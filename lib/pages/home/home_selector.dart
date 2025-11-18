import 'package:flutter/material.dart';
import 'home_staff_page.dart';
import 'customer/home_customer_page.dart';

class HomeSelectorPage extends StatelessWidget {
  final String userRole;

  const HomeSelectorPage({super.key, required this.userRole});

  @override
  Widget build(BuildContext context) {
    switch (userRole) {
      case 'admin':
      case 'staff':
        return HomeStaffPage(userRole: userRole); // dùng chung
      case 'customer':
        return const HomeCustomerPage();
      default:
        return const Scaffold(
          body: Center(
            child: Text(
              'Không xác định được vai trò người dùng',
              style: TextStyle(fontSize: 18),
            ),
          ),
        );
    }
  }
}
