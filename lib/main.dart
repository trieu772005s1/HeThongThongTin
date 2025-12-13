import 'package:fl_credit/pages/loan_online/loan_step/steps/loan_edit_address_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:fl_credit/theme/app_theme.dart';
import 'package:fl_credit/pages/login_page.dart';
import 'package:fl_credit/pages/register_screen.dart';
import 'package:fl_credit/pages/home/customer/home_customer_page.dart';

// Home selector
import 'package:fl_credit/pages/home/staff/home_selector.dart';

// Home staff + admin
import 'package:fl_credit/pages/home/staff/home_staff_page.dart';

// Notifications
import 'package:fl_credit/pages/home/staff/notification_page.dart';

// Loan pages (🔥 đúng vị trí thư mục của bạn)
import 'package:fl_credit/pages/home/staff/loan_list_page.dart';
import 'package:fl_credit/pages/home/staff/loan_detail_page.dart';
import 'package:fl_credit/pages/home/staff/repayment_list_page.dart';
import 'package:fl_credit/pages/home/staff/loan_contract_page.dart';


// Staff management
import 'package:fl_credit/pages/home/staff/staff_management_page.dart';

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
        // Login + Đăng ký
        '/': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),

        // Kiểm tra role
       '/home': (context) {
       final args = ModalRoute.of(context)!.settings.arguments as Map?;
       final userRole = args?['userRole'] ?? 'customers'; // fallback
       return HomeSelectorPage(userRole: userRole);
       },


        // Thông báo
        '/notifications': (context) => const NotificationsPage(),

        // Staff/Admin home
        '/staffHome': (context) => const HomeStaffPage(userRole: 'staff'),
        '/adminHome': (context) => const HomeStaffPage(userRole: 'admin'),
         
           // Customer home (placeholder) - replace with your real page
        '/customerHome': (context) => const HomeCustomerPage(),
        // Loan pages
        '/loanList': (ctx) => const LoanListPage(),
        '/loanContract': (context) => const LoanContractPage(),
        '/loanDetail': (ctx) => const LoanDetailPage(),
        '/repaymentList': (ctx) => const RepaymentListPage(),
        '/loanDetail': (context) => const LoanDetailPage(),
        '/loan_edit_address': (_) => const LoanEditAddressPage(),

        // Staff
        '/staffManagement': (ctx) => const StaffManagementPage(),
      },
    );
  }
}
