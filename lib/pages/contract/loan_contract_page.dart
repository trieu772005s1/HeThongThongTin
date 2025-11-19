import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_credit/models/loan.dart';

class LoanContractPage extends StatelessWidget {
  final Loan loan;

  const LoanContractPage({super.key, required this.loan});

  @override
  Widget build(BuildContext context) {
    final NumberFormat fmt = NumberFormat('#,###', 'vi_VN');

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text('Chi tiết hợp đồng'),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoRow('Số hợp đồng', loan.id),
                  const SizedBox(height: 8),
                  _infoRow(
                    'Tổng số tiền vay',
                    '${fmt.format(loan.amount)} VND',
                  ),
                  const SizedBox(height: 8),
                  _infoRow('Trạng thái', loan.status),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.email_outlined),
                  label: const Text('Gửi Email'),
                  onPressed: () {
                    // TODO: logic gửi email hợp đồng
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.download_outlined),
                  label: const Text('Tải về'),
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: const Color(0xFF1976D2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Hiển thị bản hợp đồng (ví dụ ảnh hoặc PDF)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(16),
            child: Image.asset(
              'assets/images/contract_sample.png', // thay bằng đường dẫn thật
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
