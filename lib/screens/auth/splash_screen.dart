import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stylehub/providers/auth_provider.dart';
import 'package:stylehub/core/theme/app_colors.dart';
import 'package:stylehub/core/theme/app_typography.dart';
import 'package:stylehub/core/theme/app_constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final authProvider = context.read<AuthProvider>();

    // Small delay to ensure splash is visible and app is initialized
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    if (authProvider.isAuthenticated) {
      final role = authProvider.userRole;
      if (role == 'admin' || role == 'staff') {
        Navigator.of(context).pushReplacementNamed('/staff-dashboard');
      } else {
        Navigator.of(context).pushReplacementNamed('/customer-main');
      }
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.content_cut, size: 80, color: AppColors.onPrimary),
            const SizedBox(height: AppSpacing.m),
            Text(
              'StyleHub',
              style: AppTypography.displaySmall.copyWith(
                color: AppColors.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
