///حذف المسابح مع الحساسات ايضا////

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DeleteConfirmation extends StatelessWidget {
  final String poolId;

  const DeleteConfirmation({super.key, required this.poolId});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFFDFF4FF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text(
        "Confirm Deletion",
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF035079)),
      ),
      content: const Text(
        "Are you sure you want to delete this pool?",
        style: TextStyle(fontSize: 18, color: Colors.black87),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            "Cancel",
            style: TextStyle(color: Color(0xFF035079), fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            final poolRef = FirebaseFirestore.instance.collection('pools').doc(poolId);
            final sensorsRef = poolRef.collection('sensors');

            // حذف الحساسات أولاً
            final sensorsSnapshot = await sensorsRef.get();
            for (var doc in sensorsSnapshot.docs) {
              await doc.reference.delete();
            }

            // حذف المسبح نفسه
            await poolRef.delete();

            // عرض رسالة نجاح
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Pool deleted successfully"),
                backgroundColor: Colors.green,
              ),
            );

            // الرجوع لصفحتين: إغلاق الديالوج ثم الرجوع لصفحة الخيارات
            Navigator.of(context).pop(); // إغلاق الـ dialog
            Navigator.of(context).pop(); // الرجوع من PoolOptionsScreen
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF035079),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              "Delete",
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}

/*
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DeleteConfirmation extends StatelessWidget {
  final String poolId;

  const DeleteConfirmation({super.key, required this.poolId});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFFDFF4FF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text(
        "Confirm Deletion",
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF035079)),
      ),
      content: const Text(
        "Are you sure you want to delete this pool?",
        style: TextStyle(fontSize: 18, color: Colors.black87),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            "Cancel",
            style: TextStyle(color: Color(0xFF035079), fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            await FirebaseFirestore.instance.collection('pools').doc(poolId).delete();
            // ignore: use_build_context_synchronously
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF035079),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              "Delete",
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}*/