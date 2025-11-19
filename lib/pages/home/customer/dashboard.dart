import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_credit/utils/excel_exporter.dart';
import 'package:fl_credit/models/loan.dart';
import 'package:fl_credit/pages/contract/contract_detail_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // để dùng DocumentSnapshot
import 'package:fl_credit/services/firestore_service.dart';

class CustomerDashboard extends StatelessWidget {
  const CustomerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final NumberFormat fmt = NumberFormat('#,###', 'vi_VN');

    final int totalDebt = 25000000;

    // Mẫu hợp đồng đang sử dụng
    final Loan currentLoan = Loan(
      id: 'HD12345',
      amount: 5000000,
      disbursementDate: '01/11/2025',
      status: 'Đang hoạt động',
      paidCycles: 2,
      totalCycles: 12,
    );

    // Danh sách khoản vay để xuất báo cáo
    final List<Loan> loans = [
      currentLoan,
      Loan(
        id: 'HD67890',
        amount: 10000000,
        disbursementDate: '05/10/2025',
        status: 'Đã tất toán',
        paidCycles: 12,
        totalCycles: 12,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        title: _buildGreeting(),
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
            _buildUseContract(context, fmt, currentLoan),
            const SizedBox(height: 24),
            _buildRepaymentButton(context),
            const SizedBox(height: 12),
            _buildExportButton(context, loans),
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

  Widget _buildGreeting() {
    final user = FirebaseAuth.instance.currentUser;

    const baseStyle = TextStyle(
      fontSize: 22,
      color: Colors.white,
      fontWeight: FontWeight.bold,
    );

    // Nếu chưa đăng nhập, hiện mặc định
    if (user == null) {
      return const Text('Xin chào!', style: baseStyle);
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirestoreService().userProfileStream(user.uid),
      builder: (context, snapshot) {
        String name = 'bạn';

        if (snapshot.hasData && snapshot.data!.data() != null) {
          final data = snapshot.data!.data()!;
          final fullName = (data['fullName'] ?? '') as String;

          if (fullName.isNotEmpty) {
            // Lấy từ cuối cùng làm tên: "Trần Tuấn Triệu" -> "Triệu"
            name = fullName.split(' ').last;
          }
        }

        return Text('Xin chào, $name!', style: baseStyle);
      },
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

  Widget _buildUseContract(BuildContext context, NumberFormat fmt, Loan loan) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.assignment, color: Colors.green),
        title: Text('Hợp đồng ${loan.id}'),
        subtitle: Text(
          'Thanh toán: ${fmt.format(loan.amount)}đ - ${loan.disbursementDate}\n'
          'Kỳ đã trả: ${loan.paidCycles}/${loan.totalCycles}',
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ContractDetailPage(loan: loan),
            ),
          );
        },
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

  Widget _buildExportButton(BuildContext context, List<Loan> loans) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          await exportLoanReportToExcel(loans);
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
