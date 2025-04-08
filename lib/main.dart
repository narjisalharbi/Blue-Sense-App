

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:register_app2/RealTimePoolStatus.dart';
import 'package:register_app2/SignUpPage.dart';
import 'package:register_app2/login_page.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blue Sense',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:FirstPage(), 
      navigatorObservers: [routeObserver],
    );
  }
}



////------------FirstPage-------------////
class FirstPage extends StatelessWidget {
  const FirstPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // خلفية الصورة
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/first.jpg"), 
                fit: BoxFit.cover,
              ),
            ),
          ),
          // النصوص العلوية
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Column(
              children: const [
                Text(
                  'Your Safety,',
                  style: TextStyle(
                    color: Color.fromARGB(255, 0, 0, 0),
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Our priority',
                  style: TextStyle(
                    color: Color.fromARGB(255, 0, 0, 0),
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          // زر Next
          Positioned(
            bottom: 50,
            right: 30,
            child: InkWell(
              onTap: () {
                // الانتقال إلى صفحة الترحيب
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WelcomePage()),
                );
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'Next',
                      style: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}





/////--------WelcomePage----------//////
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
            colors: [
              Color(0xFF87CDF2),
              Color.fromARGB(255, 139, 197, 228),
              Color(0xCC49A3D1),
              Color(0xE587C0DD),
              Color(0xFFDCE9F0),
              Color(0xFFD0E1EB),
              Color(0xFFDFF4FF),
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 80),
            const Text(
              'Welcome\nBlue Sense!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 40,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 30),
            Container(
              width: 249,
              height: 366,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("images/first.jpg"),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(80),
                  topRight: Radius.circular(80),
                ),
              ),
            ),
            const SizedBox(height: 50),
            // زر Sign up
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpPage()),
                );
              },
              borderRadius: BorderRadius.circular(26),
              child: Container(
                width: 300,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xCC035079),
                  borderRadius: BorderRadius.circular(26),
                ),
                child: const Center(
                  child: Text(
                    'Sign up',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 3,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // زر Sign in
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              borderRadius: BorderRadius.circular(26),
              child: Container(
                width: 300,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: const Center(
                  child: Text(
                    'Sign in',
                    style: TextStyle(
                      color: Color(0xFF035079),
                      fontSize: 30,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 3,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    ),
  );
}

}
