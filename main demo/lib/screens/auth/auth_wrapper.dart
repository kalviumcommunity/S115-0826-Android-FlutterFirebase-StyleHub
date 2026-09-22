import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../admin/admin_dashboard_screen.dart';
import '../customer/customer_main_screen.dart';
import '../staff/staff_dashboard_screen.dart';
import 'login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (!authProvider.isAuthenticated) {
      return const LoginScreen();
    }

    final role = authProvider.role;
    if (role == AppConstants.roleAdmin) {
      return const AdminDashboardScreen();
    } else if (role == AppConstants.roleStaff) {
      return const StaffDashboardScreen();
    } else {
      return const CustomerMainScreen();
    }
  }
}
