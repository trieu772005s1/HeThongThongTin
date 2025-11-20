import 'package:flutter/material.dart';
import 'package:fl_credit/pages/loan_online/loan_step/step/loan_step2_page.dart';

class LoanStepPage extends StatefulWidget {
  const LoanStepPage({super.key});

  @override
  State<LoanStepPage> createState() => _LoanStepPageState();
}

class _LoanStepPageState extends State<LoanStepPage> {
  int _currentStep = 2; // bắt đầu từ bước 2

  String _userName =
      'Biện Phúc Toàn'; // tạm giả lập, bạn thay bằng dữ liệu thật từ Firebase
  String _userIdNumber = '079205003635'; // tương tự

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        title: const Text('Vay Online', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 220,
            decoration: const BoxDecoration(
              color: Color(0xFF1976D2),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Center(
              child: SizedBox(
                width: 180,
                child: Image.asset(
                  'assets/images/loan_step_page_background.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tạo đăng ký vay',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Hoàn tất các bước sau để hoàn thành đăng ký vay của bạn',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 32),
                    for (int i = 1; i <= 4; i++) ...[
                      _buildStepWithLine(step: i, title: _getStepTitle(i)),
                      const SizedBox(height: 20),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 1:
        return 'Xác thực tài khoản (Đã hoàn tất)';
      case 2:
        return 'Khởi tạo hồ sơ vay';
      case 3:
        return 'Hoàn tất thông tin';
      case 4:
        return 'Xác nhận đề nghị vay';
      default:
        return '';
    }
  }

  void _handleStepStart(int step) async {
    if (_currentStep != step) return;

    if (step == 2) {
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) =>
              LoanStep2Page(name: _userName, idNumber: _userIdNumber),
        ),
      );
      if (result == true) {
        setState(() {
          _currentStep = 3;
        });
      }
    } else {
      // xử lý các bước 3 hoặc 4 nếu bạn thêm sau
      setState(() {
        _currentStep = step;
      });
    }
  }

  Widget _buildStepWithLine({required int step, required String title}) {
    final bool done = step < _currentStep;
    final bool isCurrent = step == _currentStep;
    final colorDone = const Color(0xFF1976D2);

    return Stack(
      children: [
        if (step < 4)
          Positioned(
            left: 20,
            top: 30,
            bottom: 0,
            child: Container(
              width: 2,
              color: done ? colorDone : Colors.grey.shade300,
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(bottom: 32),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: done || isCurrent
                    ? colorDone
                    : Colors.grey.shade200,
                child: Text(
                  '$step',
                  style: TextStyle(
                    color: done || isCurrent
                        ? Colors.white
                        : Colors.grey.shade600,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    color: isCurrent
                        ? Colors.black
                        : done
                        ? Colors.black87
                        : Colors.grey.shade700,
                  ),
                ),
              ),
              if (isCurrent && step >= 2)
                TextButton(
                  onPressed: () => _handleStepStart(step),
                  style: TextButton.styleFrom(foregroundColor: colorDone),
                  child: const Text('Bắt đầu'),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
