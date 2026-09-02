import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'screens/splash_screen.dart';

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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // App starts with a Splash/Loading screen while Auth state is checked
      home: const SplashScreen(),
    );
  }
}
