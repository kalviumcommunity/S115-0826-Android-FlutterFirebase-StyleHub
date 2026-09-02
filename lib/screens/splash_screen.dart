import 'package:flutter/material.dart';
import '../core/theme/app_constants.dart';

class SplashScreen extends StatelessWidget {
  /// Optional callback for navigation/authentication-state routing
  /// to be connected by another developer later.
  final VoidCallback? onInitializationComplete;

  const SplashScreen({
    super.key,
    this.onInitializationComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Branding / Logo area
              Container(
                padding: const EdgeInsets.all(AppSpacing.l),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.spa_rounded, // Using a standard icon as placeholder for logo
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              // App Title
              Text(
                'StyleHub',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: AppSpacing.s),
              // Tagline
              Text(
                'Your Salon, Reimagined',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white70,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
