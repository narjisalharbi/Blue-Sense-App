import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//--------------------- الثوابت المُستخدمة للتنسيق ---------------------
const Color primaryColor = Color(0xFF035079);
const Color accentColor = Color(0xCC035079);
const Color textColor = Colors.black;
const Color buttonTextColor = Colors.white;

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

//--------------------- PoolDetailsScreen ---------------------
class PoolDetailsScreen extends StatefulWidget {
  const PoolDetailsScreen({super.key});

  @override
  _PoolDetailsScreenState createState() => _PoolDetailsScreenState();
}

class _PoolDetailsScreenState extends State<PoolDetailsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _checkUserPools();
  }

  void _checkUserPools() async {
    String userEmail = _auth.currentUser?.email ?? "";
    QuerySnapshot poolSnapshot = await FirebaseFirestore.instance
        .collection('pools')
        .where('ownerEmail', isEqualTo: userEmail)
        .get();

    if (poolSnapshot.docs.isEmpty && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AddPoolScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Pools"),
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('pools')
            .where('ownerEmail', isEqualTo: _auth.currentUser?.email ?? "")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No pools found.", style: TextStyle(color: textColor)));
          }

          var pools = snapshot.data!.docs;

          return ListView.builder(
            itemCount: pools.length,
            itemBuilder: (context, index) {
              var pool = pools[index];
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  title: Text(pool['PoolName'],
                      style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                  subtitle: Text(pool['location'], style: TextStyle(color: textColor)),
                  trailing: Icon(Icons.arrow_forward_ios, color: primaryColor),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PoolPreviewScreen(poolId: pool.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: accentColor,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPoolScreen()),
          );
        },
        child: const Icon(Icons.add, color: buttonTextColor),
      ),
    );
  }
}

//--------------------- AddPoolScreen ---------------------
class AddPoolScreen extends StatefulWidget {
  const AddPoolScreen({super.key});

  @override
  _AddPoolScreenState createState() => _AddPoolScreenState();
}

class _AddPoolScreenState extends State<AddPoolScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();
  final TextEditingController _dimensionsController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isLoading = false;

  Future<void> _savePool() async {
    if (_nameController.text.trim().isEmpty ||
        _locationController.text.trim().isEmpty ||
        _typeController.text.trim().isEmpty ||
        _capacityController.text.trim().isEmpty ||
        _dimensionsController.text.trim().isEmpty) {
      _showSnackBar("Please fill all fields.", Colors.red);
      return;
    }

    String poolName = _nameController.text.trim();
    String userEmail = _auth.currentUser?.email ?? "";

    setState(() => isLoading = true);

    try {
      User? user = _auth.currentUser;

      if (user == null || !user.emailVerified) {
        _showSnackBar("Please verify your email before adding a pool.", Colors.red);
        if (user != null) await user.sendEmailVerification();
        setState(() => isLoading = false);
        return;
      }

      QuerySnapshot existingPools = await FirebaseFirestore.instance
          .collection('pools')
          .where('PoolName', isEqualTo: poolName)
          .get();

      if (existingPools.docs.isNotEmpty) {
        _showSnackBar("A pool with this name already exists!", Colors.orange);
        setState(() => isLoading = false);
        return;
      }

      DocumentReference poolRef = await FirebaseFirestore.instance.collection('pools').add({
        'PoolName': poolName,
        'location': _locationController.text.trim(),
        'type': _typeController.text.trim(),
        'capacity': int.tryParse(_capacityController.text.trim()) ?? 0,
        'dimensions': _dimensionsController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'ownerEmail': userEmail,
        'ownerId': user.uid,
      });

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PoolPreviewScreen(poolId: poolRef.id)),
        );
      }
    } catch (e) {
      _showSnackBar("An error occurred: $e", Colors.red);
    }

    setState(() => isLoading = false);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message, style: const TextStyle(color: Colors.white)),
          backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Pool"),
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTextField(_nameController, "Pool Name"),
            _buildTextField(_locationController, "Location"),
            _buildTextField(_typeController, "Type"),
            _buildTextField(_capacityController, "Capacity", isNumeric: true),
            _buildTextField(_dimensionsController, "Dimensions"),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : _savePool,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Save", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey[200],
        ),
      ),
    );
  }
}

//--------------------- PoolPreviewScreen ---------------------
class PoolPreviewScreen extends StatelessWidget {
  final String poolId;

  const PoolPreviewScreen({super.key, required this.poolId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pool Details"),
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('pools').doc(poolId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text("No Data Found", style: TextStyle(color: textColor)));
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;

          return Container(
            decoration: BoxDecoration(gradient: mainGradient),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Name: ${data['PoolName']}",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                Text("Location: ${data['location']}",
                    style: TextStyle(fontSize: 18, color: textColor)),
                Text("Type: ${data['type']}",
                    style: TextStyle(fontSize: 18, color: textColor)),
                Text("Capacity: ${data['capacity']}",
                    style: TextStyle(fontSize: 18, color: textColor)),
                Text("Dimensions: ${data['dimensions']}",
                    style: TextStyle(fontSize: 18, color: textColor)),
              ],
            ),
          );
        },
      ),
    );
  }
}