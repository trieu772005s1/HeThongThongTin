import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_credit/models/loan.dart';

class ViewContractDetailPage extends StatelessWidget {
  final Loan loan;

  const ViewContractDetailPage({super.key, required this.loan});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,###', 'vi_VN');

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        title: const Text(
          'Chi tiết hợp đồng',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1976D2),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSection(),
            const SizedBox(height: 16),
            _buildSummaryCard(fmt),
            const SizedBox(height: 24),
            _buildTermsCard(fmt),
            const SizedBox(height: 24),
            _buildCommitmentCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1976D2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'HỢP ĐỒNG TÍN DỤNG TIÊU DÙNG',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Số hợp đồng: ${loan.id}',
            style: const TextStyle(color: Colors.white70),
          ),
          Text(
            'Ngày ký: ${loan.disbursementDate}',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(NumberFormat fmt) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
            _infoRow('Loại sản phẩm', 'Vay tiền mặt'),
            const SizedBox(height: 8),
            _infoRow('Số tiền vay', '${fmt.format(loan.amount)} VND'),
            const SizedBox(height: 8),
            _infoRow('Kỳ hạn vay', '${loan.totalCycles} tháng'),
            const SizedBox(height: 8),
            _infoRow('Trạng thái', loan.status),
            const SizedBox(height: 8),
            if (loan.nextDueDate != null)
              _infoRow('Ngày kết thúc', loan.nextDueDate!),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsCard(NumberFormat fmt) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Điều khoản vay',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _infoRow('• Ngày giải ngân', loan.disbursementDate),
            const SizedBox(height: 8),
            if (loan.installmentAmount != null)
              _infoRow(
                '• Khoản trả mỗi kỳ',
                '${fmt.format(loan.installmentAmount!)} VND',
              ),
            const SizedBox(height: 8),
            const Text(
              '• Lãi suất: Theo chính sách tại thời điểm ký hợp đồng',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommitmentCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cam kết của các bên',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Khách hàng cam kết cung cấp thông tin chính xác và thực hiện đầy đủ các nghĩa vụ theo hợp đồng này.',
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Đại diện Bên Cho Vay',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Khách hàng',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [Text('(Ký tên, đóng dấu)'), Text('(Ký tên)')],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(color: Colors.grey)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
