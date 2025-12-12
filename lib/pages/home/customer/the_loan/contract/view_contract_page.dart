import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_credit/models/loan.dart';
import 'view_contract_detail_page.dart'; // Nhớ import file chi tiết hợp đồng

class ViewContractPage extends StatelessWidget {
  final Loan loan;

  const ViewContractPage({super.key, required this.loan});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,###', 'vi_VN');

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        title: const Text(
          'Hợp đồng vay',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// ------------------- TÓM TẮT HỢP ĐỒNG -------------------
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tóm tắt hợp đồng',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  _infoRow('Số hợp đồng', loan.id),
                  const SizedBox(height: 8),

                  _infoRow('Loại sản phẩm', 'Vay tiền mặt'),
                  const SizedBox(height: 8),

                  _infoRow('Số tiền vay', '${fmt.format(loan.amount)} VND'),
                  const SizedBox(height: 8),

                  _infoRow('Kỳ hạn vay', '${loan.totalCycles} tháng'),
                  const SizedBox(height: 8),

                  _infoRow('Ngày bắt đầu', loan.disbursementDate),
                  const SizedBox(height: 8),

                  if (loan.nextDueDate != null)
                    _infoRow('Ngày kết thúc', loan.nextDueDate!),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          /// ------------------- NÚT XEM CHI TIẾT HỢP ĐỒNG -------------------
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ViewContractDetailPage(loan: loan),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1976D2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text(
              'Xem chi tiết hợp đồng',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// ------------------- WIDGET: Dòng thông tin -------------------
  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
