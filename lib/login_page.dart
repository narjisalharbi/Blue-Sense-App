/*import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:register_app2/menu.dart';
import 'package:register_app2/pools_overview_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final int maxLoginAttempts = 5;
  bool isLocked = false;

  @override
  void initState() {
    super.initState();
    _loadLockState();
  }

  Future<void> _loadLockState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLocked = prefs.getBool('isLocked') ?? false;
    });
  }

  bool isValidEmail(String email) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }

  bool containsSpecialCharacters(String input) {
    final regex = RegExp(r'[!#$%^&*(),?":{}|<>]');
    return regex.hasMatch(input);
  }

  Future<void> signIn(BuildContext context) async {
    String email = emailController.text.trim();
    String password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال البريد وكلمة المرور')),
      );
      return;
    }

    if (!isValidEmail(email) || containsSpecialCharacters(email) || containsSpecialCharacters(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('مدخلات غير صالحة')),
      );
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        // ✅ إزالة الحظر (إذا كان موجود)
        final blockedQuery = await FirebaseFirestore.instance
            .collection('blocked_users')
            .where('ownerEmail', isEqualTo: email)
            .limit(1)
            .get();

        if (blockedQuery.docs.isNotEmpty) {
          await FirebaseFirestore.instance.collection('blocked_users').doc(blockedQuery.docs.first.id).delete();
          print("✅ تم فك الحظر تلقائيًا بعد تسجيل الدخول");
        }

        await FirebaseFirestore.instance.collection('login_attempts').doc(email).delete();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLocked', false);

        String uid = user.uid;

        // 🔍 تحقق من نوع المستخدم
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
        if (userDoc.exists && userDoc['user_type'] == 'owner') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Menu()));
          return;
        }

        DocumentSnapshot adminDoc = await FirebaseFirestore.instance.collection('admin').doc(uid).get();
        if (adminDoc.exists && adminDoc['user_type'] == 'admin') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const PoolsOverviewPage()));
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('نوع المستخدم غير معروف')),
        );
      }
    } on FirebaseAuthException catch (e) {
      // محاولة خاطئة
      DocumentReference attemptRef = FirebaseFirestore.instance.collection('login_attempts').doc(email);
      DocumentSnapshot attemptSnap = await attemptRef.get();

      int attempts = 1;
      if (attemptSnap.exists) {
        attempts = (attemptSnap['count'] ?? 0) + 1;
      }

      await attemptRef.set({'count': attempts});

      if (e.code == 'wrong-password') {
        if (attempts >= maxLoginAttempts) {
          // 🛑 حظر المستخدم
          await FirebaseFirestore.instance.collection('blocked_users').add({
            'ownerEmail': email,
            'timestamp': FieldValue.serverTimestamp(),
            'reason': 'Exceeded $maxLoginAttempts failed login attempts',
            'isActive': true,
          });

          // إرسال رابط إعادة تعيين كلمة المرور
          String resetMessage = '';
          try {
            await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
            resetMessage = '📧 تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك';
          } catch (e) {
            resetMessage = '❌ فشل في إرسال الرابط: $e';
          }

          // إشعار الإدمن
          await FirebaseFirestore.instance.collection('admin_notifications').add({
            'ownerEmail': email,
            'timestamp': FieldValue.serverTimestamp(),
            'message': '🚨 تم حظر المستخدم بعد $maxLoginAttempts محاولات',
            'resetLink': resetMessage,
          });

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLocked', true);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("🚫 تم حظرك مؤقتًا.\n$resetMessage")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ كلمة المرور غير صحيحة. المتبقي: ${maxLoginAttempts - attempts}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: ${e.message}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل الدخول'),
        backgroundColor: const Color(0xFF035079),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: 150,
                height: 150,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage('images/LOG.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isLocked ? null : () => signIn(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isLocked ? Colors.grey : const Color(0xCC035079),
                ),
                child: Text(isLocked ? 'محظور' : 'تسجيل الدخول'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {}, // يمكنك إضافة نسيت كلمة المرور هنا
                child: const Text('نسيت كلمة المرور؟'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/

/*
 يخزن
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:register_app2/menu.dart';
import 'package:register_app2/pools_overview_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final int maxLoginAttempts = 5;
  bool isLocked = false;

  @override
  void initState() {
    super.initState();
    _loadLockState();
  }

  Future<void> _loadLockState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLocked = prefs.getBool('isLocked') ?? false;
    });
  }

  bool isValidEmail(String email) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }

  bool containsSpecialCharacters(String input) {
    final regex = RegExp(r'[!#$%^&*(),?":{}|<>]');
    return regex.hasMatch(input);
  }

  Future<void> signIn(BuildContext context) async {
    String email = emailController.text.trim();
    String password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال البريد وكلمة المرور')),
      );
      return;
    }

    if (!isValidEmail(email) || containsSpecialCharacters(email) || containsSpecialCharacters(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('مدخلات غير صالحة')),
      );
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        // ✅ فك الحظر تلقائيًا إذا كان موجودًا
        final blockedQuery = await FirebaseFirestore.instance
            .collection('blocked_users')
            .where('ownerEmail', isEqualTo: email)
            .limit(1)
            .get();

        if (blockedQuery.docs.isNotEmpty) {
          await FirebaseFirestore.instance.collection('blocked_users').doc(blockedQuery.docs.first.id).delete();
          print("✅ تم فك الحظر تلقائيًا بعد تسجيل الدخول");
        }

        await FirebaseFirestore.instance.collection('login_attempts').doc(email).delete();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLocked', false);

        String uid = user.uid;

        // 🔍 التحقق من نوع المستخدم
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
        if (userDoc.exists && userDoc['user_type'] == 'owner') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Menu()));
          return;
        }

        DocumentSnapshot adminDoc = await FirebaseFirestore.instance.collection('admin').doc(uid).get();
        if (adminDoc.exists && adminDoc['user_type'] == 'admin') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const PoolsOverviewPage()));
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('نوع المستخدم غير معروف')),
        );
      }
    } on FirebaseAuthException catch (e) {
      // تحقق من عدد المحاولات
      DocumentReference attemptRef = FirebaseFirestore.instance.collection('login_attempts').doc(email);
      DocumentSnapshot attemptSnap = await attemptRef.get();

      int attempts = 1;
      if (attemptSnap.exists) {
        attempts = (attemptSnap['count'] ?? 0) + 1;
      }

      await attemptRef.set({'count': attempts});

      if (attempts >= maxLoginAttempts) {
        // 🔴 تحقق أولًا إذا كان المستخدم موجودًا مسبقًا في blocked_users
        final existingBlockQuery = await FirebaseFirestore.instance
            .collection('blocked_users')
            .where('ownerEmail', isEqualTo: email)
            .limit(1)
            .get();

        if (existingBlockQuery.docs.isEmpty) {
          // ✅ إضافة المستخدم إلى `blocked_users`
          await FirebaseFirestore.instance.collection('blocked_users').add({
            'ownerEmail': email,
            'timestamp': FieldValue.serverTimestamp(),
            'reason': 'تم الحظر بسبب تجاوز الحد المسموح من المحاولات',
            'isActive': true,
          });

          print("🚫 تم إضافة المستخدم إلى blocked_users: $email");

          // 📩 إرسال رابط إعادة تعيين كلمة المرور
          try {
            await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
            print("📧 تم إرسال رابط إعادة تعيين كلمة المرور إلى $email");
          } catch (e) {
            print("❌ فشل في إرسال الرابط: $e");
          }

          // 🔔 إشعار الإدمن
          await FirebaseFirestore.instance.collection('admin_notifications').add({
            'ownerEmail': email,
            'timestamp': FieldValue.serverTimestamp(),
            'message': '🚨 تم حظر المستخدم تلقائيًا بعد تجاوز المحاولات المسموحة',
          });

          print("🔔 تم إرسال إشعار إلى الإدمن بخصوص الحظر");
        }

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLocked', true);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("🚫 تم حظرك تلقائيًا بسبب محاولات تسجيل دخول خاطئة.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ كلمة المرور غير صحيحة. المتبقي: ${maxLoginAttempts - attempts}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل الدخول'),
        backgroundColor: const Color(0xFF035079),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            ElevatedButton(
              onPressed: isLocked ? null : () => signIn(context),
              child: Text(isLocked ? 'محظور' : 'تسجيل الدخول'),
            ),
          ],
        ),
      ),
    );
  }
}
*/
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:register_app2/ForgotPasswordScreen.dart';
import 'package:register_app2/RealTimePoolStatus.dart';
import 'package:register_app2/SignUpPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:register_app2/pools_overview_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final int maxLoginAttempts = 3;
  bool isLocked = false;

  @override
  void initState() {
    super.initState();
    _loadLockState();
  }

  Future<void> _loadLockState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLocked = prefs.getBool('isLocked') ?? false;
    });
  }

  bool isValidEmail(String email) {
    final regex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$');

    return regex.hasMatch(email);
  }

  bool isValidPassword(String password) {
  final passwordRegex = RegExp(
  r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[!@#\$%^&*(),.?":{}|<>])[A-Za-z\d!@#\$%^&*(),.?":{}|<>]{8,}$');

    return passwordRegex.hasMatch(password);
  }

  Future<void> signIn(BuildContext context) async {
    String email = emailController.text.trim();
    String password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email and password')),
      );
      return;
    }

  

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        if (!user.emailVerified) {
          await user.sendEmailVerification();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('📩 Verification email sent. Please check your inbox.')),
          );
          await FirebaseAuth.instance.signOut();
          return;
        }

        final blockedQuery = await FirebaseFirestore.instance
            .collection('blocked_users')
            .where('ownerEmail', isEqualTo: email)
            .limit(1)
            .get();

        if (blockedQuery.docs.isNotEmpty) {
          await FirebaseFirestore.instance.collection('blocked_users').doc(blockedQuery.docs.first.id).delete();
        }

        await FirebaseFirestore.instance.collection('login_attempts').doc(email).delete();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLocked', false);

        String uid = user.uid;
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
        if (userDoc.exists && userDoc['user_type'] == 'owner') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const RealTimePoolStatus()));
          return;
        }

        DocumentSnapshot adminDoc = await FirebaseFirestore.instance.collection('admin').doc(uid).get();
        if (adminDoc.exists && adminDoc['user_type'] == 'admin') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const PoolsOverviewPage()));
          return;
        }
      }
    } on FirebaseAuthException {
      DocumentReference attemptRef = FirebaseFirestore.instance.collection('login_attempts').doc(email);
      DocumentSnapshot attemptSnap = await attemptRef.get();
      int attempts = 1;
      if (attemptSnap.exists) {
        attempts = (attemptSnap['count'] ?? 0) + 1;
      }
      await attemptRef.set({'count': attempts});

      if (attempts >= maxLoginAttempts) {
        final existingBlockQuery = await FirebaseFirestore.instance
            .collection('blocked_users')
            .where('ownerEmail', isEqualTo: email)
            .limit(1)
            .get();

        if (existingBlockQuery.docs.isEmpty) {
          await FirebaseFirestore.instance.collection('blocked_users').add({
            'ownerEmail': email,
            'timestamp': FieldValue.serverTimestamp(),
            'reason': 'Banned due to exceeding the allowed number of attempts',
            'isActive': true,
          });

          await FirebaseFirestore.instance.collection('admin_notifications').add({
            'ownerEmail': email,
            'timestamp': FieldValue.serverTimestamp(),
            'message': '🚨 User banned after exceeding allowed attempts',
          });
        }

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLocked', true);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("🚫 You have been blocked due to incorrect login attempts.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text('❌ Incorrect password. Remaining attempts: ${maxLoginAttempts - attempts}'))
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log in'),
        backgroundColor: const Color(0xFF035079),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage('images/LOG.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLocked ? null : () => signIn(context),
              child: Text(isLocked ? 'blocked' : 'Log in'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
              ),
              child: const Text('Forgot your password?'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SignUpPage()),
              ),
              child: const Text("Don't have an account? Sign up now"),
            ),
          ],
        ),
      ),
    );
  }
}
