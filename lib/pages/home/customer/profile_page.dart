import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_credit/services/auth_service.dart';
import 'package:fl_credit/services/firestore_service.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          'Cá nhân',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(), // giờ header lấy tên từ Firestore
              const SizedBox(height: 30),
              _buildMenuList(context),
            ],
          ),
        ),
      ),
    );
  }

  /// HEADER: lấy user hiện tại + dữ liệu từ Firestore
  Widget _buildHeader() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // trường hợp hiếm khi chưa đăng nhập
      return _headerContainer('Người dùng');
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirestoreService().userProfileStream(user.uid),
      builder: (context, snapshot) {
        String displayName = user.email ?? 'Người dùng';

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data();
          if (data != null && data['fullName'] is String) {
            displayName = data['fullName'] as String;
          }
        }

        return _headerContainer(displayName);
      },
    );
  }

  /// UI của header, chỉ cần truyền tên
  Widget _headerContainer(String name) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1976D2), Color(0xFF64B5F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 36, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified, size: 16, color: Colors.green),
                    SizedBox(width: 4),
                    Text(
                      'Đã xác thực',
                      style: TextStyle(fontSize: 12, color: Colors.green),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// MENU + ĐĂNG XUẤT
  Widget _buildMenuList(BuildContext context) {
    final items = [
      {'icon': Icons.lock_outline, 'title': 'Thay đổi mật khẩu'},
      {'icon': Icons.support_agent, 'title': 'Liên hệ hỗ trợ'},
      {'icon': Icons.description, 'title': 'Điều khoản cho vay'},
      {'icon': Icons.verified_user, 'title': 'Điều khoản & điều kiện sử dụng'},
      {'icon': Icons.privacy_tip, 'title': 'Xử lý dữ liệu cá nhân'},
      {'icon': Icons.logout, 'title': 'Đăng xuất'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: items.map((item) {
          final String title = item['title'] as String;
          final bool isLogout = title == 'Đăng xuất';

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                leading: Icon(item['icon'] as IconData, color: Colors.blue),
                title: Text(title),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () async {
                  if (isLogout) {
                    await AuthService().signOut();
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/',
                      (route) => false,
                    );
                  } else {
                    // Sau này xử lý thêm cho các menu khác
                  }
                },
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
