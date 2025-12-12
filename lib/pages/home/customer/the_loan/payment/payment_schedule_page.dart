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
  int _selectedTabIndex = 0; // 0 = Tất cả, 1 = Sắp tới, 2 = Đã qua

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,###', 'vi_VN');
    final List<Installment> installments = widget.loan.installments ?? [];

    // Phân loại các kỳ
    final now = DateTime.now();
    final upcoming = installments.where((i) {
      try {
        final dt = DateFormat('dd/MM/yyyy').parse(i.dueDate);
        return dt.isAfter(now);
      } catch (_) {
        return false;
      }
    }).toList();

    final past = installments.where((i) {
      try {
        final dt = DateFormat('dd/MM/yyyy').parse(i.dueDate);
        return dt.isBefore(now) || dt.isAtSameMomentAs(now);
      } catch (_) {
        return false;
      }
    }).toList();

    List<Installment> displayList;
    if (_selectedTabIndex == 1) {
      displayList = upcoming;
    } else if (_selectedTabIndex == 2) {
      displayList = past;
    } else {
      displayList = installments;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        title: const Text(
          'Lịch thanh toán',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _tabButton('Tất cả (${installments.length})', 0),
                  _tabButton('Sắp tới (${upcoming.length})', 1),
                  _tabButton('Đã qua (${past.length})', 2),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: displayList.isEmpty
                  ? const Center(child: Text('Không có kỳ thanh toán'))
                  : ListView.separated(
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
                            trailing: Text('${fmt.format(inst.amount)}đ'),
                            onTap: () {},
                          ),
                        );
                      },
                    ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
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
            color: isSelected ? Colors.blue.shade50 : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? Colors.blue : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
