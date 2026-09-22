import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../core/widgets/confirmation_dialog.dart';
import '../../models/appointment_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import 'booking_flow_screen.dart';
import 'widgets/booking_card.dart';

class CustomerAppointmentsScreen extends StatelessWidget {
  final VoidCallback onStartBooking;

  const CustomerAppointmentsScreen({
    super.key,
    required this.onStartBooking,
  });

  @override
  Widget build(BuildContext context) {
    final bookingProv = context.watch<BookingProvider>();
    final upcoming = bookingProv.upcomingAppointments;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
      ),
      body: upcoming.isEmpty
          ? EmptyStateWidget(
              icon: Icons.calendar_today_outlined,
              title: 'No Upcoming Appointments',
              message: 'You do not have any pending or confirmed bookings scheduled.',
              actionLabel: 'Book Now',
              onAction: onStartBooking,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: upcoming.length,
              itemBuilder: (context, index) {
                final apt = upcoming[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: BookingCard(
                    appointment: apt,
                    onCancel: () async {
                      final confirmed = await ConfirmationDialog.show(
                        context,
                        title: 'Cancel Appointment?',
                        message: 'Are you sure you want to cancel your ${apt.serviceName} booking at ${apt.branchName}?',
                        confirmLabel: 'Yes, Cancel',
                        isDestructive: true,
                      );
                      if (confirmed == true) {
                        await bookingProv.updateStatus(apt.appointmentId, AppConstants.statusCancelled);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Appointment cancelled')),
                          );
                        }
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}
