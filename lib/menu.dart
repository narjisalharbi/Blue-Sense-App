import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:register_app2/ManageScreen.dart';
import 'ProfileHeader.dart'; 

// الثوابت الخاصة بالتنسيق (مستوحاة من AppTheme)
const Color primaryColor = Color(0xFF035079);
const Color accentColor = Color(0xCC035079);
const Color textColor = Colors.black;
const Gradient mainGradient = LinearGradient(
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
);

class Menu  extends StatelessWidget {
  const Menu  ({super.key});

  // دالة لجلب اسم المالك من Firestore بناءً على الـ UID الحالي
  Future<String> fetchOwnerName() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return "${data['first_name'] ?? ''} ${data['last_name'] ?? ''}".trim();
      }
    }
    return "Owner";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Owner Dashboard"),
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: mainGradient),
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 12),
                // استخدام FutureBuilder لجلب الاسم من Firestore
                FutureBuilder<String>(
                  future: fetchOwnerName(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return const Center(child: Text("Error fetching name"));
                    } else {
                      return ProfileHeader(ownerName: snapshot.data!);
                    }
                  },
                ),
                const SizedBox(height: 179),
                ProfileMenuItem(
                  title: 'My Account',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfileForm()),
                    );
                  },
                ),
                const SizedBox(height: 26),
                ProfileMenuItem(
                  title: 'My Pools',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ManageScreen()),
                    );
                  },
                ),
                const SizedBox(height: 360),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  final String ownerName;
  const ProfileHeader({super.key, required this.ownerName});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 36),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(63),
              bottomLeft: Radius.circular(63),
            ),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.25),
                blurRadius: 4,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(
                    'https://cdn.builder.io/api/v1/image/assets/TEMP/2f5b28fbe4989b508b4b1178f867d5c24e9319cbcd5e67c49b3049d958e90d0a?placeholderIfAbsent=true&apiKey=1c0ea8106c53462488ab386c4e1ad287'
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  ownerName,
                  style: const TextStyle(
                    fontFamily: 'Inria Serif',
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.5,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ProfileMenuItem extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  const ProfileMenuItem({super.key, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 70),
        decoration: BoxDecoration(
          color: const Color(0xFFDFF4FF),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.25),
              blurRadius: 4,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Inria Serif',
            fontSize: 25,
            letterSpacing: 2.5,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
