import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/confirmation_dialog.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../../providers/booking_provider.dart';

class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProv = context.watch<AuthProvider>();
    final user = authProv.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: AppColors.primaryLight,
                    child: Text(
                      user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'U',
                      style: AppTypography.displayMedium.copyWith(color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.name ?? 'Customer Name',
                    style: AppTypography.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? 'email@example.com',
                    style: AppTypography.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Unified Identity: ${user?.uid ?? "uid"}',
                      style: AppTypography.labelSmall.copyWith(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Profile info list
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.phone_outlined, color: AppColors.textSecondary),
                    title: const Text('Phone Number'),
                    subtitle: Text(user?.phone.isNotEmpty == true ? user!.phone : 'Not set'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.shield_outlined, color: AppColors.textSecondary),
                    title: const Text('Account Role'),
                    subtitle: Text(user?.role.toUpperCase() ?? 'CUSTOMER'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.storefront_outlined, color: AppColors.textSecondary),
                    title: const Text('Preferred Network'),
                    subtitle: const Text('StyleHub Multi-Branch Central'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Demo Role Switcher
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Switch Role (Demo Mode)', style: AppTypography.titleMedium.copyWith(fontSize: 14)),
                  const SizedBox(height: 6),
                  Text(
                    'Quickly test the application flow as a Staff member or HQ Admin.',
                    style: AppTypography.bodyMedium.copyWith(fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            context.read<BookingProvider>().clearAllListeners();
                            authProv.switchRole(AppConstants.roleStaff);
                            Navigator.of(context).pushReplacementNamed(AppRoutes.staffDashboard);
                          },
                          child: const Text('Staff View'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            context.read<BookingProvider>().clearAllListeners();
                            authProv.switchRole(AppConstants.roleAdmin);
                            Navigator.of(context).pushReplacementNamed(AppRoutes.adminDashboard);
                          },
                          child: const Text('Admin HQ'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            AppButton(
              label: 'Sign Out',
              variant: AppButtonVariant.outline,
              icon: Icons.logout,
              onPressed: () async {
                final confirm = await ConfirmationDialog.show(
                  context,
                  title: 'Sign Out?',
                  message: 'Are you sure you want to log out of StyleHub?',
                  confirmLabel: 'Sign Out',
                );
                if (confirm == true) {
                  context.read<BookingProvider>().clearAllListeners();
                  await authProv.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
