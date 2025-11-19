import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_credit/services/firestore_service.dart';

class LoanListPage extends StatelessWidget {
  LoanListPage({super.key});

  final _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách khoản vay'),
        backgroundColor: const Color(0xFF1976D2),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _firestoreService.allLoansStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text('Chưa có khoản vay nào'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data();
              final amount = (data['amount'] ?? 0).toDouble();
              final interest = (data['interestRate'] ?? 0).toDouble();
              final term = (data['termMonths'] ?? 0).toInt();
              final status = (data['status'] ?? 'pending') as String;
              final createdAt = data['createdAt'] as Timestamp?;
              final createdStr = createdAt != null
                  ? '${createdAt.toDate().day}/${createdAt.toDate().month}/${createdAt.toDate().year}'
                  : '---';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(
                    'Số tiền: ${amount.toStringAsFixed(0)} VND',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Lãi: ${interest.toStringAsFixed(1)}% | Thời hạn: $term tháng\nTạo ngày: $createdStr',
                  ),
                  trailing: Chip(
                    label: Text(status),
                    backgroundColor: _statusColor(status),
                    labelStyle: const TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    final loanID = docs[index].id;
                    Navigator.pushNamed(
                      context,
                      '/loanDetail',
                      arguments: loanID,
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'closed':
        return Colors.grey;
      default:
        return Colors.orange; // pending
    }
  }
}
