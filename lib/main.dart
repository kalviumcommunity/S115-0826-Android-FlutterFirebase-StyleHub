import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'core/auth_wrapper.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/reference_data_provider.dart';
import 'providers/staff_dashboard_provider.dart';
import 'repositories/appointment_repository.dart';
import 'repositories/auth_repository.dart';
import 'repositories/branch_repository.dart';
import 'repositories/service_repository.dart';
import 'repositories/staff_repository.dart';
import 'repositories/stylist_repository.dart';
import 'services/appointment_service.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'services/operations_service.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Service Layer
  final authService = AuthService();
  final firestoreService = FirestoreService();
  final appointmentService = AppointmentService();
  final storageService = StorageService();
  final operationsService = OperationsService(firestoreService: firestoreService);

  // Repository Layer
  final authRepository = AuthRepository(authService: authService, firestoreService: firestoreService);
  final appointmentRepository = AppointmentRepository(appointmentService: appointmentService);
  final branchRepository = BranchRepository(firestoreService: firestoreService);
  final stylistRepository = StylistRepository(firestoreService: firestoreService);
  final serviceRepository = ServiceRepository(firestoreService: firestoreService);
  final staffRepository = StaffRepository(firestoreService: firestoreService);

  runApp(
    MultiProvider(
      providers: [
        Provider<FirestoreService>.value(value: firestoreService),
        Provider<StorageService>.value(value: storageService),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authRepository: authRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => BookingProvider(appointmentRepository: appointmentRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => ReferenceDataProvider(
            branchRepository: branchRepository,
            stylistRepository: stylistRepository,
            serviceRepository: serviceRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => StaffDashboardProvider(
            staffRepository: staffRepository,
            operationsService: operationsService,
          ),
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
      title: 'StyleHub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthWrapper(),
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
