import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/customer_home_screen.dart';
import 'core/theme/app_theme.dart';

void main() async {
  // Ensure widget binding is initialized before calling Firebase.initializeApp()
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase backend
  await Firebase.initializeApp();

  runApp(
    // Register top-level providers here to separate state management from UI logic
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // Additional providers (e.g., AppointmentProvider, BranchProvider) go here
      ],
      child: const StyleHubApp(),
    ),
  );
}

class StyleHubApp extends StatelessWidget {
  const StyleHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StyleHub',
      theme: AppTheme.lightTheme,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (!auth.isInitialized) {
          return const SplashScreen();
        }
        if (auth.isAuthenticated) {
          return const CustomerHomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
