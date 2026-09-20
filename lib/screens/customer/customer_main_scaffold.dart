import 'package:flutter/material.dart';
import 'package:stylehub/core/theme/app_colors.dart';
import 'package:stylehub/core/theme/app_typography.dart';
import 'package:stylehub/screens/customer/branch_list_screen.dart';
import 'package:stylehub/screens/customer/my_appointments_screen.dart';
import 'package:stylehub/screens/customer/service_history_screen.dart';
import 'package:stylehub/screens/customer/profile_screen.dart';

class CustomerMainScaffold extends StatefulWidget {
  const CustomerMainScaffold({super.key});

  @override
  State<CustomerMainScaffold> createState() => _CustomerMainScaffoldState();
}

class _CustomerMainScaffoldState extends State<CustomerMainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const BranchListScreen(),
    const MyAppointmentsScreen(),
    const ServiceHistoryScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.secondary,
        selectedLabelStyle: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.bold),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.storefront), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Bookings'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
