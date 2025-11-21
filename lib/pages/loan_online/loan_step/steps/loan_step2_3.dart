import 'package:flutter/material.dart';

class LoanStep2_3 extends StatelessWidget {
  const LoanStep2_3({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Xác nhận hồ sơ',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text(
            'Vui lòng kiểm tra lại thông tin và xác nhận gửi hồ sơ',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 24),
          Text('Họ và tên: Biện Phúc Toàn'),
          SizedBox(height: 8),
          Text('Số CMND/CCCD: 079205003635'),
        ],
      ),
    );
  }
}
