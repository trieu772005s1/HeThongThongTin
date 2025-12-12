import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StaffManagementPage extends StatelessWidget {
  const StaffManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final usersRef = FirebaseFirestore.instance
        .collection('users')
        .orderBy('createdAt', descending: true);
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý nhân viên')),
      body: StreamBuilder<QuerySnapshot>(
        stream: usersRef.snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty)
            return const Center(child: Text('Chưa có user nào.'));
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final d = docs[i];
              final data = d.data() as Map<String, dynamic>;
              final role = data['role'] ?? 'staff';
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                child: ListTile(
                  title: Text(data['full_name'] ?? d.id),
                  subtitle: Text('Email: ${data['email'] ?? ''} · Role: $role'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) {
                      if (v == 'makeAdmin')
                        d.reference.update({'role': 'admin'});
                      if (v == 'makeStaff')
                        d.reference.update({'role': 'staff'});
                      if (v == 'delete') d.reference.delete();
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'makeAdmin',
                        child: Text('Đặt làm admin'),
                      ),
                      const PopupMenuItem(
                        value: 'makeStaff',
                        child: Text('Đặt làm staff'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Xóa user'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
