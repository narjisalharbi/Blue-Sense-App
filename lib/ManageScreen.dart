import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:register_app2/DeleteConfirmation.dart';
import 'package:register_app2/addSe.dart';
import 'package:register_app2/pool_list.dart';

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

//--------------------- ManageScreen ---------------------
class ManageScreen extends StatelessWidget {
  const ManageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Pool"),
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('pools')
            .where('ownerId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var pools = snapshot.data!.docs;

          return Container(
            decoration: BoxDecoration(gradient: mainGradient),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: pools.isEmpty
                      ? Center(
                          child: Text(
                            "No pools found. Please add a pool.",
                            style: TextStyle(color: textColor),
                          ),
                        )
                      : ListView.builder(
                          itemCount: pools.length,
                          itemBuilder: (context, index) {
                            var pool = pools[index];
                            String poolName = pool['PoolName'];
                            String poolId = pool.id;

                            return Card(
                              elevation: 3,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                title: Text(
                                  poolName,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: textColor),
                                ),
                                subtitle: Text(
                                  "Tap to manage this pool",
                                  style: TextStyle(color: textColor),
                                ),
                                trailing: Icon(Icons.arrow_forward_ios, color: primaryColor),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PoolOptionsScreen(
                                          poolId: poolId, poolName: poolName),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddPoolScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  ),
                  child: Text(
                    "Add Pool",
                    style: TextStyle(
                        color: buttonTextColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ManagePoolScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  ),
                  child: Text(
                    "Manage Pool",
                    style: TextStyle(
                        color: buttonTextColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ManageSensorsScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  ),
                  child: Text(
                    "Manage Sensors",
                    style: TextStyle(
                        color: buttonTextColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

//--------------------- ManagePoolScreen ---------------------
class ManagePoolScreen extends StatelessWidget {
  const ManagePoolScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Pool"),
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: mainGradient),
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('pools')
              .where('ownerId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                  child: Text("No pools found.", style: TextStyle(color: textColor)));
            }
            return ListView(
              children: snapshot.data!.docs.map((doc) {
                String poolName = doc['PoolName'];
                return ListTile(
                  title: Text(poolName, style: TextStyle(color: textColor)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PoolOptionsScreen(poolId: doc.id, poolName: poolName),
                      ),
                    );
                  },
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}

//--------------------- PoolOptionsScreen ---------------------
class PoolOptionsScreen extends StatelessWidget {
  final String poolId;
  final String poolName;

  const PoolOptionsScreen({super.key, required this.poolId, required this.poolName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage $poolName"),
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('pools').doc(poolId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.data!.exists) {
            return Center(child: Text("Pool not found", style: TextStyle(color: textColor)));
          }

          var poolData = snapshot.data!.data() as Map<String, dynamic>;

          return Container(
            decoration: BoxDecoration(gradient: mainGradient),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditPoolScreen(
                            poolId: poolId,
                            poolData: poolData,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                    ),
                    child: Text(
                      "Edit Pool",
                      style: TextStyle(color: buttonTextColor, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => DeleteConfirmation(poolId: poolId,),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                    ),
                    child: Text(
                      "Delete Pool",
                      style: TextStyle(color: buttonTextColor, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

//--------------------- EditPoolScreen ---------------------
class EditPoolScreen extends StatefulWidget {
  final String poolId;
  final Map<String, dynamic> poolData;

  const EditPoolScreen({super.key, required this.poolId, required this.poolData});

  @override
  _EditPoolScreenState createState() => _EditPoolScreenState();
}

class _EditPoolScreenState extends State<EditPoolScreen> {
  late TextEditingController _nameController;
  late TextEditingController _capacityController;
  late TextEditingController _dimensionsController;
  late TextEditingController _locationController;
  late TextEditingController _typeController;

  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.poolData['PoolName']);
    _capacityController = TextEditingController(text: widget.poolData['capacity'].toString());
    _dimensionsController = TextEditingController(text: widget.poolData['dimensions']);
    _locationController = TextEditingController(text: widget.poolData['location']);
    _typeController = TextEditingController(text: widget.poolData['type']);

    _nameController.addListener(_checkFields);
    _capacityController.addListener(_checkFields);
    _dimensionsController.addListener(_checkFields);
    _locationController.addListener(_checkFields);
    _typeController.addListener(_checkFields);
  }

  void _checkFields() {
    setState(() {
      _isButtonEnabled =
          _nameController.text.trim().isNotEmpty &&
          _capacityController.text.trim().isNotEmpty &&
          _dimensionsController.text.trim().isNotEmpty &&
          _locationController.text.trim().isNotEmpty &&
          _typeController.text.trim().isNotEmpty;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _capacityController.dispose();
    _dimensionsController.dispose();
    _locationController.dispose();
    _typeController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_isButtonEnabled) return;
    try {
      await FirebaseFirestore.instance.collection('pools').doc(widget.poolId).update({
        'PoolName': _nameController.text.trim(),
        'capacity': int.parse(_capacityController.text.trim()),
        'dimensions': _dimensionsController.text.trim(),
        'location': _locationController.text.trim(),
        'type': _typeController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Pool details updated successfully!")),
      );
      Navigator.pop(context, {
        'PoolName': _nameController.text.trim(),
        'capacity': int.parse(_capacityController.text.trim()),
        'dimensions': _dimensionsController.text.trim(),
        'location': _locationController.text.trim(),
        'type': _typeController.text.trim(),
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update pool details: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Pool"),
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: mainGradient),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Pool Name"),
            ),
            TextField(
              controller: _capacityController,
              decoration: InputDecoration(labelText: "Capacity"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _dimensionsController,
              decoration: InputDecoration(labelText: "Dimensions"),
            ),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(labelText: "Location"),
            ),
            TextField(
              controller: _typeController,
              decoration: InputDecoration(labelText: "Type"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isButtonEnabled ? _saveChanges : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              ),
              child: Text("Save Changes", style: TextStyle(color: buttonTextColor)),
            ),
          ],
        ),
      ),
    );
  }
}

//--------------------- ManageSensorsScreen ---------------------
class ManageSensorsScreen extends StatefulWidget {
  const ManageSensorsScreen({super.key});

  @override
  _ManageSensorsScreenState createState() => _ManageSensorsScreenState();
}

class _ManageSensorsScreenState extends State<ManageSensorsScreen> {
  String? selectedPoolId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Sensors"),
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: mainGradient),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // قائمة اختيار المسبح
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('pools')
                  .where('ownerId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                      child: Text("Please add a pool first before managing sensors.", style: TextStyle(color: textColor)));
                }

                var pools = snapshot.data!.docs;

                return DropdownButtonFormField<String>(
                  hint: Text("Select Pool", style: TextStyle(color: textColor)),
                  value: selectedPoolId,
                  items: pools.map((pool) {
                    return DropdownMenuItem(
                      value: pool.id,
                      child: Text(pool['PoolName'], style: TextStyle(color: textColor)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedPoolId = value;
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            // عرض الحساسات الخاصة بالمسبح المحدد
            selectedPoolId == null
                ? Center(child: Text("Select a pool to view sensors", style: TextStyle(color: textColor)))
                : Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('pools')
                          .doc(selectedPoolId)
                          .collection('sensors')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        }
                        var sensors = snapshot.data!.docs;

                        if (sensors.isEmpty) {
                          Future.microtask(() {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddSensorScreen(poolId: selectedPoolId!),
                              ),
                            );
                          });

                          return Center(child: Text("Redirecting to add sensor...", style: TextStyle(color: textColor)));
                        }

                        return ListView.builder(
                          itemCount: sensors.length,
                          itemBuilder: (context, index) {
                            var sensor = sensors[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                title: Text(sensor['sensorType'], style: TextStyle(color: textColor)),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    FirebaseFirestore.instance
                                        .collection('pools')
                                        .doc(selectedPoolId)
                                        .collection('sensors')
                                        .doc(sensor.id)
                                        .delete();
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
            const SizedBox(height: 10),
            // زر إضافة حساس جديد
            ElevatedButton(
              onPressed: selectedPoolId == null
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddSensorScreen(poolId: selectedPoolId!),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedPoolId == null ? Colors.grey : accentColor,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              ),
              child: Text("Add Sensor", style: TextStyle(color: buttonTextColor, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}


//--------------------- SensorCard ---------------------
class SensorCard extends StatelessWidget {
  final String sensorName;
  const SensorCard({super.key, required this.sensorName});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(sensorName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.blue),
              onPressed: () {}),
        ],
      ),
    );
  }
}
