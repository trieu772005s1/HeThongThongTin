// lib/pages/home/staff/staff_management_page.dart
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
      backgroundColor: const Color(0xFFF3F8FF),
      appBar: AppBar(title: const Text('Quản lý nhân viên'), centerTitle: true),
      body: StreamBuilder<QuerySnapshot>(
        stream: usersRef.snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('Chưa có nhân viên nào.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final d = docs[i];
              final data = d.data() as Map<String, dynamic>;
              final role = (data['role'] ?? 'staff').toString();

              final isAdmin = role == 'admin';

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  leading: CircleAvatar(
                    radius: 22,
                    backgroundColor: isAdmin
                        ? Colors.redAccent.withOpacity(0.15)
                        : Colors.indigo.withOpacity(0.15),
                    child: Icon(
                      isAdmin ? Icons.security : Icons.person,
                      color: isAdmin ? Colors.redAccent : Colors.indigo,
                    ),
                  ),
                  title: Text(
                    _displayNameFrom(data),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        (data['email'] ?? '').toString(),
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 6),
                      _roleChip(role),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (v) async {
                      if (v == 'makeAdmin') {
                        await d.reference.update({'role': 'admin'});
                      }
                      if (v == 'makeStaff') {
                        await d.reference.update({'role': 'staff'});
                      }
                      if (v == 'delete') {
                        final ok = await _confirmDelete(context);
                        if (ok) {
                          await d.reference.delete();
                        }
                      }
                    },
                    itemBuilder: (_) => [
                      if (!isAdmin)
                        const PopupMenuItem(
                          value: 'makeAdmin',
                          child: Text('Đặt làm Admin'),
                        ),
                      if (isAdmin)
                        const PopupMenuItem(
                          value: 'makeStaff',
                          child: Text('Hạ xuống Staff'),
                        ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text(
                          'Xóa nhân viên',
                          style: TextStyle(color: Colors.red),
                        ),
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

  // Try several common name fields; fall back to email or 'Chưa đặt tên'
  static String _displayNameFrom(Map<String, dynamic> data) {
    final candidates = <String>[
      (data['full_name'] ?? '').toString(),
      (data['fullName'] ?? '').toString(),
      (data['name'] ?? '').toString(),
      (data['displayName'] ?? '').toString(),
      (data['username'] ?? '').toString(),
    ];
    for (final c in candidates) {
      if (c.trim().isNotEmpty) return c.trim();
    }
    final email = (data['email'] ?? '').toString();
    if (email.trim().isNotEmpty) return email;
    return 'Chưa đặt tên';
  }

  // ================= UI HELPERS =================

  Widget _roleChip(String role) {
    final isAdmin = role == 'admin';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isAdmin
            ? Colors.redAccent.withOpacity(0.12)
            : Colors.indigo.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isAdmin ? 'ADMIN' : 'STAFF',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: isAdmin ? Colors.redAccent : Colors.indigo,
        ),
      ),
    );
  }

  // ================= LOGIC =================

  Future<bool> _confirmDelete(BuildContext context) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text(
          'Bạn có chắc chắn muốn xóa nhân viên này?\nHành động không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    return res == true;
  }
}
