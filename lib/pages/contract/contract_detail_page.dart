import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_credit/models/loan.dart';
import 'package:fl_credit/pages/payment/payment_schedule_page.dart';
import 'package:fl_credit/pages/payment/pay_loan_page.dart';

class ContractDetailPage extends StatelessWidget {
  final Loan loan;

  const ContractDetailPage({super.key, required this.loan});

  @override
  Widget build(BuildContext context) {
    final NumberFormat fmt = NumberFormat('#,###', 'vi_VN');
    final int remainingPrincipal = loan.remainingPrincipal ?? loan.amount;
    final String nextDueDate = loan.nextDueDate ?? '—';
    final int installmentAmount = loan.installmentAmount ?? 0;
    final List<Transaction> historyList = loan.transactionHistory ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text('Chi tiết khoản vay'),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _sectionCard(
              icon: Icons.assignment,
              title: 'Thông tin hợp đồng',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoRow('Số hợp đồng', loan.id),
                  const SizedBox(height: 8),
                  _infoRow('Tổng số tiền vay', '${fmt.format(loan.amount)}đ'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _sectionCard(
              icon: Icons.bar_chart,
              title: 'Tiến độ thanh toán',
              child: Column(
                children: [
                  _infoRow(
                    'Số tiền gốc đã trả',
                    '${fmt.format(loan.originalPaid ?? 0)}đ',
                  ),
                  const SizedBox(height: 8),
                  _infoRow(
                    'Tổng nợ gốc hiện tại',
                    '${fmt.format(remainingPrincipal)}đ',
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: (loan.totalCycles > 0)
                        ? (loan.paidCycles / loan.totalCycles)
                        : 0,
                    backgroundColor: Colors.grey.shade300,
                    color: Colors.blue,
                    minHeight: 8,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _sectionCard(
              icon: Icons.credit_card,
              title: 'Thanh toán sắp tới',
              child: Column(
                children: [
                  _infoRow('Kỳ thanh toán tiếp theo', nextDueDate),
                  const SizedBox(height: 8),
                  _infoRow(
                    'Số tiền cần thanh toán',
                    '${fmt.format(installmentAmount)}đ',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _sectionCard(
              icon: Icons.settings,
              title: 'Chức năng',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _actionTile(Icons.schedule, 'Lịch trả', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentSchedulePage(loan: loan),
                      ),
                    );
                  }),
                  _actionTile(Icons.receipt_long, 'Xem HĐ', () {
                    // TODO: điều hướng xem hợp đồng
                  }),
                  _actionTile(Icons.payments, 'Thanh toán', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PayLoanPage(loan: loan),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _sectionCard(
              icon: Icons.history,
              title: 'Lịch sử giao dịch',
              child: (historyList.isEmpty)
                  ? const Text('Không có giao dịch nào.')
                  : Column(
                      children: historyList.map((tx) {
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(
                            Icons.payments,
                            color: Colors.orange,
                          ),
                          title: Text('${fmt.format(tx.amount)}đ'),
                          subtitle: Text(tx.date),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _actionTile(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.blue.shade50,
            child: Icon(icon, color: Colors.blue),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
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
