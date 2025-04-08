
/*
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page.dart';

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  EmailVerificationPageState createState() => EmailVerificationPageState();
}

class EmailVerificationPageState extends State<EmailVerificationPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;
  Timer? timer;
  bool isEmailVerified = false;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    _reloadUser(); // التحقق الفوري عند الدخول

    // بدء التحقق التلقائي كل 3 ثوانٍ
    timer = Timer.periodic(Duration(seconds: 3), (timer) async {
      await _reloadUser();
    });
  }

  /// 🔄 تحديث بيانات المستخدم
  Future<void> _reloadUser() async {
    await user?.reload(); // تحديث بيانات المستخدم
    setState(() {
      isEmailVerified = user!.emailVerified;
    });

    if (isEmailVerified) {
      _navigateToHome();
    }
  }

  /// ✅ الانتقال إلى الصفحة الرئيسية بعد التحقق
  void _navigateToHome() {
    timer?.cancel(); // إيقاف التحقق الدوري
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  /// 📩 إعادة إرسال رابط التحقق
  Future<void> _sendVerificationEmail() async {
    try {
      await user?.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم إرسال رابط التحقق إلى بريدك الإلكتروني')),
      );
    } catch (e) {
      print("خطأ أثناء إرسال البريد الإلكتروني: $e");
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
      print("بناء الواجهة"); // 🔍 تتبع بناء الواجهة

    return Scaffold(
      appBar: AppBar(title: Text('التحقق من البريد')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.email, color: Colors.blue, size: 100),
              SizedBox(height: 20),
              Text(
                isEmailVerified
                    ? 'تم التحقق من البريد الإلكتروني! يمكنك المتابعة الآن.'
                    : 'لقد أرسلنا رابط تحقق إلى بريدك الإلكتروني. الرجاء التحقق منه.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),

              /// ✅ زر المتابعة (يتم تفعيله فقط بعد التحقق الحقيقي)
              ElevatedButton(
                onPressed: isEmailVerified ? _navigateToHome : null,
                child: Text('متابعة'),
              ),

              SizedBox(height: 10),

              /// 📩 زر إعادة إرسال التحقق
              TextButton(
                onPressed: _sendVerificationEmail,
                child: Text('إعادة إرسال رابط التحقق'),
              ),

              SizedBox(height: 10),

              /// 🔄 زر التحقق اليدوي
              ElevatedButton(
                onPressed: _reloadUser,
                child: Text('تم التحقق يدويًا'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:register_app2/RealTimePoolStatus.dart';

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  EmailVerificationPageState createState() => EmailVerificationPageState();
}

class EmailVerificationPageState extends State<EmailVerificationPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;
  Timer? timer;
  bool isEmailVerified = false;
  bool isChecking = false;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    _reloadUser(); // التحقق الفوري عند الدخول

    // بدء التحقق التلقائي كل 3 ثوانٍ فقط إذا لم يكن البريد محققًا
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
    timer?.cancel(); // إيقاف التحقق الدوري
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const RealTimePoolStatus()),
    );
  }

  /// 📩 إعادة إرسال رابط التحقق
  Future<void> _sendVerificationEmail() async {
    try {
      await user?.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A verification link has been sent to your email')), 
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
                    : "📩 We've sent a verification link to your email. Please check it",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _navigateToHome,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF035079),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'done',
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
