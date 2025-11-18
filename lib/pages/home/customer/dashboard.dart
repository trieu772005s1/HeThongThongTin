import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_credit/utils/excel_exporter.dart';

class CustomerDashboard extends StatelessWidget {
  const CustomerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final NumberFormat fmt = NumberFormat('#,###', 'vi_VN');
    final int totalDebt = 25000000;
    final int paidCycles = 4;

    final String currentContractId = '#12345';
    final int currentLoanAmount = 5000000;
    final String nextDueDate = '20/11/2025';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        title: const Text(
          'Xin chào, Triệu!',
          style: TextStyle(
            fontSize: 22,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/notifications');
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Container(
        color: const Color(0xFFF5F9FD),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 24),
            _buildSummaryCard(fmt, totalDebt),
            const SizedBox(height: 24),
            _sectionTitle('Hợp đồng đang sử dụng'),
            _buildUseContract(
              fmt,
              currentContractId,
              currentLoanAmount,
              nextDueDate,
              paidCycles,
            ),
            const SizedBox(height: 24),
            _buildRepaymentButton(context),
            const SizedBox(height: 12),
            _buildExportButton(context),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildSummaryCard(NumberFormat fmt, int debt) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSummaryItem(
              Icons.attach_money,
              'Nợ hiện tại',
              '${fmt.format(debt)}đ',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(IconData icon, String title, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue, size: 28),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(fontSize: 13)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildUseContract(
    NumberFormat fmt,
    String contractId,
    int amount,
    String dueDate,
    int paidCycles,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.assignment, color: Colors.green),
        title: Text('Hợp đồng $contractId'),
        subtitle: Text(
          'Thanh toán: ${fmt.format(amount)}đ - $dueDate\nKỳ đã trả: $paidCycles',
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {},
      ),
    );
  }

  Widget _buildRepaymentButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Chức năng trả khoản vay đang phát triển'),
            ),
          );
        },
        icon: const Icon(Icons.payment, color: Colors.white),
        label: const Text(
          'Trả khoản vay',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade700,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildExportButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          await exportLoanReportToExcel();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Xuất báo cáo Excel thành công')),
          );
        },
        icon: const Icon(Icons.download, color: Colors.white),
        label: const Text(
          'Xuất báo cáo',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade700,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
