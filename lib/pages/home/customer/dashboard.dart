import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_credit/pages/home/customer/support/support_page.dart';
import 'package:fl_credit/pages/home/customer/wardrobe/wardrobe_page.dart';
import 'package:fl_credit/pages/home/customer/loan_online/loan_step/loan_step_page.dart';
import 'package:fl_credit/pages/home/customer/loan_online/loan_step/steps/account_verification_page.dart';

class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({super.key});

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  late Future<DocumentSnapshot<Map<String, dynamic>>> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _fetchUserDoc();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _fetchUserDoc() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Chưa đăng nhập');
    }
    return FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  }

  Future<void> _openVerification(BuildContext context) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AccountVerificationPage()),
    );

    if (result == true && mounted) {
      setState(() {
        _userFuture = _fetchUserDoc(); // reload lại thông tin
      });
    }
  }

  Future<void> _startLoanFlow(
    BuildContext context,
    String currentName,
    String currentId,
    bool isVerified,
  ) async {
    var name = currentName;
    var idNumber = currentId;
    var verified = isVerified;

    // Nếu chưa xác thực thì ép user đi xác thực trước
    if (!verified) {
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => const AccountVerificationPage()),
      );

      if (result == true) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final doc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
          final data = doc.data() ?? {};
          verified = data['isVerifiedAccount'] == true;
          name = data['fullName'] ?? name;
          idNumber = data['idNumber'] ?? idNumber;
        }

        if (mounted) {
          setState(() {
            _userFuture = _fetchUserDoc();
          });
        }
      }
    }

    // Đã xác thực rồi thì vào thẳng flow vay (bắt đầu từ step 2)
    if (verified) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LoanStepPage(name: name, idNumber: idNumber),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Lỗi tải thông tin người dùng')),
          );
        }

        final data = snapshot.data?.data() ?? {};

        final fullName = (data['fullName'] as String?) ?? 'Khách Hàng';
        final idNumber = (data['idNumber'] as String?) ?? '';
        final isVerified =
            data['isVerifiedAccount'] is bool &&
            data['isVerifiedAccount'] == true;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F9FD),
          appBar: AppBar(
            backgroundColor: const Color(0xFF1976D2),
            elevation: 0,
            title: Text(
              'Xin chào!\n$fullName',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.5,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () {},
              ),
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications, color: Colors.white),
                    onPressed: () {},
                  ),
                  const Positioned(
                    top: 10,
                    right: 10,
                    child: CircleAvatar(backgroundColor: Colors.red, radius: 4),
                  ),
                ],
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Nếu CHƯA xác thực -> hiện banner "Xác thực tài khoản"
              if (!isVerified) ...[
                _buildVerifyBanner(context),
                const SizedBox(height: 24),
              ] else ...[
                // Nếu đã xác thực -> hiện banner vay online như cũ
                _buildLoanBanner(context, fullName, idNumber, isVerified),
                const SizedBox(height: 24),
              ],
              _buildFunctionItems(context, fullName, idNumber, isVerified),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  // Banner khi CHƯA xác thực
  Widget _buildVerifyBanner(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1976D2),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Xác thực tài khoản',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Vay dễ dàng, quản lý an toàn',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _openVerification(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Xác thực ngay',
                style: TextStyle(
                  color: Color(0xFF1976D2),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Banner vay online (dùng khi đã xác thực)
  Widget _buildLoanBanner(
    BuildContext context,
    String fullName,
    String idNumber,
    bool isVerified,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1976D2),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Icon(Icons.card_giftcard, color: Colors.white, size: 40),
          const SizedBox(height: 12),
          const Text(
            'Mở khoản vay\nNhận tiền liền tay',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Ưu đãi mỗi ngày từ Mcredit',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () =>
                _startLoanFlow(context, fullName, idNumber, isVerified),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Vay ngay',
              style: TextStyle(
                color: Color(0xFF1976D2),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Grid chức năng
  Widget _buildFunctionItems(
    BuildContext context,
    String fullName,
    String idNumber,
    bool isVerified,
  ) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildFuncItem(Icons.monetization_on, 'Vay Online', () {
          _startLoanFlow(context, fullName, idNumber, isVerified);
        }),
        _buildFuncItem(Icons.shopping_bag, 'Tủ đồ', () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WardrobePage()),
          );
        }),
        _buildFuncItem(Icons.location_on, 'Điểm giao dịch', () {}),
        _buildFuncItem(Icons.support_agent, 'Hỗ trợ', () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SupportPage()),
          );
        }),
      ],
    );
  }

  Widget _buildFuncItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.blue.shade50,
            child: Icon(icon, color: Colors.blue.shade800),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}
