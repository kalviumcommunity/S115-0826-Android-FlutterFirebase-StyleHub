import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stylehub/providers/booking_provider.dart';
import 'package:stylehub/providers/auth_provider.dart';
import 'package:stylehub/models/appointment_model.dart';
import 'package:stylehub/widgets/domain_cards.dart';
import 'package:stylehub/core/theme/app_colors.dart';
import 'package:stylehub/core/theme/app_typography.dart';
import 'package:stylehub/core/theme/app_constants.dart';
import 'package:stylehub/core/widgets/app_loading.dart';
import 'package:stylehub/core/widgets/app_error_widget.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  late Stream<List<AppointmentModel>> _appointmentsStream;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final customerId = context.read<AuthProvider>().currentUser?.uid;
      if (customerId != null) {
        _appointmentsStream = context.read<BookingProvider>().getCustomerAppointmentsStream(customerId);
      } else {
        _appointmentsStream = const Stream.empty();
      }
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: StreamBuilder<List<AppointmentModel>>(
        stream: _appointmentsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: AppErrorWidget(
                  message: 'Failed to load bookings. Please try again.',
                  onRetry: () => setState(() {
                    _initialized = false;
                  }),
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: AppCircularProgressIndicator());
          }

          final allAppointments = snapshot.data ?? [];
          final upcomingAppointments = allAppointments.where((a) => a.status == 'pending' || a.status == 'confirmed').toList();

          if (upcomingAppointments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_month, size: 64, color: AppColors.secondary),
                  const SizedBox(height: AppSpacing.m),
                  Text(
                    'No upcoming bookings',
                    style: AppTypography.titleLarge.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.m),
            itemCount: upcomingAppointments.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s),
            itemBuilder: (context, index) {
              final appt = upcomingAppointments[index];
              return AppointmentCard(
                appointment: appt,
                onTap: () {
                  // Additional interactions if any
                },
              );
            },
          );
        },
      ),
    );
  }
}
