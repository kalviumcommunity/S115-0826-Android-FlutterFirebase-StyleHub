import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/branch_provider.dart';
import 'providers/service_provider.dart';
import 'providers/stylist_provider.dart';
import 'repositories/auth_repository.dart';
import 'repositories/booking_repository.dart';
import 'repositories/branch_repository.dart';
import 'repositories/service_repository.dart';
import 'repositories/stylist_repository.dart';
import 'repositories/firestore_repository.dart';
import 'routes/app_routes.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with the provisioned Firebase configuration FIRST
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    debugPrint('\n==================================================');
    debugPrint('PART 1 — VERIFY THE ACTUAL FIREBASE PROJECT AT RUNTIME');
    debugPrint('projectId: ${Firebase.app().options.projectId}');
    debugPrint('appId: ${Firebase.app().options.appId}');
    debugPrint('apiKey: ${Firebase.app().options.apiKey}');
    debugPrint('messagingSenderId: ${Firebase.app().options.messagingSenderId}');
    debugPrint('==================================================\n');

  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text(
              'Failed to initialize app: $e',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
    return; // Stop execution
  }

  // Instantiate singleton services NOW that Firebase is ready
  final authService = AuthService();
  final firestoreService = FirestoreService();
  final firestoreRepository = FirestoreRepository();

  // Automatically seed the database if it's empty
  try {
    await firestoreRepository.seedDatabaseIfEmpty();
  } catch (e) {
    debugPrint('Database seeding note: $e');
  }

  // Instantiate repositories
  final authRepository = AuthRepository(
    authService: authService,
    firestoreService: firestoreService,
  );
  final bookingRepository = BookingRepository(
    firestoreRepository: firestoreRepository,
  );
  final branchRepository = BranchRepository(firestoreService: firestoreService);
  final stylistRepository = StylistRepository(firestoreService: firestoreService);
  final serviceRepository = ServiceRepository(firestoreService: firestoreService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(authRepository: authRepository),
        ),
        ChangeNotifierProvider<BranchProvider>(
          create: (_) => BranchProvider(branchRepository: branchRepository),
        ),
        ChangeNotifierProvider<StylistProvider>(
          create: (_) => StylistProvider(stylistRepository: stylistRepository),
        ),
        ChangeNotifierProvider<ServiceProvider>(
          create: (_) => ServiceProvider(serviceRepository: serviceRepository),
        ),
        ChangeNotifierProvider<BookingProvider>(
          create: (_) => BookingProvider(bookingRepository: bookingRepository),
        ),
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
      title: 'StyleHub - Centralized Salon Network',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}
