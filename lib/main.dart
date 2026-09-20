import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'package:stylehub/core/app_router.dart';
import 'package:stylehub/core/auth_wrapper.dart';
import 'package:stylehub/core/theme/app_theme.dart';
import 'package:stylehub/providers/auth_provider.dart';
import 'package:stylehub/providers/booking_provider.dart';
import 'package:stylehub/providers/reference_data_provider.dart';
import 'package:stylehub/providers/staff_dashboard_provider.dart';
import 'package:stylehub/repositories/appointment_repository.dart';
import 'package:stylehub/repositories/auth_repository.dart';
import 'package:stylehub/repositories/branch_repository.dart';
import 'package:stylehub/repositories/service_repository.dart';
import 'package:stylehub/repositories/staff_repository.dart';
import 'package:stylehub/repositories/stylist_repository.dart';
import 'package:stylehub/services/appointment_service.dart';
import 'package:stylehub/services/auth_service.dart';
import 'package:stylehub/services/firestore_service.dart';
import 'package:stylehub/services/operations_service.dart';
import 'package:stylehub/services/storage_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final authService = AuthService();
  final firestoreService = FirestoreService();
  final storageService = StorageService();
  final appointmentService = AppointmentService(firestore: null);

  final authRepository = AuthRepository(
    authService: authService,
    firestoreService: firestoreService,
  );
  final appointmentRepository = AppointmentRepository(
    appointmentService: appointmentService,
  );
  final staffRepository = StaffRepository(
    operationsService: OperationsService(firestore: firestoreService),
  );
  final branchRepository = BranchRepository(firestoreService: firestoreService);
  final stylistRepository = StylistRepository(firestoreService: firestoreService);
  final serviceRepository = ServiceRepository(firestoreService: firestoreService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authRepository: authRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => BookingProvider(appointmentRepository: appointmentRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => StaffDashboardProvider(repository: staffRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => ReferenceDataProvider(
            branchRepository: branchRepository,
            stylistRepository: stylistRepository,
            serviceRepository: serviceRepository,
          ),
        ),
        Provider<FirestoreService>.value(value: firestoreService),
        Provider<StorageService>.value(value: storageService),
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
