import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_credit/models/loan.dart';

class PaymentSchedulePage extends StatefulWidget {
  final Loan loan;

  const PaymentSchedulePage({super.key, required this.loan});

  @override
  State<PaymentSchedulePage> createState() => _PaymentSchedulePageState();
}

class _PaymentSchedulePageState extends State<PaymentSchedulePage> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,###', 'vi_VN');
    final installments = widget.loan.installments ?? [];

    final now = DateTime.now();
    final upcoming = installments.where((i) {
      final dt = DateFormat('dd/MM/yyyy').parse(i.dueDate);
      return dt.isAfter(now);
    }).toList();
    final past = installments.where((i) {
      final dt = DateFormat('dd/MM/yyyy').parse(i.dueDate);
      return dt.isBefore(now);
    }).toList();

    List<Installment> displayList;
    switch (_selectedTabIndex) {
      case 1:
        displayList = upcoming;
        break;
      case 2:
        displayList = past;
        break;
      default:
        displayList = installments;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text('Lịch thanh toán'),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                _tabButton('Tất cả', 0),
                const SizedBox(width: 8),
                _tabButton('Sắp tới', 1),
                const SizedBox(width: 8),
                _tabButton('Đã qua', 2),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '(${displayList.length}) kỳ',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: displayList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final inst = displayList[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text('Kỳ thanh toán ${inst.period}'),
                    subtitle: Text(inst.dueDate),
                    trailing: Text('${fmt.format(inst.amount)} VND'),
                    onTap: () {},
                  ),
                );
              },
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Thêm vào lịch điện thoại',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabButton(String title, int index) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1976D2) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
