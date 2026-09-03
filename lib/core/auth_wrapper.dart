import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/customer/customer_home_screen.dart';
import '../screens/staff/staff_dashboard_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';

/// Core Routing Logic
/// This widget listens to [AuthProvider] and routes to the correct application
/// flow based on the user's role, strictly adhering to the PRD.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // Handle Loading State
    if (authProvider.isLoading) {
      return const SplashScreen();
    }

    // Handle Empty/Unauthenticated State
    if (!authProvider.isAuthenticated) {
      return const LoginScreen();
    }

    // Handle Success/Authenticated State - Route by Role
    final role = authProvider.userRole;
    
    switch (role) {
      case 'customer':
        return const CustomerHomeScreen();
      case 'staff':
        return const StaffDashboardScreen();
      case 'admin':
        return const AdminDashboardScreen();
      default:
        // Handle Error State for unrecognized roles
        return const Scaffold(
          body: Center(
            child: Text('Error: Unrecognized user role.'),
          ),
        );
    }
  }
}
