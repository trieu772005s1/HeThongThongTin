import 'package:flutter/material.dart';

class LoanStep3Page extends StatelessWidget {
  const LoanStep3Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bước 3/4'),
        backgroundColor: const Color(0xFF1976D2),
      ),
      body: const Center(child: Text('Nội dung bước 3')),
    );
  }
}
