import 'package:fl_credit/pages/home/customer/home_customer_page.dart';
import 'package:fl_credit/pages/home/notification_page.dart';
import 'package:flutter/material.dart';
import 'package:fl_credit/pages/login_page.dart';
import 'package:fl_credit/pages/register_screen.dart';
import 'package:fl_credit/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:fl_credit/pages/contract/loan_list_page.dart';
import 'package:fl_credit/pages/contract/loan_contract_page.dart';
import 'package:fl_credit/pages/home/customer/home_customer_page.dart';
import 'package:fl_credit/pages/home/notification_page.dart';
import 'package:fl_credit/pages/home/home_staff_page.dart';
import 'package:fl_credit/pages/login_page.dart';
import 'package:fl_credit/pages/register_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FL CREDIT',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),

        // khách hàng
        '/home': (context) => const HomeCustomerPage(),
        '/notifications': (context) => const NotificationsPage(),

        // nhân viên
        '/staffHome': (context) => const HomeStaffPage(userRole: 'staff'),

        // admin
        '/adminHome': (context) => const HomeStaffPage(userRole: 'admin'),
        // route tạo hợp đồng
        '/loanContract': (context) => const LoanContractPage(),
        '/loanList': (context) => LoanListPage(),
      },
    );
  }
}
