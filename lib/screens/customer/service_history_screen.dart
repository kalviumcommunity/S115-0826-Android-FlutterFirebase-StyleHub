import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stylehub/providers/booking_provider.dart';
import 'package:stylehub/widgets/data_state_view.dart';
import 'package:stylehub/widgets/domain_cards.dart';
import 'package:stylehub/core/theme/app_colors.dart';
import 'package:stylehub/core/theme/app_typography.dart';
import 'package:stylehub/core/theme/app_constants.dart';

class ServiceHistoryScreen extends StatefulWidget {
  const ServiceHistoryScreen({super.key});

  @override
  State<ServiceHistoryScreen> createState() => _ServiceHistoryScreenState();
}

class _ServiceHistoryScreenState extends State<ServiceHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookingProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Service History')),
      body: DataStateView<List<dynamic>>(
        isLoading: provider.isLoading,
        errorMessage: provider.errorMessage,
        isEmpty: provider.pastAppointments.isEmpty,
        data: provider.pastAppointments,
        successBuilder: (appointments) {
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.m),
            itemCount: appointments.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s),
            itemBuilder: (context, index) {
              final appt = appointments[index];
              return AppointmentCard(
                appointment: appt,
                onTap: () {},
              );
            },
          );
        },
      ),
    );
  }
}
