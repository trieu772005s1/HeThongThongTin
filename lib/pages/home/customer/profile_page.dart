import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_credit/services/auth_service.dart';
import 'package:fl_credit/pages/login_page.dart';
import 'package:fl_credit/pages/auth/change_password_page.dart';
import 'package:fl_credit/pages/support/support_page.dart';
import 'package:fl_credit/pages/terms/loan_terms_page.dart';
import 'package:fl_credit/pages/terms/app_terms_page.dart';
import 'package:fl_credit/pages/terms/privacy_page.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  final AuthService _authService = AuthService();

  Future<DocumentSnapshot<Map<String, dynamic>>> _fetchUserDoc() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Chưa đăng nhập');
    return FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  }

  Future<void> _logout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (ok == true) {
      await _authService.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        elevation: 0,
        title: const Text('Cá nhân'),
        centerTitle: true,
        backgroundColor: const Color(0xFF1976D2),
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _fetchUserDoc(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data?.data() ?? {};
          final name = data['fullName'] ?? 'Khách hàng';
          final verified = data['isVerifiedAccount'] == true;

          return Column(
            children: [
              // ===== HEADER CARD =====
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 34, color: Color(0xFF1976D2)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          _verifyBadge(verified),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ===== MENU =====
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _section('Tài khoản'),
                    _tile(Icons.lock_outline, 'Đổi mật khẩu', () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordPage()));
                    }),

                    const SizedBox(height: 16),
                    _section('Hỗ trợ'),
                    _tile(Icons.support_agent, 'Liên hệ hỗ trợ', () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportPage()));
                    }),

                    const SizedBox(height: 16),
                    _section('Pháp lý'),
                    _tile(Icons.description_outlined, 'Điều khoản cho vay', () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const LoanTermsPage()));
                    }),
                    _tile(Icons.article_outlined, 'Điều khoản sử dụng', () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AppTermsPage()));
                    }),
                    _tile(Icons.privacy_tip_outlined, 'Xử lý dữ liệu cá nhân', () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPage()));
                    }),

                    const SizedBox(height: 24),
                    _logoutButton(context),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ================= COMPONENT =================

  Widget _verifyBadge(bool verified) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: verified ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            verified ? Icons.verified : Icons.info_outline,
            size: 16,
            color: verified ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 6),
          Text(
            verified ? 'Đã xác thực' : 'Chưa xác thực',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: verified ? Colors.green : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black54,
        ),
      ),
    );
  }

  Widget _tile(IconData icon, String title, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF1976D2)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _logoutButton(BuildContext context) {
    return Card(
      color: Colors.red.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: const Icon(Icons.logout, color: Colors.red),
        title: const Text(
          'Đăng xuất',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        onTap: () => _logout(context),
      ),
    );
  }
}
