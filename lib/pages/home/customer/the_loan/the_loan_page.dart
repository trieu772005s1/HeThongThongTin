import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_credit/models/loan.dart';
import 'package:fl_credit/pages/home/customer/the_loan/the_loan_detail_page.dart';

class TheLoanPage extends StatefulWidget {
  final List<Loan> loans;

  const TheLoanPage({super.key, required this.loans});

  @override
  State<TheLoanPage> createState() => _TheLoanPageState();
}

class _TheLoanPageState extends State<TheLoanPage> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,###', 'vi_VN');

    final current = widget.loans.where((l) => !l.isPaidOff).toList();
    final paidOff = widget.loans.where((l) => l.isPaidOff).toList();
    final displayList = _tabIndex == 0 ? current : paidOff;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Khoản vay', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1976D2),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: Row(
              children: [
                _buildTab('Hiện có (${current.length})', 0),
                _buildTab('Đã tất toán (${paidOff.length})', 1),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: displayList.isEmpty
                ? const Center(child: Text('Không có khoản vay nào'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: displayList.length,
                    itemBuilder: (context, index) {
                      final loan = displayList[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          leading: const Icon(
                            Icons.monetization_on,
                            color: Colors.blue,
                          ),
                          title: Text(loan.status), // dùng status thay vì type
                          subtitle: Text(
                            'Số hợp đồng: ${loan.id}\nNgày ký: ${loan.disbursementDate}',
                          ),
                          trailing: Text(
                            '${fmt.format(loan.amount)} VND',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TheLoanDetailPage(loan: loan),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _tabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _tabIndex = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                width: 2,
                color: isSelected ? Colors.blue : Colors.transparent,
              ),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(color: isSelected ? Colors.blue : Colors.grey),
            ),
          ),
        ),
      ),
    );
  }
}
