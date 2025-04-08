import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'UpdateVerifi.dart'; // تأكد من صحة المسار

class ProfileForm extends StatefulWidget {
  const ProfileForm({super.key});

  @override
  ProfileFormState createState() => ProfileFormState();
}

class ProfileFormState extends State<ProfileForm> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  bool _isLoading = true;

  final Color primaryColor = const Color(0xFF035079);
  final Color accentColor = const Color(0xCC035079);
  final Color textColor = Colors.black;
  final Gradient mainGradient = const LinearGradient(
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

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          setState(() {
            _emailController.text = userDoc['email'] ?? '';
            _firstNameController.text = userDoc['first_name'] ?? '';
            _lastNameController.text = userDoc['last_name'] ?? '';
            _phoneNumberController.text = userDoc['phone_number'] ?? '';
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('⚠️ Failed to load data: $e')),
        );
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToUpdateField(String field, String currentValue) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateFieldPage(field: field, currentValue: currentValue),
      ),
    );
  }

  Future<void> deleteMyAccountCompletely(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String uid = user.uid;

      try {
        // 1️⃣ حذف جميع المسابح
        QuerySnapshot poolsSnapshot = await FirebaseFirestore.instance
            .collection('pools')
            .where('ownerId', isEqualTo: uid)
            .get();

        for (var doc in poolsSnapshot.docs) {
          await FirebaseFirestore.instance.collection('pools').doc(doc.id).delete();
        }

        // 2️⃣ حذف وثيقة المستخدم
        await FirebaseFirestore.instance.collection('users').doc(uid).delete();

        // 3️⃣ حذف الحساب من Firebase Auth
        await user.delete();

        Navigator.of(context).popUntil((route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account deleted successfully")),
        );

      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please re-login to delete your account.")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Auth Error: ${e.message}")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Page'),
        backgroundColor: primaryColor,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: mainGradient),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildProfileRow('Email', _emailController.text, 'email'),
                    _buildProfileRow('First Name', _firstNameController.text, 'first_name'),
                    _buildProfileRow('Last Name', _lastNameController.text, 'last_name'),
                    _buildProfileRow('Phone Number', _phoneNumberController.text, 'phone_number'),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () async {
                        bool confirmed = await showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text("Confirm Delete"),
                            content: const Text("Are you sure you want to delete your account?"),
                            actions: [
                              TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text("Cancel")),
                              TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text("Delete")),
                            ],
                          ),
                        );

                        if (confirmed) {
                          await deleteMyAccountCompletely(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text("Delete My Account"),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildProfileRow(String label, String value, String field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: TextField(
                controller: TextEditingController(text: value),
                readOnly: true,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                style: TextStyle(color: textColor),
              ),
            ),
            TextButton(
              onPressed: () => _navigateToUpdateField(field, value),
              child: Text('Edit', style: TextStyle(color: accentColor)),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}