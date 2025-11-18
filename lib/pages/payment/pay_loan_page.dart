import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_credit/models/loan.dart';

class PayLoanPage extends StatelessWidget {
  final Loan loan;

  const PayLoanPage({super.key, required this.loan});

  @override
  Widget build(BuildContext context) {
    final NumberFormat fmt = NumberFormat('#,###', 'vi_VN');

    final int principal = loan.amount;
    final int interest = loan.closingInterest ?? 0;
    final int overdue = loan.overdueAmount ?? 0;
    final int payFee = loan.closingFee ?? 0;
    final int collectionFee = loan.collectionFee ?? 0;
    final int totalPayment =
        principal + interest + overdue + payFee + collectionFee;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text('Thanh toán khoản vay'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  loan.id,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

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
                          'Thông tin thanh toán khoản vay',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '(Tính đến ngày ${DateFormat('dd/MM/yyyy').format(DateTime.now())})',
                          style: const TextStyle(color: Colors.grey),
                        ),

                        const Divider(height: 24),
                        _infoRow('Số tiền gốc', '${fmt.format(principal)} VND'),
                        const SizedBox(height: 8),
                        _infoRow('Số tiền lãi', '${fmt.format(interest)} VND'),
                        const SizedBox(height: 8),
                        _infoRow(
                          'Số tiền quá hạn',
                          '${fmt.format(overdue)} VND',
                        ),
                        const SizedBox(height: 8),
                        _infoRowWithInfo(
                          'Phí thanh toán',
                          '${fmt.format(payFee)} VND',
                        ),
                        const SizedBox(height: 8),
                        _infoRow(
                          'Phí thu hộ dự kiến',
                          '${fmt.format(collectionFee)} VND',
                        ),
                        const Divider(height: 24),
                        _infoRow(
                          'Tổng tiền dự kiến',
                          '${fmt.format(totalPayment)} VND',
                          bold: true,
                        ),
                        const SizedBox(height: 12),
                        _noteBox(
                          'Phí thu hộ thực tế sẽ phụ thuộc vào phương thức thanh toán bạn chọn',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          _buildBottomBar(context, totalPayment, collectionFee),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          value,
          style: TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _infoRowWithInfo(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(label),
            const SizedBox(width: 4),
            Icon(Icons.info_outline, size: 16, color: Colors.grey.shade600),
          ],
        ),
        Text(value),
      ],
    );
  }

  Widget _noteBox(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.blue, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, int total, int collectionFee) {
    final NumberFormat fmt = NumberFormat('#,###', 'vi_VN');
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tổng số tiền thanh toán',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                Text.rich(
                  TextSpan(
                    text: '${fmt.format(total)} VND',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                    children: [
                      TextSpan(
                        text: '  ^',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Đã gồm phí thu hộ: ${fmt.format(collectionFee)} VND',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            height: 46,
            child: ElevatedButton(
              onPressed: () {
                // TODO: xử lý thanh toán
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Tiếp tục'),
            ),
          ),
        ],
      ),
    );
  }
}
