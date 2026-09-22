import 'package:flutter/material.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/customer/customer_main_screen.dart';
import '../screens/customer/booking_flow_screen.dart';
import '../screens/staff/staff_dashboard_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String customerMain = '/customer-main';
  static const String bookingFlow = '/booking-flow';
  static const String staffDashboard = '/staff-dashboard';
  static const String adminDashboard = '/admin-dashboard';

  static Map<String, WidgetBuilder> get routes {
    return {
      splash: (context) => const SplashScreen(),
      login: (context) => const LoginScreen(),
      signup: (context) => const SignupScreen(),
      customerMain: (context) => const CustomerMainScreen(),
      bookingFlow: (context) => const BookingFlowScreen(),
      staffDashboard: (context) => const StaffDashboardScreen(),
      adminDashboard: (context) => const AdminDashboardScreen(),
    };
  }
}
