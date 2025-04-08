import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isLoading = false;
  String? errorMessage;
  bool isResetLinkSent = false;

  Future<void> resetPassword() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    String email = emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        isLoading = false;
        errorMessage = 'Please enter your email';
      });
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
      setState(() {
        isResetLinkSent = true;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        backgroundColor: const Color(0xFF035079),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF87CDF2),
              Color(0xFFD0E1EB),
              Color(0xFFDFF4FF),
              Colors.white,
            ],
          ),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!isResetLinkSent) ...[
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: resetPassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF035079),
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                          ),
                          child: const Text(
                            'Send Password Reset Email',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                  if (errorMessage != null) ...[
                    const SizedBox(height: 10),
                    Text(errorMessage!, style: const TextStyle(color: Colors.red)),
                  ],
                ] else ...[
                  const Text(
                    'A password reset link has been sent to your email. Please check your email and follow the instructions.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
