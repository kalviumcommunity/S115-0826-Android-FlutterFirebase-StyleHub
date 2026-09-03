import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'repositories/auth_repository.dart';
import 'screens/splash_screen.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';

void main() async {
  // Ensure widget binding is initialized before calling Firebase.initializeApp()
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase backend.
  //
  // NOTE: After running `flutterfire configure`, uncomment the import and
  // options parameter below to use the generated configuration:
  //
  //   import 'firebase_options.dart';
  //   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  //
  // Until then, Firebase.initializeApp() without options works when
  // google-services.json is present in android/app/.
  await Firebase.initializeApp();

  // ---------------------------------------------------------------------------
  // Dependency Injection: Build the layer stack bottom-up.
  //
  // Service Layer  → talks to Firebase
  // Repository Layer → orchestrates Services, maps errors, enforces business rules
  // Provider Layer → exposes state to UI via ChangeNotifier
  //
  // This wiring ensures the Layered Architecture (TRD §1) is enforced at
  // the composition root.
  // ---------------------------------------------------------------------------
  final authService = AuthService();
  final firestoreService = FirestoreService();

  final authRepository = AuthRepository(
    authService: authService,
    firestoreService: firestoreService,
  );

  runApp(
    // Register top-level providers here to separate state management from UI logic
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authRepository: authRepository),
        ),
        // Additional providers (e.g., AppointmentProvider, BranchProvider) go here.
        // Each should follow the same pattern:
        //   ChangeNotifierProvider(create: (_) => XxxProvider(repository: xxxRepository)),
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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // App starts with a Splash/Loading screen while Auth state is checked
      home: const SplashScreen(),
    );
  }
}
