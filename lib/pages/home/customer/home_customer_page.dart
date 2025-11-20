import 'package:flutter/material.dart';
import 'package:fl_credit/pages/home/customer/dashboard.dart' as dash;
import 'package:fl_credit/pages/home/customer/profile_page.dart' as profile;
import 'package:fl_credit/pages/the_loan/the_loan_page.dart'; // <- Đảm bảo class tên đúng
import 'package:fl_credit/models/loan.dart';

class HomeCustomerPage extends StatefulWidget {
  const HomeCustomerPage({super.key});

  @override
  State<HomeCustomerPage> createState() => _HomeCustomerPageState();
}

class _HomeCustomerPageState extends State<HomeCustomerPage> {
  int _currentIndex = 0;

  final List<Loan> _loans = [
    Loan(
      id: 'HD001',
      amount: 5000000,
      disbursementDate: '10/11/2025',
      status: 'Đang hoạt động',
      remainingPrincipal: 2000000,
      nextDueDate: '10/12/2025',
      installmentAmount: 500000,
      originalPaid: 3000000,
      paidCycles: 6,
      totalCycles: 12,
      closingInterest: 100000,
      overdueAmount: 0,
      closingFee: 50000,
      collectionFee: 10000,
      transactionHistory: [],
      installments: [],
    ),
    Loan(
      id: 'HD002',
      amount: 7000000,
      disbursementDate: '01/01/2025',
      status: 'Đã tất toán',
      paidCycles: 12,
      totalCycles: 12,
      transactionHistory: [],
      installments: [],
    ),
  ];

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const dash.CustomerDashboard(),
      TheLoanPage(loans: _loans), // <- Đúng tên class, truyền danh sách vào
      Container(),
      Container(),
      const profile.ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(icon: Icons.home, label: 'Trang chủ', index: 0),
              _navItem(icon: Icons.attach_money, label: 'Khoản vay', index: 1),
              const SizedBox(width: 48),
              _navItem(icon: Icons.credit_card, label: 'Thẻ', index: 3),
              _navItem(icon: Icons.person, label: 'Cá nhân', index: 4),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF1976D2),
        child: const Icon(Icons.add, size: 32, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _navItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF1976D2) : Colors.grey,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? const Color(0xFF1976D2) : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
