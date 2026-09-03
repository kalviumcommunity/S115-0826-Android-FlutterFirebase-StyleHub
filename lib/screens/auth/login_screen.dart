import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/app_error_widget.dart';
import '../../providers/auth_provider.dart';
import 'signup_screen.dart';

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

  void _onLoginPressed(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      final authProvider = context.read<AuthProvider>();
      await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      // Navigation is handled globally by the AuthWrapper in main.dart
      // when the auth state changes.
    }
  }

  void _onSignUpPressed(BuildContext context) {
    context.read<AuthProvider>().clearError();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SignUpScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.spa_rounded,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: AppSpacing.l),
                  Text(
                    'Welcome Back',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.s),
                  Text(
                    'Login to continue to StyleHub',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  
                  Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      return AppErrorWidget(message: auth.errorMessage);
                    },
                  ),
                  
                  AppTextField(
                    labelText: 'Email',
                    hintText: 'Enter your email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email is required';
                      }
                      if (!value.contains('@')) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                  AppTextField(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    controller: _passwordController,
                    isPassword: true,
                    prefixIcon: Icons.lock_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.m),
                  
                  Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      return AppButton(
                        text: 'Login',
                        isLoading: auth.isLoading,
                        onPressed: () => _onLoginPressed(context),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.m),
                  
                  AppButton(
                    text: 'Don\'t have an account? Sign Up',
                    type: AppButtonType.text,
                    onPressed: () => _onSignUpPressed(context),
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
