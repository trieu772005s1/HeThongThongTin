import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'card_limit_page.dart';

class CardStartPage extends StatefulWidget {
  const CardStartPage({super.key});

  @override
  State<CardStartPage> createState() => _CardStartPageState();
}

class _CardStartPageState extends State<CardStartPage> {
  String? cardStatus;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance
        .collection("card_applications")
        .doc(uid)
        .get();

    if (!doc.exists) {
      setState(() => cardStatus = null);
    } else {
      setState(() => cardStatus = doc["status"]);
    }
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

      body: Center(child: _buildBodyByStatus()),
    );
  }

  Widget _buildBodyByStatus() {
    if (cardStatus == null) {
      return _buildOpenCardUI();
    } else if (cardStatus == "pending") {
      return _buildPendingUI();
    } else if (cardStatus == "approved") {
      return _buildApprovedUI();
    }
    return const SizedBox.shrink();
  }

  // UI khi chưa có thẻ
  Widget _buildOpenCardUI() {
    return Column(
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
    );
  }

  // UI đang xét duyệt
  Widget _buildPendingUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.hourglass_empty, size: 60, color: Colors.orange),
        SizedBox(height: 16),
        Text(
          "Hồ sơ mở thẻ của bạn đang được xét duyệt",
          style: TextStyle(fontSize: 17),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // UI khi đã phê duyệt
  Widget _buildApprovedUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.credit_score, size: 60, color: Colors.green),
        SizedBox(height: 16),
        Text(
          "Thẻ của bạn đã được phê duyệt!",
          style: TextStyle(fontSize: 17),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
