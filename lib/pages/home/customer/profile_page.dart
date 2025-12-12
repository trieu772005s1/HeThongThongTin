import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_credit/services/auth_service.dart';

// Pages
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
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc muốn đăng xuất không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Hủy")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Đăng xuất")),
        ],
      ),
    );

    if (confirm != true) return;

    await _authService.signOut();
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginPage()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff3f6fb),
      appBar: PreferredSize(
  preferredSize: const Size.fromHeight(90),
  child: Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Color(0xFF1976D2),
          Color(0xFF42A5F5),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(28),
        bottomRight: Radius.circular(28),
      ),
    ),
    padding: const EdgeInsets.only(top: 35, left: 20, bottom: 15),
    alignment: Alignment.centerLeft,
    child: const Text(
      "Cá nhân",
      style: TextStyle(
        color: Colors.white,
        fontSize: 23,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
      ),
    ),
  ),
),

      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _fetchUserDoc(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snap.data?.data() ?? {};
          final userName = data["fullName"] ?? "Khách hàng";
          final isVerified = data["isVerifiedAccount"] == true;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // =========================
              // HEADER PROFILE CARD
              // =========================
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6),
                        ],
                      ),
                      child: const CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, size: 40, color: Color(0xFF1976D2)),
                      ),
                    ),
                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),

                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isVerified ? Icons.verified : Icons.error_outline,
                                  color: isVerified ? Colors.green : Colors.orange,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isVerified ? "Đã xác thực" : "Chưa xác thực",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isVerified ? Colors.green : Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // =========================
              // MENU ITEMS
              // =========================
              _menuCard(
                icon: Icons.lock_outline,
                text: "Thay đổi mật khẩu",
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordPage())),
              ),

              _menuCard(
                icon: Icons.support_agent,
                text: "Liên hệ hỗ trợ",
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportPage())),
              ),

              _menuCard(
                icon: Icons.description_outlined,
                text: "Điều khoản cho vay",
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoanTermsPage())),
              ),

              _menuCard(
                icon: Icons.article_outlined,
                text: "Điều khoản & điều kiện sử dụng",
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AppTermsPage())),
              ),

              _menuCard(
                icon: Icons.privacy_tip_outlined,
                text: "Xử lý dữ liệu cá nhân",
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPage())),
              ),

              const SizedBox(height: 20),

              // =========================
              // LOGOUT BUTTON
              // =========================
              Container(
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    "Đăng xuất",
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                  onTap: () => _logout(context),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // =========================
  // BEAUTIFUL MENU CARD
  // =========================
  Widget _menuCard({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF1976D2), size: 26),
        title: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
