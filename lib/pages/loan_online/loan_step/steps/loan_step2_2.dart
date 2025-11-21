import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LoanStep2_2 extends StatefulWidget {
  const LoanStep2_2({super.key});

  @override
  State<LoanStep2_2> createState() => _LoanStep2_2State();
}

class _LoanStep2_2State extends State<LoanStep2_2> {
  double _selectedAmount = 3000000;
  final double _minAmount = 3000000;
  final double _maxAmount = 20000000;

  String get _formattedAmount {
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '',
      decimalDigits: 0,
    );
    return formatter.format(_selectedAmount);
  }

  @override
  Widget build(BuildContext context) {
    // Số phân đoạn bạn muốn chia (ví dụ: mỗi 1 triệu là một bước)
    final int divisionsCount = ((_maxAmount - _minAmount) / 1000000).round();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bạn cần vay bao nhiêu?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text('Tôi mong muốn vay', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Text(
            '${_formattedAmount} VND',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          Slider(
            value: _selectedAmount,
            min: _minAmount,
            max: _maxAmount,
            divisions: divisionsCount,
            label: '${_formattedAmount} VND',
            onChanged: (double value) {
              setState(() {
                _selectedAmount = value;
              });
            },
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${NumberFormat.compact(locale: 'vi_VN').format(_minAmount)} VND',
              ),
              Text(
                '${NumberFormat.compact(locale: 'vi_VN').format(_maxAmount)} VND',
              ),
            ],
          ),

          const SizedBox(height: 24),
          const Text(
            'Thời gian cấp hạn mức: 36 tháng',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          const Text('Mục đích vay', style: TextStyle(fontSize: 16)),
          // … bạn có thể thêm dropdown hoặc lựa chọn ở đây
        ],
      ),
    );
  }
}
