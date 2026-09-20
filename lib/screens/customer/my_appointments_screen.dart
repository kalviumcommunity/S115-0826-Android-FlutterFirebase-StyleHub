import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stylehub/providers/booking_provider.dart';
import 'package:stylehub/widgets/data_state_view.dart';
import 'package:stylehub/widgets/domain_cards.dart';
import 'package:stylehub/core/theme/app_colors.dart';
import 'package:stylehub/core/theme/app_typography.dart';
import 'package:stylehub/core/theme/app_constants.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookingProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: DataStateView<List<dynamic>>(
        isLoading: provider.isLoading,
        errorMessage: provider.errorMessage,
        isEmpty: provider.upcomingAppointments.isEmpty,
        data: provider.upcomingAppointments,
        successBuilder: (appointments) {
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.m),
            itemCount: appointments.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s),
            itemBuilder: (context, index) {
              final appt = appointments[index];
              return AppointmentCard(
                appointment: appt,
                onTap: () {
                  // Open details or cancel dialog
                },
              );
            },
          );
        },
      ),
    );
  }
}
