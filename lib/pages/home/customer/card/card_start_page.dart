import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'card_limit_page.dart';

class CardStartPage extends StatelessWidget {
  const CardStartPage({super.key});

  Stream<DocumentSnapshot<Map<String, dynamic>>> _userStream() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance.collection('users').doc(uid).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Thẻ tín dụng",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF002C5F),
          ),
        ),
        centerTitle: false,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _userStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return _buildOpenCardUI(context);
          }

          final data = snapshot.data!.data()!;
          final card = data['creditCard'];
          final status = card?['status'] ?? 'NONE';

          switch (status) {
            case 'NONE':
              return _buildOpenCardUI(context);

            case 'PENDING':
              return _buildPendingUI();

            case 'APPROVED':
              return _buildApprovedUI(card['limit']);

            case 'REJECTED':
              return _buildRejectedUI(context);

            default:
              return _buildOpenCardUI(context);
          }
        },
      ),
    );
  }

  // ================= UI =================

  Widget _buildOpenCardUI(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.credit_card_outlined, size: 60, color: Colors.blue),
          const SizedBox(height: 12),
          const Text(
            "Bạn hiện chưa có thẻ tín dụng nào.",
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 220,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CardLimitPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
              child: const Text(
                "+ Mở thẻ ngay",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingUI() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.hourglass_empty, size: 60, color: Colors.orange),
          SizedBox(height: 16),
          Text(
            "Hồ sơ của bạn đang được nhân viên tín dụng xét duyệt. Thời gian xử lý dự kiến: 1–3 ngày làm việc.",
            style: TextStyle(fontSize: 17),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildApprovedUI(int limit) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.credit_score, size: 60, color: Colors.green),
          const SizedBox(height: 16),
          const Text(
            "Thẻ của bạn đã được phê duyệt!",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text("Hạn mức: $limit VND"),
        ],
      ),
    );
  }

  Widget _buildRejectedUI(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cancel, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            "Hồ sơ mở thẻ của bạn đã bị từ chối",
            style: TextStyle(fontSize: 17),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CardLimitPage()),
              );
            },
            child: const Text("Đăng ký lại"),
          ),
        ],
      ),
    );
  }
}
