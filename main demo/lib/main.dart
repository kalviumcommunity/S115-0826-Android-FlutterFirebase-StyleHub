import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
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
import 'routes/app_routes.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with the provisioned Firebase configuration
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization note: $e');
  }

  // Instantiate singleton services
  final authService = AuthService();
  final firestoreService = FirestoreService();

  // Instantiate repositories
  final authRepository = AuthRepository(
    authService: authService,
    firestoreService: firestoreService,
  );
  final bookingRepository = BookingRepository(firestoreService: firestoreService);
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
