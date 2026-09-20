import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stylehub/providers/auth_provider.dart';
import 'package:stylehub/widgets/primary_button.dart';
import 'package:stylehub/widgets/custom_text_field.dart';
import 'package:stylehub/core/theme/app_colors.dart';
import 'package:stylehub/core/theme/app_typography.dart';
import 'package:stylehub/core/theme/app_constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();
      await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (mounted && authProvider.isAuthenticated) {
        // Role routing handled by SplashScreen or here directly
        final role = authProvider.userRole;
        if (role == 'admin' || role == 'staff') {
          Navigator.of(context).pushReplacementNamed('/staff-dashboard');
        } else {
          Navigator.of(context).pushReplacementNamed('/customer-main');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.lock_outline, size: 64, color: AppColors.primary),
                  const SizedBox(height: AppSpacing.l),
                  Text(
                    'Welcome Back',
                    textAlign: TextAlign.center,
                    style: AppTypography.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.m),
                  Text(
                    'Login to manage your style',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  CustomTextField(
                    label: 'Email',
                    hint: 'email@example.com',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.email_outlined),
                    validator: (value) => value == null || value.isEmpty ? 'Please enter email' : null,
                  ),
                  const SizedBox(height: AppSpacing.m),
                  CustomTextField(
                    label: 'Password',
                    hint: '••••••••',
                    controller: _passwordController,
                    isPassword: true,
                    prefixIcon: const Icon(Icons.lock_outlined),
                    validator: (value) => value == null || value.isEmpty ? 'Please enter password' : null,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  PrimaryButton(
                    text: 'Login',
                    isLoading: context.watch<AuthProvider>().isLoading,
                    onPressed: _handleLogin,
                  ),
                  const SizedBox(height: AppSpacing.m),
                  TextButton(
                    onPressed: () => Navigator.of(context).pushNamed('/signup'),
                    child: Text(
                      "Don't have an account? Sign Up",
                      style: AppTypography.labelMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
