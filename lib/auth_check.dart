/*import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'home_page.dart';

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            return HomePage();
          } else {
            return LoginPage();
          }
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
*/


/*
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:register_app2/EmailVerificationPage.dart';
import 'login_page.dart';
//
//import 'home_page.dart';

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            User? user = snapshot.data;

            // إذا كان المستخدم قد سجل الدخول ولكنه لم يتحقق من البريد الإلكتروني بعد
            if (user != null && !user.emailVerified) {
              return EmailVerificationPage();  // الانتقال إلى صفحة التحقق من البريد
            } else {
              return EmailVerificationPage();  // الانتقال إلى الصفحة الرئيسية إذا تم التحقق من البريد
            }
          } else {
            return LoginPage();  // الانتقال إلى صفحة تسجيل الدخول إذا لم يكن المستخدم مسجلاً
          }
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
شغال 
*/
/*
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:register_app2/EmailVerificationPage.dart';
import 'package:register_app2/home_page.dart';  // تأكد من استيراد الصفحة الرئيسية
import 'login_page.dart';

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            User? user = snapshot.data;

            // التحقق مما إذا كان البريد الإلكتروني قد تم تأكيده أم لا
            if (user != null && !user.emailVerified) {
              return EmailVerificationPage();  // توجيه المستخدم إلى صفحة التحقق
            } else {
              return HomePage();  // توجيه المستخدم إلى الصفحة الرئيسية بعد التحقق
            }
          } else {
            return LoginPage();  // إذا لم يكن المستخدم مسجلاً، يتم توجيهه إلى تسجيل الدخول
          }
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}*/

/*
حور

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page.dart';
import 'login_page.dart';


class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  User? user;
  Timer? timer;
  bool isEmailVerified = false;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;

    if (user != null && !user!.emailVerified) {
      _sendVerificationEmail(); // ⏩ إرسال التحقق عند دخول الصفحة
      _startEmailCheck(); // ⏩ بدء التحقق الدوري
    } else {
      isEmailVerified = true; // ✅ إذا كان الحساب مفعّل مسبقًا
    }
  }

  /// 📩 إرسال رابط التحقق
  Future<void> _sendVerificationEmail() async {
    try {
      await user?.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم إرسال رابط التحقق إلى بريدك الإلكتروني')),
      );
    } catch (e) {
      print("خطأ في إرسال التحقق: $e");
    }
  }

  /// 🔍 التحقق مما إذا كان البريد مفعلًا كل 3 ثوانٍ
  void _startEmailCheck() {
    timer = Timer.periodic(Duration(seconds: 3), (timer) async {
      await user?.reload();
      if (user?.emailVerified ?? false) {
        setState(() {
          isEmailVerified = true;
        });

        timer.cancel(); // ⏹️ إيقاف المؤقت بعد التحقق
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم التحقق من البريد الإلكتروني! يمكنك المتابعة الآن.')),
        );
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel(); // ⏹️ تأكد من إيقاف المؤقت عند مغادرة الصفحة
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            user = snapshot.data;
            
            if (user != null && !user!.emailVerified) {
              return _buildVerificationScreen();  // ⏳ صفحة انتظار التحقق
            } else {
              return HomePage(); // ✅ انتقال بعد التحقق
            }
          } else {
            return LoginPage(); // ⏩ إذا لم يسجل الدخول، العودة لصفحة تسجيل الدخول
          }
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  /// 📨 واجهة انتظار التحقق من البريد
  Widget _buildVerificationScreen() {
    return Scaffold(
      appBar: AppBar(title: Text('التحقق من البريد')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.email, color: Colors.blue, size: 100),
            SizedBox(height: 20),
            Text(
              isEmailVerified
                  ? 'تم التحقق! يمكنك المتابعة الآن.'
                  : 'لقد أرسلنا رابط تحقق إلى بريدك الإلكتروني. الرجاء التحقق منه.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isEmailVerified
                  ? () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage()),
                      );
                    }
                  : null, // ❌ الزر يكون معطلًا حتى يتم التحقق
              child: Text('متابعة'),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: _sendVerificationEmail,
              child: Text('إعادة إرسال رابط التحقق'),
            ),
          ],
        ),
      ),
    );
  }
}
حورر
*/


import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:register_app2/login_page.dart';

class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  EmailVerificationPageState createState() => EmailVerificationPageState();
}

class EmailVerificationPageState extends State<AuthCheck> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;
  Timer? timer;
  bool isEmailVerified = false;
  bool isChecking = false;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    _reloadUser(); 

    timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      await _reloadUser();
    });
  }

  /// 🔄 تحديث بيانات المستخدم
  Future<void> _reloadUser() async {
    if (isChecking) return;
    setState(() => isChecking = true);
    
    await user?.reload(); // تحديث بيانات المستخدم
    setState(() {
      isEmailVerified = user?.emailVerified ?? false;
      isChecking = false;
    });

    if (isEmailVerified) {
      _navigateToHome();
    }
  }

  /// ✅ الانتقال إلى الصفحة الرئيسية بعد التحقق
  void _navigateToHome() {
    timer?.cancel(); 
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  /// 📩 إعادة إرسال رابط التحقق
  Future<void> _sendVerificationEmail() async {
    try {
      await user?.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("A verification link has been sent to your email.")), 
      );
      
      Future.delayed(const Duration(seconds: 3), () {
        FirebaseAuth.instance.currentUser?.delete(); // حذف الحساب إذا لم يتم التحقق بعد فترة
      });
    } catch (e) {
      print("Error sending email: $e");
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF035079),
        title: const Text('Check mail', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.email, color: Colors.blue, size: 100),
              const SizedBox(height: 20),
              Text(
                isEmailVerified
                    ? '✅ Email verified! You can proceed now.'
                    : "📩 We've sent a verification link to your email. Please check it.",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),

              /// ✅ زر المتابعة يعمل دائمًا
              ElevatedButton(
                onPressed: _navigateToHome,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF035079),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Done',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              /// 📩 زر إعادة إرسال التحقق مع حذف الحساب بعد فترة إذا لم يتم التحقق
              TextButton(
                onPressed: _sendVerificationEmail,
                child: const Text(
                  'Resend verification link',
                  style: TextStyle(color: Color(0xFF035079), fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 10),

            ],
          ),
        ),
      ),
    );
  }
}
