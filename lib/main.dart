import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'core/auth_wrapper.dart';
import 'core/theme/app_theme.dart';
import 'providers/booking_provider.dart';
import 'repositories/appointment_repository.dart';
import 'repositories/auth_repository.dart';
import 'services/appointment_service.dart';
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
  final appointmentService = AppointmentService(firestore: null); // Defaults to instance

  final authRepository = AuthRepository(
    authService: authService,
    firestoreService: firestoreService,
  );
  final appointmentRepository = AppointmentRepository(
    appointmentService: appointmentService,
  );

  runApp(
    // Register top-level providers here to separate state management from UI logic
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authRepository: authRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => BookingProvider(appointmentRepository: appointmentRepository),
        ),
        // Additional providers (e.g., BranchProvider) go here.
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
      theme: AppTheme.lightTheme,
      // App starts with AuthWrapper to determine routing based on Role
      home: const AuthWrapper(),
    );
  }
}
