import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateFieldPage extends StatefulWidget {
  final String field;
  final String currentValue;

  const UpdateFieldPage({super.key, required this.field, required this.currentValue});

  @override
  UpdateFieldPageState createState() => UpdateFieldPageState();
}

class UpdateFieldPageState extends State<UpdateFieldPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late TextEditingController _controller;
  late TextEditingController _otpController;
  bool _isUpdating = false;
  bool _isVerifyingOtp = false;
  String? verificationId;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentValue);
    _otpController = TextEditingController();
  }

  // **إرسال OTP عبر البريد الإلكتروني**
  Future<void> _sendEmailOtp() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await user.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ تم إرسال رابط التحقق إلى بريدك الإلكتروني!')),
      );
      setState(() {
        _isVerifyingOtp = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('⚠️ فشل إرسال رابط التحقق: $e')));
    }
  }

  // **التحقق من OTP**
  Future<void> _verifyOtp() async {
    final user = _auth.currentUser;
    if (user == null) return;

    // يجب أن يتحقق المستخدم من البريد الإلكتروني أولا عبر الرابط المرسل
    await user.reload();
    if (user.emailVerified) {
      _updateFieldInFirestore();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ الرجاء التحقق من بريدك الإلكتروني أولاً!')),
      );
      setState(() {
        _isVerifyingOtp = false;
      });
    }
  }

  // **تحديث الحقل في Firestore بعد التحقق**
  Future<void> _updateFieldInFirestore() async {
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      await _firestore.collection('users').doc(user.uid).update({
        widget.field: _controller.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ تم تحديث البيانات بنجاح!')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('⚠️ فشل التحديث: $e')));
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  // **الدالة عند الضغط على حفظ التعديلات**
  void _onUpdatePressed() {
    _sendEmailOtp();
  }

  // **الدالة للتحقق من OTP**
  void _onVerifyOtpPressed() {
    _verifyOtp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تعديل البيانات')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'أدخل ${widget.field} الجديد',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            _isVerifyingOtp
                ? Column(
                    children: [
                      TextField(
                        controller: _otpController,
                        decoration: const InputDecoration(
                          labelText: 'أدخل رمز التحقق',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _onVerifyOtpPressed,
                        child: const Text('تحقق من رمز التحقق'),
                      ),
                    ],
                  )
                : ElevatedButton(
                    onPressed: _onUpdatePressed,
                    child: const Text('حفظ التعديلات'),
                  ),
            if (_isUpdating) const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _otpController.dispose();
    super.dispose();
  }
}