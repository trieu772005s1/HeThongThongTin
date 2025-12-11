import 'package:flutter/material.dart';
import 'package:fl_credit/services/auth_service.dart';

class HomeStaffPage extends StatelessWidget {
  final String userRole;

  const HomeStaffPage({super.key, required this.userRole});

  bool get isAdmin => userRole == 'admin';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isAdmin ? 'Trang quản trị (Admin)' : 'Trang nhân viên'),
        backgroundColor: const Color(0xFF1976D2),
        actions: [
          IconButton(
            tooltip: 'Đăng xuất',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().signOut();
              if (!context.mounted) return;
              // Xoá stack và quay về màn login
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1976D2), Color(0xFF64B5F6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            cardTile(
              context,
              'Tạo hợp đồng',
              onTap: () {
                Navigator.pushNamed(context, '/loanContract');
              },
            ),
            cardTile(
              context,
              'Xem danh sách khoản vay',
              onTap: () {
                Navigator.pushNamed(context, '/loanList');
              },
            ),
            cardTile(context, 'Cập nhật thanh toán', onTap: () {}),
            if (isAdmin) cardTile(context, 'Xóa hợp đồng', onTap: () {}),
            if (isAdmin) cardTile(context, 'Quản lý nhân viên', onTap: () {}),
          ],
        ),
      ),
    );
  }

  Widget cardTile(
    BuildContext context,
    String title, {
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        title: Text(title, style: const TextStyle(fontSize: 18)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: onTap,
      ),
    );
  }
}
