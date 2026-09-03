import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/theme/app_constants.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  void _onLogoutPressed(BuildContext context) {
    context.read<AuthProvider>().signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Profile Content'),
              const SizedBox(height: AppSpacing.l),
              AppButton(
                text: 'Logout',
                type: AppButtonType.secondary,
                onPressed: () => _onLogoutPressed(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
