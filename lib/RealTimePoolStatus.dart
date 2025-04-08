import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:register_app2/ChangePasswordPage.dart';
import 'package:register_app2/login_page.dart';
import 'package:register_app2/ProfileHeader.dart';
import 'package:register_app2/menu.dart';
import 'AppTheme .dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class RealTimePoolStatus extends StatefulWidget {
  const RealTimePoolStatus({super.key});

  @override
  State<RealTimePoolStatus> createState() => _RealTimePoolStatusState();
}

class _RealTimePoolStatusState extends State<RealTimePoolStatus> with RouteAware {
  String? selectedPoolId;
  String? selectedPoolName;
  List<Map<String, dynamic>> userPools = [];

  @override
  void initState() {
    super.initState();
    _loadUserPools();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    _loadUserPools();
  }

  Future<void> _loadUserPools() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final poolSnapshot = await FirebaseFirestore.instance
        .collection('pools')
        .where('ownerId', isEqualTo: userId)
        .get();

    if (mounted) {
      setState(() {
        userPools = poolSnapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'name': doc['PoolName'],
          };
        }).toList();

        if (userPools.isNotEmpty) {
          selectedPoolId = userPools.first['id'];
          selectedPoolName = userPools.first['name'];
        } else {
          selectedPoolId = null;
          selectedPoolName = null;
        }
      });
    }
  }

  void _handleMenuSelection(String value) async {
    if (value == 'My Home') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const Menu()));
    } else if (value == 'My Account') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileForm()));
    } else if (value == 'Change Password') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordPage()));
    } else if (value == 'Logout') {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Real-Time Pool Status"),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: _handleMenuSelection,
              itemBuilder: (BuildContext context) {
                return ['My Home', 'My Account', 'Change Password', 'Logout']
                    .map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.mainGradient),
        child: Column(
          children: [
            if (userPools.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: selectedPoolId,
                  onChanged: (newValue) {
                    setState(() {
                      selectedPoolId = newValue;
                      selectedPoolName = userPools
                          .firstWhere((pool) => pool['id'] == newValue)['name'];
                    });
                  },
                  items: userPools.map((pool) {
                    return DropdownMenuItem<String>(
                      value: pool['id'],
                      child: Text(pool['name']),
                    );
                  }).toList(),
                ),
              ),
            Expanded(
              child: selectedPoolId == null
                  ? Center(
                      child: userPools.isEmpty
                          ? const Text("No pools found.")
                          : const CircularProgressIndicator(),
                    )
                  : StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('pools')
                          .doc(selectedPoolId)
                          .collection('sensors')
                          .where('sensorStatus', isEqualTo: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final sensors = snapshot.data!.docs;

                        if (sensors.isEmpty) {
                          return const Center(child: Text('No sensors found.'));
                        }

                        return GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: sensors.length,
                          itemBuilder: (context, index) {
                            final sensor = sensors[index];
                            final String sensorType = sensor['sensorType'];
                            final String sensorId = sensor.id;

                            return FutureBuilder<QuerySnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection('pollution_data')
                                  .where('sensorId', isEqualTo: sensorId)
                                  .orderBy('STTimestamp', descending: true)
                                  .limit(1)
                                  .get(),
                              builder: (context, pollutionSnapshot) {
                                String value = '—';
                                String status = 'Normal';

                                if (pollutionSnapshot.hasData &&
                                    pollutionSnapshot.data!.docs.isNotEmpty) {
                                  final pollutionDoc = pollutionSnapshot.data!.docs.first;
                                  value = pollutionDoc['value'].toString();

                                  final double? doubleValue = double.tryParse(value);
                                  status = _getStatus(sensorType, doubleValue);
                                }

                                final icon = _getIcon(sensorType);

                                return Column(
                                  children: [
                                    if (status == 'Not Normal')
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 8.0),
                                        child: Text(
                                          '⚠️ Warning: $sensorType sensor value is abnormal!',
                                          style: TextStyle(
                                            color: Colors.red.shade700,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    _buildStatusCard(
                                      title: sensorType,
                                      value: value,
                                      status: status,
                                      icon: icon,
                                    ),
                                  ],
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
      ),
    );
  }

  String _getStatus(String type, double? value) {
    if (value == null) return 'Normal';
    switch (type) {
      case 'Temperature':
        return (value >= 26 && value <= 30) ? 'Normal' : 'Not Normal';
      case 'pH Level':
        return (value >= 7.0 && value <= 7.8) ? 'Normal' : 'Not Normal';
      default:
        return 'Unknown';
    }
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'Temperature':
        return Icons.thermostat;
      case 'pH Level':
        return Icons.science;
      default:
        return Icons.sensors;
    }
  }

  Widget _buildStatusCard({
    required String title,
    required String value,
    required String status,
    required IconData icon,
  }) {
    final isNormal = status == 'Normal';
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isNormal ? Colors.white.withOpacity(0.9) : Colors.red.shade100,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 36),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                  fontSize: 20,
                  color: AppTheme.textColor,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              status,
              style: TextStyle(
                  fontSize: 14,
                  color: isNormal ? Colors.grey[700] : Colors.red.shade800),
            ),
          ],
        ),
      ),
    );
  }
}


/*import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:register_app2/ChangePasswordPage.dart';
import 'package:register_app2/login_page.dart';
import 'package:register_app2/ProfileHeader.dart';
import 'package:register_app2/menu.dart';
import 'AppTheme .dart';

class RealTimePoolStatus extends StatefulWidget {
  const RealTimePoolStatus({super.key});

  @override
  State<RealTimePoolStatus> createState() => _RealTimePoolStatusState();
}

class _RealTimePoolStatusState extends State<RealTimePoolStatus> {
  String? selectedPoolId;
  String? selectedPoolName;

  @override
  void initState() {
    super.initState();
    _loadFirstPool();
  }

  Future<void> _loadFirstPool() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final poolSnapshot = await FirebaseFirestore.instance
        .collection('pools')
        .where('ownerId', isEqualTo: userId)
        .limit(1)
        .get();

    if (poolSnapshot.docs.isNotEmpty) {
      setState(() {
        selectedPoolId = poolSnapshot.docs.first.id;
        selectedPoolName = poolSnapshot.docs.first['PoolName'];
      });
    } else {
      setState(() {
        selectedPoolId = null;
        selectedPoolName = null;
      });
    }
  }

  void _handleMenuSelection(String value) async {
    if (value == 'My Home') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const Menu()));
    } else if (value == 'My Account') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileForm()));
    } else if (value == 'Change Password') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordPage()));
    } else if (value == 'Logout') {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Real-Time Pool Status"),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: _handleMenuSelection,
              itemBuilder: (BuildContext context) {
                return ['My Home', 'My Account', 'Change Password', 'Logout']
                    .map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.mainGradient),
        child: (selectedPoolId == null && selectedPoolName == null)
            ? const Center(child: CircularProgressIndicator())
            : StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('pools')
                    .doc(selectedPoolId)
                    .collection('sensors')
                    .where('sensorStatus', isEqualTo: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final sensors = snapshot.data!.docs;

                  if (sensors.isEmpty) {
                    return const Center(child: Text('No sensors found.'));
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: sensors.length,
                    itemBuilder: (context, index) {
                      final sensor = sensors[index];
                      final String sensorType = sensor['sensorType'];
                      final String sensorId = sensor.id;

                      return FutureBuilder<QuerySnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('pollution_data')
                            .where('sensorId', isEqualTo: sensorId)
                            .orderBy('STTimestamp', descending: true)
                            .limit(1)
                            .get(),
                        builder: (context, pollutionSnapshot) {
                          String value = '—';
                          String status = 'Normal';

                          if (pollutionSnapshot.hasData &&
                              pollutionSnapshot.data!.docs.isNotEmpty) {
                            final pollutionDoc = pollutionSnapshot.data!.docs.first;
                            value = pollutionDoc['value'].toString();

                            final double? doubleValue = double.tryParse(value);
                            status = _getStatus(sensorType, doubleValue);
                          }

                          final icon = _getIcon(sensorType);

                          return Column(
                            children: [
                              if (status == 'Not Normal')
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Text(
                                    '⚠️ Warning: $sensorType sensor value is abnormal!',
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              _buildStatusCard(
                                title: sensorType,
                                value: value,
                                status: status,
                                icon: icon,
                              ),
                            ],
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

  String _getStatus(String type, double? value) {
    if (value == null) return 'Normal';
    switch (type) {
      case 'Temperature':
        return (value >= 26 && value <= 30) ? 'Normal' : 'Not Normal';
      case 'pH Level':
        return (value >= 7.0 && value <= 7.8) ? 'Normal' : 'Not Normal';
      default:
        return 'Unknown';
    }
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'Temperature':
        return Icons.thermostat;
      case 'pH Level':
        return Icons.science;
      default:
        return Icons.sensors;
    }
  }

  Widget _buildStatusCard({
    required String title,
    required String value,
    required String status,
    required IconData icon,
  }) {
    final isNormal = status == 'Normal';
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isNormal ? Colors.white.withOpacity(0.9) : Colors.red.shade100,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 36),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                color: AppTheme.textColor,
                fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              status,
              style: TextStyle(
                fontSize: 14,
                color: isNormal ? Colors.grey[700] : Colors.red.shade800),
            ),
          ],
        ),
      ),
    );
  }
}
قبل م احط عرض المسابح في في اول صفحه
*/

/*import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:register_app2/login_page.dart';
import 'package:register_app2/ProfileHeader.dart';
import 'AppTheme .dart';

class RealTimePoolStatus extends StatefulWidget {
  const RealTimePoolStatus({super.key});

  @override
  State<RealTimePoolStatus> createState() => _RealTimePoolStatusState();
}

class _RealTimePoolStatusState extends State<RealTimePoolStatus> {
  String? selectedPoolId;
  String? selectedPoolName;

  @override
  void initState() {
    super.initState();
    _loadFirstPool();
  }

  Future<void> _loadFirstPool() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final poolSnapshot = await FirebaseFirestore.instance
        .collection('pools')
        .where('ownerId', isEqualTo: userId)
        .limit(1)
        .get();

    if (poolSnapshot.docs.isNotEmpty) {
      setState(() {
        selectedPoolId = poolSnapshot.docs.first.id;
        selectedPoolName = poolSnapshot.docs.first['PoolName'];
      });
    }
  }

  void _handleMenuSelection(String value) async {
    if (value == 'My Account') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileForm()));
    } else if (value == 'My Pools') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const RealTimePoolStatus()));
    } else if (value == 'Logout') {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Real-Time Pool Status"),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: _handleMenuSelection,
            itemBuilder: (BuildContext context) {
              return ['My Account', 'My Pools', 'Logout'].map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.mainGradient),
        child: selectedPoolId == null
            ? const Center(child: Text('No pool found. Please add a pool.'))
            : StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('pools')
                    .doc(selectedPoolId)
                    .collection('sensors')
                    .where('sensorStatus', isEqualTo: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final sensors = snapshot.data!.docs;

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: sensors.length,
                    itemBuilder: (context, index) {
                      final sensor = sensors[index];
                      final String sensorType = sensor['sensorType'];

                      return FutureBuilder<QuerySnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('pollution_data')
                            .where('poolId', isEqualTo: selectedPoolId)
                            .where('sensorType', isEqualTo: sensorType)
                            .orderBy('timestamp', descending: true)
                            .limit(1)
                            .get(),
                        builder: (context, pollutionSnapshot) {
                          String value = '—';
                          String status = 'Normal';

                          if (pollutionSnapshot.hasData &&
                              pollutionSnapshot.data!.docs.isNotEmpty) {
                            final pollutionDoc = pollutionSnapshot.data!.docs.first;
                            value = pollutionDoc['value'].toString();

                            final double? doubleValue = double.tryParse(value);
                            status = _getStatus(sensorType, doubleValue);
                          }

                          final icon = _getIcon(sensorType);

                          return _buildStatusCard(
                            title: sensorType,
                            value: value,
                            status: status,
                            icon: icon,
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

  String _getStatus(String type, double? value) {
    if (value == null) return 'Normal';
    switch (type) {
      case 'Temperature':
        return (value >= 26 && value <= 30) ? 'Normal' : 'Not Normal';
      case 'pH Level':
        return (value >= 7.0 && value <= 7.8) ? 'Normal' : 'Not Normal';
      default:
        return 'Unknown';
    }
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'Temperature':
        return Icons.thermostat;
      case 'pH Level':
        return Icons.science;
      default:
        return Icons.sensors;
    }
  }

  Widget _buildStatusCard({
    required String title,
    required String value,
    required String status,
    required IconData icon,
  }) {
    final isNormal = status == 'Normal';
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isNormal ? Colors.white.withOpacity(0.9) : Colors.red.shade100,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 36),
            const SizedBox(height: 8),
            Text(title,
                style: TextStyle(
                    fontSize: 16, color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontSize: 20, color: AppTheme.textColor, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(status,
                style: TextStyle(
                    fontSize: 14,
                    color: isNormal ? Colors.grey[700] : Colors.red.shade800)),
          ],
        ),
      ),
    );
  }
}
*/
