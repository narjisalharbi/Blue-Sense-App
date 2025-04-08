/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddSensorScreen extends StatefulWidget {
  final String poolId;

  AddSensorScreen({required this.poolId});

  @override
  _AddSensorScreenState createState() => _AddSensorScreenState();
}

class _AddSensorScreenState extends State<AddSensorScreen> {
  final TextEditingController sensorTypeController = TextEditingController();
  final TextEditingController sensorValueController = TextEditingController();
  bool isLoading = false; // 🔹 لإدارة حالة التحميل

  Future<void> addSensor() async {
    if (sensorTypeController.text.trim().isEmpty || sensorValueController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields.")),
      );
      return;
    }

    setState(() {
      isLoading = true; // 🔹 عرض مؤشر تحميل
    });

    try {
      await FirebaseFirestore.instance
          .collection('pools')
          .doc(widget.poolId)
          .collection('sensors')
          .add({
        'sensorType': sensorTypeController.text.trim(),
        'value': double.tryParse(sensorValueController.text.trim()) ?? 0.0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sensor added successfully!")),
      );

      Navigator.pop(context); // 🔹 الرجوع إلى شاشة إدارة المستشعرات بعد الإضافة
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error adding sensor: ${e.toString()}")),
      );
    }

    setState(() {
      isLoading = false; // 🔹 إخفاء مؤشر التحميل بعد انتهاء العملية
    });
  }

  @override
  void dispose() {
    // 🔹 تحرير موارد النصوص عند مغادرة الشاشة
    sensorTypeController.dispose();
    sensorValueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Sensor")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: sensorTypeController,
              decoration: InputDecoration(labelText: "Sensor Type"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: sensorValueController,
              decoration: InputDecoration(labelText: "Initial Value"),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator() // 🔹 عرض مؤشر تحميل أثناء الإضافة
                : ElevatedButton(
                    onPressed: addSensor,
                    child: Text("Add Sensor"),
                  ),
          ],
        ),
      ),
    );
  }
}
*/




/*
قبل حق نوره 



import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddSensorScreen extends StatefulWidget {
  final String poolId;

  const AddSensorScreen({super.key, required this.poolId});

  @override
  _AddSensorScreenState createState() => _AddSensorScreenState();
}

class _AddSensorScreenState extends State<AddSensorScreen> {
  List<String> sensorTypes = ['Temperature', 'pH'];
  List<String> selectedSensors = [];
  bool isLoading = false;

  Future<void> addSensor(String sensorType) async {
    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('pools')
          .doc(widget.poolId)
          .collection('sensors')
          .add({
        'sensorType': sensorType,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$sensorType sensor added successfully!")),
      );

      setState(() {
        selectedSensors.add(sensorType);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error adding sensor: ${e.toString()}")),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Sensor")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // عرض الحساسات المتاحة مع الأزرار
            Wrap(
              spacing: 10,
              children: sensorTypes.map((sensorType) {
                return Chip(
                  label: Text(sensorType),
                  avatar: Icon(Icons.add),
                  onDeleted: selectedSensors.contains(sensorType)
                      ? null
                      : () {
                          addSensor(sensorType);
                        },
                  deleteIcon: Icon(Icons.add),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () {
                      // يمكن تنفيذ عمل إضافي هنا لو أردت
                    },
                    child: Text("Finish Adding Sensors"),
                  ),
          ],
        ),
      ),
    );
  }
}
قبل حق نور ة
*/
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddSensorScreen extends StatefulWidget {
  final String poolId;

  AddSensorScreen({required this.poolId});

  @override
  _AddSensorScreenState createState() => _AddSensorScreenState();
}

class _AddSensorScreenState extends State<AddSensorScreen> {
  List<String> sensorTypes = ['pH Level', 'Temperature'];
  List<String> activeSensors = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadActiveSensors();
  }

  Future<void> _loadActiveSensors() async {
    try {
      QuerySnapshot sensorSnapshot = await FirebaseFirestore.instance
          .collection('pools')
          .doc(widget.poolId)
          .collection('sensors')
          .where('sensorStatus', isEqualTo: true)
          .get();

      List<String> sensors = sensorSnapshot.docs
          .map((doc) => doc['sensorType'] as String)
          .toList();

      setState(() {
        activeSensors = sensors;
      });
    } catch (e) {
      print("Error loading sensors: $e");
    }
  }

  Future<void> addSensor(String sensorType) async {
    setState(() {
      isLoading = true;
    });

    try {
      // التحقق من عدم تكرار نفس نوع الحساس
      QuerySnapshot existing = await FirebaseFirestore.instance
          .collection('pools')
          .doc(widget.poolId)
          .collection('sensors')
          .where('sensorType', isEqualTo: sensorType)
          .where('sensorStatus', isEqualTo: true)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$sensorType sensor is already added.")),
        );
        setState(() => isLoading = false);
        return;
      }

      DocumentReference docRef = await FirebaseFirestore.instance
          .collection('pools')
          .doc(widget.poolId)
          .collection('sensors')
          .add({
        'sensorStatus': true,
        'sensorType': sensorType,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await docRef.update({'sensorId': docRef.id});

      setState(() {
        activeSensors.add(sensorType);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$sensorType sensor added successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error adding sensor: ${e.toString()}")),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> removeSensor(String sensorType) async {
    setState(() {
      isLoading = true;
    });

    try {
      QuerySnapshot query = await FirebaseFirestore.instance
          .collection('pools')
          .doc(widget.poolId)
          .collection('sensors')
          .where('sensorType', isEqualTo: sensorType)
          .where('sensorStatus', isEqualTo: true)
          .get();

      for (var doc in query.docs) {
        await doc.reference.update({'sensorStatus': false});
      }

      setState(() {
        activeSensors.remove(sensorType);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$sensorType sensor removed successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error removing sensor: ${e.toString()}")),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add New Sensor",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade700, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.3,
                ),
                itemCount: sensorTypes.length,
                itemBuilder: (context, index) {
                  String sensorType = sensorTypes[index];
                  bool isActive = activeSensors.contains(sensorType);

                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 3,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.blue.shade400,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                            ),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12),
                          width: double.infinity,
                          child: Center(
                            child: Text(
                              sensorType,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: GestureDetector(
                              onTap: isActive
                                  ? () => removeSensor(sensorType)
                                  : () => addSensor(sensorType),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isActive ? Colors.red : Colors.blue,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                padding: EdgeInsets.all(10),
                                child: Icon(
                                  isActive ? Icons.remove : Icons.add,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            if (isLoading)
              const Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}

/*
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddSensorScreen extends StatefulWidget {
  final String poolId;

  AddSensorScreen({required this.poolId});

  @override
  _AddSensorScreenState createState() => _AddSensorScreenState();
}

class _AddSensorScreenState extends State<AddSensorScreen> {
  // أنواع الحساسات
  List<String> sensorTypes = ['pH Level', 'Temperature'];

  // قائمة بالحساسات المفعّلة حاليًا
  List<String> activeSensors = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadActiveSensors();
  }

  /// تحميل الحساسات النشطة من Firestore (حيث sensorStatus = true)
  Future<void> _loadActiveSensors() async {
    try {
      QuerySnapshot sensorSnapshot = await FirebaseFirestore.instance
          .collection('pools')
          .doc(widget.poolId)
          .collection('sensors')
          .where('sensorStatus', isEqualTo: true)
          .get();

      // جمع أسماء أنواع الحساسات في قائمة
      List<String> sensors = sensorSnapshot.docs
          .map((doc) => doc['sensorType'] as String)
          .toList();

      setState(() {
        activeSensors = sensors;
      });
    } catch (e) {
      print("Error loading sensors: $e");
    }
  }

  /// إضافة حساس جديد
  Future<void> addSensor(String sensorType) async {
    // إذا كان الحساس مضافًا مسبقًا في القائمة، لا تضف مرة أخرى
    if (activeSensors.contains(sensorType)) return;

    setState(() {
      isLoading = true;
    });

    try {
      // إنشاء مستند جديد بمعرف تلقائي
      DocumentReference docRef = await FirebaseFirestore.instance
          .collection('pools')
          .doc(widget.poolId)
          .collection('sensors')
          .add({
        'sensorStatus': true,        // حالة الحساس (مفعّل)
        'sensorType': sensorType,    // نوع الحساس
        'createdAt': FieldValue.serverTimestamp(),
      });

      // بعد الإنشاء، احفظ المعرّف في الحقل sensorId
      await docRef.update({'sensorId': docRef.id});

      // أضف نوع الحساس لقائمة الحساسات المفعّلة
      setState(() {
        activeSensors.add(sensorType);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$sensorType sensor added successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error adding sensor: ${e.toString()}")),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  /// إلغاء تفعيل حساس (بدلاً من حذفه)
  Future<void> removeSensor(String sensorType) async {
    setState(() {
      isLoading = true;
    });

    try {
      // البحث عن المستندات النشطة الخاصة بهذا الحساس
      QuerySnapshot query = await FirebaseFirestore.instance
          .collection('pools')
          .doc(widget.poolId)
          .collection('sensors')
          .where('sensorType', isEqualTo: sensorType)
          .where('sensorStatus', isEqualTo: true)
          .get();

      // تحديث حالة الحساس إلى false
      for (var doc in query.docs) {
        await doc.reference.update({'sensorStatus': false});
      }

      setState(() {
        activeSensors.remove(sensorType);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$sensorType sensor removed successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error removing sensor: ${e.toString()}")),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add New Sensor",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade700, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.3,
                ),
                itemCount: sensorTypes.length,
                itemBuilder: (context, index) {
                  String sensorType = sensorTypes[index];
                  bool isActive = activeSensors.contains(sensorType);

                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 3,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // عنوان الحساس في الأعلى
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.blue.shade400,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                            ),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12),
                          width: double.infinity,
                          child: Center(
                            child: Text(
                              sensorType,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        // زر الإضافة أو الحذف
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: GestureDetector(
                              onTap: isActive
                                  ? () => removeSensor(sensorType)
                                  : () => addSensor(sensorType),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isActive ? Colors.red : Colors.blue,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                padding: EdgeInsets.all(10),
                                child: Icon(
                                  isActive ? Icons.remove : Icons.add,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () {
                      // يمكنك تنفيذ إجراء معين عند الانتهاء
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    ),
                    child: Text("Finish Adding Sensors"),
                  ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
قبل لا اعدل ع فاليو 

*/



/*

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddSensorScreen extends StatefulWidget {
  final String poolId;

  AddSensorScreen({required this.poolId});

  @override
  _AddSensorScreenState createState() => _AddSensorScreenState();
}

class _AddSensorScreenState extends State<AddSensorScreen> {
  List<String> sensorTypes = ['Temperature', 'pH'];
  List<String> selectedSensors = [];
  bool isLoading = false;

  Future<void> addSensor(String sensorType) async {
    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('pools')
          .doc(widget.poolId)
          .collection('sensors')
          .add({
        'sensorType': sensorType,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$sensorType sensor added successfully!")),
      );

      setState(() {
        selectedSensors.add(sensorType);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error adding sensor: ${e.toString()}")),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Sensor")),
      body: Container(
        // تدرج لوني خلفية
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF87CDF2),
              Color.fromARGB(255, 55, 149, 200),
              Color(0xCC49A3D1),
              Color(0xE587C0DD),
              Color(0xFFDCE9F0),
              Color(0xFFD0E1EB),
              Color(0xFFDFF4FF),
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // عرض الحساسات المتاحة مع الأزرار
              Wrap(
                spacing: 10,
                children: sensorTypes.map((sensorType) {
                  return Chip(
                    label: Text(sensorType),
                    avatar: Icon(Icons.add),
                    onDeleted: selectedSensors.contains(sensorType)
                        ? null
                        : () {
                            addSensor(sensorType);
                          },
                    deleteIcon: Icon(Icons.add),
                    backgroundColor: const Color.fromARGB(255, 212, 241, 249), // تخصيص لون الخلفية
                    labelStyle: TextStyle(color: const Color.fromARGB(255, 5, 5, 5)), // تخصيص اللون
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(204, 127, 171, 194), // تخصيص لون الزر
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                      onPressed: () {
                        // يمكن تنفيذ عمل إضافي هنا لو أردت
                      },
                      child: Text(
                        "Finish Adding Sensors",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
*/