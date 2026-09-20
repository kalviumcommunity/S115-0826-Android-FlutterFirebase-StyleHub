import 'package:flutter/material.dart';
import 'package:stylehub/screens/auth/splash_screen.dart';
import 'package:stylehub/screens/auth/login_screen.dart';
import 'package:stylehub/screens/auth/sign_up_screen.dart';
import 'package:stylehub/screens/customer/customer_main_scaffold.dart';
import 'package:stylehub/screens/customer/branch_list_screen.dart';
import 'package:stylehub/screens/customer/branch_details_screen.dart';
import 'package:stylehub/screens/booking/service_selection_screen.dart';
import 'package:stylehub/models/branch_model.dart';
import 'package:stylehub/screens/customer/my_appointments_screen.dart';
import 'package:stylehub/screens/customer/service_history_screen.dart';
import 'package:stylehub/screens/customer/profile_screen.dart';
import 'package:stylehub/screens/staff/staff_dashboard_screen.dart';
import 'package:stylehub/screens/staff/customer_search_screen.dart'; // Note: You might need to create this if not already done
import 'package:stylehub/screens/staff/returning_customer_profile_screen.dart'; // Note: You might need to create this if not already done
import 'package:stylehub/screens/admin/admin_management_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/signup':
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      case '/customer-main':
        return MaterialPageRoute(builder: (_) => const CustomerMainScaffold());
      case '/branch-list':
        return MaterialPageRoute(builder: (_) => const BranchListScreen());
      case '/branch-details':
        return MaterialPageRoute(builder: (_) => const BranchDetailsScreen());
      case '/service-selection':
        final branch = settings.arguments as BranchModel;
        return MaterialPageRoute(builder: (_) => ServiceSelectionScreen(branch: branch));
      case '/my-appointments':
        return MaterialPageRoute(builder: (_) => const MyAppointmentsScreen());
      case '/service-history':
        return MaterialPageRoute(builder: (_) => const ServiceHistoryScreen());
      case '/profile':
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case '/staff-dashboard':
        return MaterialPageRoute(builder: (_) => const StaffDashboardScreen());
      case '/customer-search':
        return MaterialPageRoute(builder: (_) => const CustomerSearchScreen());
      case '/customer-profile':
        return MaterialPageRoute(builder: (_) => const ReturningCustomerProfileScreen());
      case '/admin-management':
        return MaterialPageRoute(builder: (_) => const AdminManagementScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
