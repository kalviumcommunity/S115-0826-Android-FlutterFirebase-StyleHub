import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String? _error;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Create Account', style: Theme.of(context).textTheme.displayLarge),
              const SizedBox(height: 32),
              AppTextField(
                label: 'Name',
                controller: _nameCtrl,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Email',
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Phone',
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Password',
                controller: _passwordCtrl,
                obscureText: true,
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 32),
              AppButton(
                text: 'Register',
                isLoading: auth.isLoading,
                onPressed: () async {
                  setState(() => _error = null);
                  try {
                    await auth.register(
                      name: _nameCtrl.text,
                      email: _emailCtrl.text,
                      phone: _phoneCtrl.text,
                      password: _passwordCtrl.text,
                    );
                  } catch (e) {
                    setState(() => _error = 'Registration failed. Please check your inputs.');
                  }
                },
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go('/login'),
                child: const Text("Already have an account? Log in"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
