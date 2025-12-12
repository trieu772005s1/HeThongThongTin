import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// AUTH
import 'package:fl_credit/pages/login_page.dart';
import 'package:fl_credit/pages/register_screen.dart';
import 'package:fl_credit/pages/auth/forgot_password_page.dart';
import 'package:fl_credit/pages/auth/verify_otp_page.dart';
import 'package:fl_credit/pages/auth/reset_password_page.dart';

// HOME
import 'package:fl_credit/pages/home/home_selector.dart';
import 'package:fl_credit/pages/home/notification_page.dart';
import 'package:fl_credit/pages/home/home_staff_page.dart';

// USER WARDROBE
import 'package:fl_credit/pages/the_loan/wardrobe/wardrobe_page.dart';
import 'package:fl_credit/pages/the_loan/wardrobe/reward_list_page.dart';
import 'package:fl_credit/pages/the_loan/wardrobe/voucher_list_page.dart';
import 'package:fl_credit/pages/the_loan/wardrobe/promotion_list_page.dart';

// ADMIN WARDROBE
import 'package:fl_credit/pages/admin/wardrobe/admin_user_list_page.dart';
import 'package:fl_credit/pages/admin/wardrobe/admin_user_benefit_page.dart';

// ADMIN PROMOTION
import 'package:fl_credit/pages/admin/promotion/admin_promotion_list.dart';
import 'package:fl_credit/pages/admin/promotion/admin_promotion_form.dart';

// THEME
import 'package:fl_credit/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FL CREDIT',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,

      initialRoute: '/',

      routes: {
        // AUTH
        '/': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/forgotPassword': (context) => ForgotPasswordPage(),
        '/verifyOtp': (context) => VerifyOtpPage(),
        '/resetPassword': (context) => ResetPasswordPage(),

        // HOME
        '/home': (context) => HomeSelectorPage(),
        '/notifications': (context) => NotificationsPage(),

        '/staffHome': (context) => HomeStaffPage(userRole: 'staff'),
        '/adminHome': (context) => HomeStaffPage(userRole: 'admin'),

        // USER WARDROBE
        '/wardrobe': (context) => WardrobePage(),
        '/rewards': (context) => RewardListPage(),
        '/vouchers': (context) => VoucherListPage(),
        '/promotions': (context) => PromotionListPage(),

        // ADMIN
        '/admin-user-list': (context) => AdminUserListPage(),

        // ADMIN USER BENEFIT – nhận args
        '/admin-user-benefit': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map;
          return AdminUserBenefitPage(
            userId: args['userId'],
            userName: args['userName'],
          );
        },

        // ADMIN PROMOTION
        '/admin-promotions': (context) => AdminPromotionList(),
        '/admin-promotion-create': (context) => AdminPromotionForm(),
      },
    );
  }
}
