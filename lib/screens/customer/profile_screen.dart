import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_constants.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.phone;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authProvider.signOut(),
          ),
        ],
      ),
      body: user == null
          ? const Center(child: Text('Not signed in'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: Column(
                children: [
                  // Profile Photo
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: user.profileImageUrl != null
                            ? NetworkImage(user.profileImageUrl!)
                            : null,
                        child: user.profileImageUrl == null
                            ? Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                                style: const TextStyle(fontSize: 36))
                            : null,
                      ),
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.primary,
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                          onPressed: () {
                            // TODO: Wire image_picker + StorageService
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Photo upload coming soon')),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.l),

                  // Email (read-only)
                  ListTile(
                    leading: const Icon(Icons.email_outlined),
                    title: const Text('Email'),
                    subtitle: Text(user.email),
                  ),
                  ListTile(
                    leading: const Icon(Icons.badge_outlined),
                    title: const Text('Role'),
                    subtitle: Text(user.role.toUpperCase()),
                  ),
                  const Divider(),
                  const SizedBox(height: AppSpacing.m),

                  // Editable fields
                  AppTextField(
                    labelText: 'Name',
                    hintText: 'Enter your name',
                    controller: _nameController,
                    prefixIcon: Icons.person_outline,
                  ),
                  const SizedBox(height: AppSpacing.m),
                  AppTextField(
                    labelText: 'Phone',
                    hintText: 'Enter your phone number',
                    controller: _phoneController,
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: AppSpacing.l),

                  AppButton(
                    text: 'Update Profile',
                    isLoading: authProvider.isLoading,
                    onPressed: () async {
                      final updatedUser = user.copyWith(
                        name: _nameController.text.trim(),
                        phone: _phoneController.text.trim(),
                      );
                      // TODO: Call authRepository.updateUserProfile(updatedUser)
                      // For now, show feedback
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profile update coming soon')),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
