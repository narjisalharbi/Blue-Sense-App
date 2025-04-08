/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:register_app2/admin_notifications_lite_screen.dart';

const Color primaryColor = Color(0xFF035079);
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

class PoolsOverviewPage extends StatefulWidget {
  const PoolsOverviewPage({Key? key}) : super(key: key);

  @override
  _PoolsOverviewPageState createState() => _PoolsOverviewPageState();
}

class _PoolsOverviewPageState extends State<PoolsOverviewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Pools"),
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminNotificationsLiteScreen()),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: mainGradient),
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('pools').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text("No pools found.", style: TextStyle(color: textColor)),
              );
            }

            var allPools = snapshot.data!.docs;

            return FutureBuilder<List<QueryDocumentSnapshot>>(
              future: _filterValidPools(allPools),
              builder: (context, futureSnapshot) {
                if (!futureSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var validPools = futureSnapshot.data!;

                if (validPools.isEmpty) {
                  return Center(
                    child: Text("No valid pools found.", style: TextStyle(color: textColor)),
                  );
                }

                return ListView.builder(
                  itemCount: validPools.length,
                  itemBuilder: (context, index) {
                    var pool = validPools[index].data() as Map<String, dynamic>;
                    String poolName = pool['PoolName'] ?? "No Name";
                    String location = pool['location'] ?? "Unknown";
                    String type = pool['type'] ?? "Unknown";
                    String capacity = pool['capacity']?.toString() ?? "Unknown";
                    String dimensions = pool['dimensions'] ?? "Unknown";
                    String ownerId = pool['ownerId'] ?? '';

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(poolName, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Location: $location\nType: $type\nCapacity: $capacity\nDimensions: $dimensions",
                              style: TextStyle(color: textColor),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.block, size: 18),
                              label: const Text("حظر الـ Owner"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () => _blockOwner(ownerId),
                            )
                          ],
                        ),
                        trailing: Icon(Icons.arrow_forward_ios, color: primaryColor),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<List<QueryDocumentSnapshot>> _filterValidPools(List<QueryDocumentSnapshot> allPools) async {
    List<QueryDocumentSnapshot> validPools = [];

    for (var poolDoc in allPools) {
      var poolData = poolDoc.data() as Map<String, dynamic>;
      String ownerId = poolData['ownerId'] ?? '';

      if (ownerId.isEmpty) continue;

      bool exists = await _ownerExists(ownerId);
      if (exists) validPools.add(poolDoc);
    }

    return validPools;
  }

  Future<bool> _ownerExists(String ownerId) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(ownerId).get();
    return userDoc.exists;
  }

  Future<void> _blockOwner(String ownerId) async {
    try {
      final userSnapshot = await FirebaseFirestore.instance.collection('users').doc(ownerId).get();
      if (!userSnapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("🚫 المستخدم غير موجود")));
        return;
      }

      final email = userSnapshot['email'] ?? '';

      // 🔐 حظر المستخدم
      await FirebaseFirestore.instance.collection('blocked_users').doc(ownerId).set({
        'ownerEmail': email,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 📧 إرسال رابط إعادة تعيين كلمة المرور
      String resetMessage = "";
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        resetMessage = "📧 تم إرسال رابط إعادة تعيين كلمة المرور إلى $email";
      } catch (e) {
        resetMessage = "❌ فشل في إرسال الرابط: $e";
      }

      // 🔔 إشعار الأدمن
      await FirebaseFirestore.instance.collection('admin_notifications').add({
        'ownerEmail': email,
        'timestamp': FieldValue.serverTimestamp(),
        'message': '🚨 تم حظر المستخدم بواسطة الأدمن',
        'resetLink': resetMessage,
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("✅ تم حظر $email")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ فشل الحظر: $e")));
    }
  }
}
*/






import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

const Color primaryColor = Color(0xFF035079);
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

class PoolsOverviewPage extends StatefulWidget {
  const PoolsOverviewPage({Key? key}) : super(key: key);

  @override
  _PoolsOverviewPageState createState() => _PoolsOverviewPageState();
}

class _PoolsOverviewPageState extends State<PoolsOverviewPage> {
  Future<bool> _ownerExists(String ownerId) async {
    if (ownerId.isEmpty) return false;
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(ownerId).get();
    return userDoc.exists;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Pools"),
        backgroundColor: primaryColor,
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text("Logout", style: TextStyle(color: Colors.white)),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('blocked_users').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const SizedBox.shrink();
              return Card(
                color: Colors.red.shade100,
                margin: const EdgeInsets.all(8),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: snapshot.data!.docs.map((doc) {
                      final blockedUser = doc.data() as Map<String, dynamic>;
                      final email = blockedUser['ownerEmail'] ?? 'No Email';
                      return ListTile(
                        title: Text("🚨 Blocked User: $email"),
                        subtitle: const Text("Needs to reset password"),
                        trailing: ElevatedButton.icon(
                          icon: const Icon(Icons.email),
                          label: const Text("Send link"),
                          onPressed: () async {
                            try {
                              await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("✅ A password reset link has been sent to $email")),
                              );

                              final adminDocs = await FirebaseFirestore.instance
                                  .collection('admin_notifications')
                                  .where('ownerEmail', isEqualTo: email)
                                  .get();

                              for (var doc in adminDocs.docs) {
                                await doc.reference.update({
                                  'resetLink': '📧 A password reset link has been sent to $email',
                                });
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("❌ Failed to send link: $e")),
                              );
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('pools').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("🚫 No pools found."));
                }

                var allPools = snapshot.data!.docs;

                return FutureBuilder<List<QueryDocumentSnapshot>>(
                  future: () async {
                    List<QueryDocumentSnapshot> validPools = [];
                    for (var poolDoc in allPools) {
                      var poolData = poolDoc.data() as Map<String, dynamic>;
                      String ownerId = poolData['ownerId'] ?? '';
                      bool ownerExists = await _ownerExists(ownerId);
                      if (ownerExists) validPools.add(poolDoc);
                    }
                    return validPools;
                  }(),
                  builder: (context, futureSnapshot) {
                    if (!futureSnapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    var validPools = futureSnapshot.data!;

                    if (validPools.isEmpty) {
                      return const Center(child: Text("🚫 No valid pools found."));
                    }

                    return ListView.builder(
                      itemCount: validPools.length,
                      itemBuilder: (context, index) {
                        var poolData = validPools[index].data() as Map<String, dynamic>;

                        String poolId = validPools[index].id;
                        String poolName = poolData['PoolName'] ?? "No Name";
                        String location = poolData['location'] ?? "Unknown";
                        String type = poolData['type'] ?? "N/A";
                        String capacity = poolData['capacity']?.toString() ?? "N/A";
                        String dimensions = poolData['dimensions']?.toString() ?? "N/A";
                        String ownerEmail = poolData['ownerEmail'] ?? "Unknown";

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: ExpansionTile(
                            title: Text(poolName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(
                              "📍 Location: $location\n🛠 Type: $type\n📏 Dimensions: $dimensions\n🔢 Capacity: $capacity\n👤 Owner: $ownerEmail",
                              style: const TextStyle(fontSize: 14),
                            ),
                            children: [
                              StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('pools')
                                    .doc(poolId)
                                    .collection('sensors')
                                    .snapshots(),
                                builder: (context, sensorSnapshot) {
                                  if (!sensorSnapshot.hasData) {
                                    return const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Center(child: CircularProgressIndicator()),
                                    );
                                  }

                                  var sensors = sensorSnapshot.data!.docs;

                                  if (sensors.isEmpty) {
                                    return const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Center(child: Text("No sensors available.")),
                                    );
                                  }

                                  return Column(
                                    children: sensors.map((sensorDoc) {
                                      var sensorData = sensorDoc.data() as Map<String, dynamic>;
                                      String sensorType = sensorData['sensorType'] ?? "Unknown Sensor";

                                      return ListTile(
                                        leading: const Icon(Icons.sensors, color: Colors.blue),
                                        title: Text(sensorType),
                                      );
                                    }).toList(),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


/*
000000000000000000000000000000000000
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PoolsOverviewPage extends StatefulWidget {
  const PoolsOverviewPage({Key? key}) : super(key: key);

  @override
  _PoolsOverviewPageState createState() => _PoolsOverviewPageState();
}

class _PoolsOverviewPageState extends State<PoolsOverviewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Pools"),
        backgroundColor: const Color(0xFF035079),
      ),
      body: Column(
        children: [
          // 🛑 إشعار إذا كان هناك مستخدمون محظورون
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('blocked_users').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const SizedBox.shrink();

              return Card(
                color: Colors.red.shade100,
                margin: const EdgeInsets.all(8),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: snapshot.data!.docs.map((doc) {
                      final blockedUser = doc.data() as Map<String, dynamic>;
                      final email = blockedUser['ownerEmail'] ?? 'No Email';

                      return ListTile(
                        title: Text("🚨 المستخدم المحظور: $email"),
                        subtitle: const Text("يحتاج إلى إعادة تعيين كلمة المرور"),
                        trailing: ElevatedButton.icon(
                          icon: const Icon(Icons.email),
                          label: const Text("إرسال رابط"),
                          onPressed: () async {
                            try {
                              await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("✅ تم إرسال رابط إعادة تعيين كلمة المرور إلى $email")),
                              );

                              // تحديث admin_notifications بعد إرسال الرابط
                              final adminDocs = await FirebaseFirestore.instance
                                  .collection('admin_notifications')
                                  .where('ownerEmail', isEqualTo: email)
                                  .get();

                              for (var doc in adminDocs.docs) {
                                await doc.reference.update({
                                  'resetLink': '📧 تم إرسال رابط إعادة تعيين كلمة المرور إلى $email',
                                });
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("❌ فشل في إرسال الرابط: $e")),
                              );
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),

          // 🔹 عرض قائمة جميع المسابح
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('pools').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No pools found."));
                }

                var allPools = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: allPools.length,
                  itemBuilder: (context, index) {
                    var poolDoc = allPools[index];
                    var pool = poolDoc.data() as Map<String, dynamic>;
                    String poolName = pool['PoolName'] ?? "No Name";
                    String location = pool['location'] ?? "Unknown";
                    String poolId = poolDoc.id; // معرف المسبح

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(poolName),
                        subtitle: Text("Location: $location"),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          // ✅ التنقل إلى صفحة تفاصيل المسبح وعرض الحساسات
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PoolDetailsPage(poolId: poolId, poolName: poolName),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}



class PoolDetailsPage extends StatelessWidget {
  final String poolId;
  final String poolName;

  const PoolDetailsPage({Key? key, required this.poolId, required this.poolName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Details of $poolName")),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('pools').doc(poolId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          var poolData = snapshot.data!.data() as Map<String, dynamic>?;

          if (poolData == null) {
            return const Center(child: Text("No data available for this pool."));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("🏊 اسم المسبح: ${poolData['PoolName'] ?? 'غير متوفر'}",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text("📍 الموقع: ${poolData['location'] ?? 'غير متوفر'}",
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                Text("📏 الأبعاد: ${poolData['dimensions'] ?? 'غير متوفر'}",
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                Text("🛠️ النوع: ${poolData['type'] ?? 'غير متوفر'}",
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                Text("🛑 السعة: ${poolData['capacity']?.toString() ?? 'غير متوفر'}",
                    style: const TextStyle(fontSize: 16)),

                const Divider(),

                // 🔥 عرض الحساسات المرتبطة بهذا المسبح
                const Text("📡 الحساسات:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),

                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('pools')
                      .doc(poolId)
                      .collection('sensors') // جلب جميع الحساسات الخاصة بهذا المسبح
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("No sensors found."));
                    }

                    var sensors = snapshot.data!.docs;

                    return Column(
                      children: sensors.map((doc) {
                        var sensor = doc.data() as Map<String, dynamic>;
                        String sensorType = sensor['sensorType'] ?? "Unknown Sensor";
                        String unit = sensor['unit'] ?? "";

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(sensorType, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text("القيمة: $value $unit"),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
0000000000000000000000000

*/


/*
raefffff

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PoolsOverviewPage extends StatefulWidget {
  const PoolsOverviewPage({Key? key}) : super(key: key);

  @override
  _PoolsOverviewPageState createState() => _PoolsOverviewPageState();
}

class _PoolsOverviewPageState extends State<PoolsOverviewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Pools"),
        backgroundColor: const Color(0xFF035079),
      ),
      body: Column(
        children: [
          // 🛑 إشعار إذا كان هناك مستخدمون محظورون
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('blocked_users').snapshots(),
            builder: (context, snapshot) {
              
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const SizedBox.shrink();

              return Card(
                color: Colors.red.shade100,
                margin: const EdgeInsets.all(8),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: snapshot.data!.docs.map((doc) {
                      final blockedUser = doc.data() as Map<String, dynamic>;
                      final email = blockedUser['ownerEmail'] ?? 'No Email';

                      return ListTile(
                        title: Text("🚨 المستخدم المحظور: $email"),
                        subtitle: const Text("يحتاج إلى إعادة تعيين كلمة المرور"),
                        trailing: ElevatedButton.icon(
                          icon: const Icon(Icons.email),
                          label: const Text("إرسال رابط"),
                          onPressed: () async {
                            try {
                              await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("✅ تم إرسال رابط إعادة تعيين كلمة المرور إلى $email")),
                              );

                              // تحديث admin_notifications بعد إرسال الرابط
                              final adminDocs = await FirebaseFirestore.instance
                                  .collection('admin_notifications')
                                  .where('ownerEmail', isEqualTo: email)
                                  .get();

                              for (var doc in adminDocs.docs) {
                                await doc.reference.update({
                                  'resetLink': '📧 تم إرسال رابط إعادة تعيين كلمة المرور إلى $email',
                                });
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("❌ فشل في إرسال الرابط: $e")),
                              );
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),

          // 🔹 عرض قائمة جميع المسبح
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('pools').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No pools found."));
                }

                var allPools = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: allPools.length,
                  itemBuilder: (context, index) {
                    var pool = allPools[index].data() as Map<String, dynamic>;
                    String poolName = pool['PoolName'] ?? "No Name";
                    String location = pool['location'] ?? "Unknown";

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(poolName),
                        subtitle: Text("Location: $location"),
                        trailing: const Icon(Icons.arrow_forward_ios),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


رائفففففففففف*/
/*
kkkkkkkkkkkkkkkkkkkkkk
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_notifications_lite_screen.dart'; // تأكد من استيراد الصفحة بشكل صحيح

class PoolsOverviewPage extends StatefulWidget {
  const PoolsOverviewPage({Key? key}) : super(key: key);

  @override
  _PoolsOverviewPageState createState() => _PoolsOverviewPageState();
}

class _PoolsOverviewPageState extends State<PoolsOverviewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Pools"),
        backgroundColor: const Color(0xFF035079),
        actions: [
          // ✅ زر الإشعارات في AppBar
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminNotificationsLiteScreen()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('pools').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No pools found."));
          }

          var allPools = snapshot.data!.docs;

          return ListView.builder(
            itemCount: allPools.length,
            itemBuilder: (context, index) {
              var pool = allPools[index].data() as Map<String, dynamic>;
              String poolName = pool['PoolName'] ?? "No Name";
              String location = pool['location'] ?? "Unknown";

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(poolName),
                  subtitle: Text("Location: $location"),
                  trailing: const Icon(Icons.arrow_forward_ios),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
*/