/*import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_check.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:email_validator/email_validator.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  SignUpPageState createState() => SignUpPageState();
}

class SignUpPageState extends State<SignUpPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  String? selectedUserType;
  String countryDialCode = '+966';

  bool isValidEmail(String email) {
    return EmailValidator.validate(email);
  }

  bool isValidPhone(String phone) {
    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
    return phoneRegex.hasMatch(phone);
  }

  bool isValidFirstName(String firstName) {
    return firstName.length >= 4;
  }

  bool isValidLastName(String lastName) {
    return lastName.length >= 4;
  }

  bool isValidPassword(String password) {
    final passwordRegex = RegExp(
        r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[!@#\$%^&*(),.?":{}|<>])[A-Za-z\d!@#\$%^&*(),.?":{}|<>]{8,}$');
    return passwordRegex.hasMatch(password);
  }

  Future<bool> isPhoneNumberExistsInBothCollections(String phoneNumber) async {
    try {
      final QuerySnapshot userResult = await FirebaseFirestore.instance
          .collection('users')
          .where('phone_number', isEqualTo: phoneNumber)
          .limit(1)
          .get();

      final QuerySnapshot adminResult = await FirebaseFirestore.instance
          .collection('admin')
          .where('admPhone', isEqualTo: phoneNumber)
          .limit(1)
          .get();

      return userResult.docs.isNotEmpty || adminResult.docs.isNotEmpty;
    } catch (e) {
      print('Error checking phone number: $e');
      return false;
    }
  }

  Future<void> signUp(BuildContext context) async {
    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty ||
        firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        selectedUserType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    if (!isValidPassword(passwordController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Password must contain at least 8 characters, including uppercase, lowercase, numbers, and symbols')),
      );
      return;
    }

    if (!isValidFirstName(firstNameController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('First name must be at least 4 characters long')),
      );
      return;
    }

    if (!isValidLastName(lastNameController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Last name must be at least 4 characters long')),
      );
      return;
    }

    String phoneNumber = phoneController.text.trim();
    if (!RegExp(r'^[1-9][0-9]{8}$').hasMatch(phoneNumber)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Please enter a valid phone number (9 digits, no leading zero)')),
      );
      return;
    }

    bool phoneExists = await isPhoneNumberExistsInBothCollections(phoneNumber);
    if (phoneExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number is already in use')),
      );
      return;
    }

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      User? user = userCredential.user;
      if (user != null) {
        final String uid = user.uid;
        final String phoneFull = '$countryDialCode$phoneNumber';

        if (selectedUserType == 'owner') {
          await FirebaseFirestore.instance.collection('users').doc(uid).set({
            'email': emailController.text.trim(),
            'first_name': firstNameController.text.trim(),
            'last_name': lastNameController.text.trim(),
            'phone_number': phoneFull,
            'user_type': 'owner',
          });
        } else if (selectedUserType == 'admin') {
          await FirebaseFirestore.instance.collection('admin').doc(uid).set({
            'admEmail': emailController.text.trim(),
            'admFirstName': firstNameController.text.trim(),
            'admLastName': lastNameController.text.trim(),
            'admPhone': phoneFull,
            'user_type': 'admin',
          });
        }

        await user.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification email sent. Please check your inbox.')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AuthCheck()),
        );
      }
    } catch (e) {
      String errorMessage = 'An error occurred during registration';
      if (e is FirebaseAuthException) {
        if (e.code == 'email-already-in-use') {
          errorMessage = 'Email is already in use. Please use another email address.';
        } else if (e.code == 'weak-password') {
          errorMessage =
              'The password you entered is too weak. Please make sure it contains at least 8 characters, including uppercase, lowercase, numbers, and symbols.';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'The email address is not valid. Please enter a valid email address.';
        } else if (e.code == 'operation-not-allowed') {
          errorMessage = 'This operation is not allowed. Please enable email/password sign-in in your Firebase console.';
        } else {
          errorMessage = e.message ?? 'An unknown error occurred. Please try again later.';
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
      print('Error during sign-up: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        backgroundColor: const Color(0xFF035079),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage('images/register2.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Register',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please register to login',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'E-mail',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: firstNameController,
                    decoration: InputDecoration(
                      labelText: 'First Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: lastNameController,
                    decoration: InputDecoration(
                      labelText: 'Last Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  IntlPhoneField(
                    decoration: InputDecoration(
                      labelText: 'Phone',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    initialCountryCode: 'SA',
                    onChanged: (phone) {
                      setState(() {
                        countryDialCode = phone.countryCode;
                        phoneController.text = phone.number;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    hint: const Text('Select User Type'),
                    value: selectedUserType,
                    items: const [
                      DropdownMenuItem(
                        value: 'owner',
                        child: Text('Owner'),
                      ),
                      DropdownMenuItem(
                        value: 'admin',
                        child: Text('Admin'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedUserType = value;
                      });
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => signUp(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xCC035079),
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    child: const Text('Sign Up'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

بدون تحديد كم ادمن 
*/

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_check.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  SignUpPageState createState() => SignUpPageState();
}

class SignUpPageState extends State<SignUpPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  String? selectedUserType;
  String countryDialCode = '+966';

  Future<void> signUp(BuildContext context) async {
    print("Sign up button pressed ✅");

    // التحقق من الحقول
    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty ||
        firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        selectedUserType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    final passwordRegex = RegExp(
        r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[!@#\$%^&*(),.?":{}|<>])[A-Za-z\d!@#\$%^&*(),.?":{}|<>]{8,}$');
    if (!passwordRegex.hasMatch(passwordController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must contain uppercase, lowercase, number and symbol')),
      );
      return;
    }

    // التحقق من وجود ادمن مسبقاً
    if (selectedUserType == 'admin') {
      final existingAdmin = await FirebaseFirestore.instance
          .collection('admin')
          .limit(1)
          .get();

      if (existingAdmin.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An admin account already exists. Only one admin is allowed.')),
        );
        return;
      }
    }

    try {
      final UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailController.text.trim(),
              password: passwordController.text);

      final user = userCredential.user;
      final String phoneFull = '$countryDialCode${phoneController.text.trim()}';

      if (user != null) {
        final String uid = user.uid;

        if (selectedUserType == 'owner') {
          await FirebaseFirestore.instance.collection('users').doc(uid).set({
            'email': emailController.text.trim(),
            'first_name': firstNameController.text.trim(),
            'last_name': lastNameController.text.trim(),
            'phone_number': phoneFull,
            'user_type': 'owner',
          });
        } else if (selectedUserType == 'admin') {
          await FirebaseFirestore.instance.collection('admin').doc(uid).set({
            'admEmail': emailController.text.trim(),
            'admFirstName': firstNameController.text.trim(),
            'admLastName': lastNameController.text.trim(),
            'admPhone': phoneFull,
            'user_type': 'admin',
          });
        }

        await user.sendEmailVerification();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification email sent.')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AuthCheck()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        backgroundColor: const Color(0xFF035079),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage('images/register2.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Register',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please register to login',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'E-mail',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: firstNameController,
                    decoration: InputDecoration(
                      labelText: 'First Name',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: lastNameController,
                    decoration: InputDecoration(
                      labelText: 'Last Name',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  IntlPhoneField(
                    decoration: InputDecoration(
                      labelText: 'Phone',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    initialCountryCode: 'SA',
                    onChanged: (phone) {
                      setState(() {
                        countryDialCode = phone.countryCode;
                        phoneController.text = phone.number;
                      });
                    },
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
                  const SizedBox(height: 16),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: selectedUserType,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    hint: const Text('Select User Type'),
                    items: const [
                      DropdownMenuItem(value: 'owner', child: Text('Owner')),
                      DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedUserType = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      signUp(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF035079),
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // <-- نص أبيض
                      ),
                    ),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(color: Colors.white), // <-- تأكد أن النص أبيض
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
