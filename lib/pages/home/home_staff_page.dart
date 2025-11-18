import 'package:flutter/material.dart';

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
            cardTile('Tạo hợp đồng'),
            cardTile('Xem danh sách khoản vay'),
            cardTile('Cập nhật thanh toán'),
            if (isAdmin) cardTile('Xóa hợp đồng'),
            if (isAdmin) cardTile('Quản lý nhân viên'),
          ],
        ),
      ),
    );
  }

  Widget cardTile(String title) {
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
        onTap: () {},
      ),
    );
  }
}
