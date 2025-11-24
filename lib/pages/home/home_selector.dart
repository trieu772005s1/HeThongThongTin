// lib/pages/home/home_selector.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:fl_credit/pages/home/customer/home_customer_page.dart';
import 'package:fl_credit/pages/home/home_staff_page.dart';

class HomeSelectorPage extends StatefulWidget {
  const HomeSelectorPage({super.key});

  @override
  State<HomeSelectorPage> createState() => _HomeSelectorPageState();
}

class _HomeSelectorPageState extends State<HomeSelectorPage> {
  @override
  void initState() {
    super.initState();
    _redirectByRole();
  }

  Future<void> _redirectByRole() async {
    final user = FirebaseAuth.instance.currentUser;

    // Chưa đăng nhập → về login
    if (user == null) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/');
      return;
    }

    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data = snap.data() ?? {};
      final role = (data['role'] ?? 'customer') as String;

      if (!mounted) return;

      if (role == 'staff' || role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeStaffPage(userRole: role)),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeCustomerPage()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi tải thông tin: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
