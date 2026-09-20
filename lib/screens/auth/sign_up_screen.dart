import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stylehub/providers/auth_provider.dart';
import 'package:stylehub/widgets/primary_button.dart';
import 'package:stylehub/widgets/custom_text_field.dart';
import 'package:stylehub/core/theme/app_colors.dart';
import 'package:stylehub/core/theme/app_typography.dart';
import 'package:stylehub/core/theme/app_constants.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();
      await authProvider.signUp(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (mounted && authProvider.isAuthenticated) {
        Navigator.of(context).pushReplacementNamed('/customer-main');
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
                  const Icon(Icons.person_add_alt_1, size: 64, color: AppColors.primary),
                  const SizedBox(height: AppSpacing.l),
                  Text(
                    'Create Account',
                    textAlign: TextAlign.center,
                    style: AppTypography.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.m),
                  Text(
                    'Join StyleHub today',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  CustomTextField(
                    label: 'Full Name',
                    hint: 'John Doe',
                    controller: _nameController,
                    prefixIcon: const Icon(Icons.person_outline),
                    validator: (value) => value == null || value.isEmpty ? 'Please enter your name' : null,
                  ),
                  const SizedBox(height: AppSpacing.m),
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
                    validator: (value) => value == null || value.length < 6 ? 'Password must be 6+ chars' : null,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  PrimaryButton(
                    text: 'Sign Up',
                    isLoading: context.watch<AuthProvider>().isLoading,
                    onPressed: _handleSignUp,
                  ),
                  const SizedBox(height: AppSpacing.m),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      "Already have an account? Login",
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
