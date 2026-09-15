import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_constants.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../customer/customer_home_screen.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final bool isRescheduling;
  final String? existingAppointmentId;

  const BookingConfirmationScreen({
    super.key,
    this.isRescheduling = false,
    this.existingAppointmentId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<BookingProvider>(
      builder: (context, provider, child) {
        final branch = provider.selectedBranch;
        final service = provider.selectedService;
        final stylist = provider.selectedStylist;
        final date = provider.selectedDate;
        final time = provider.selectedTime;

        if (branch == null || service == null || stylist == null || date == null || time == null) {
          return const Scaffold(body: Center(child: Text('Missing booking data.')));
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(isRescheduling ? 'Confirm Reschedule' : 'Confirm Booking'),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  child: AppCard(
                    padding: const EdgeInsets.all(AppSpacing.l),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Booking Summary',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const Divider(height: 32),
                        _buildSummaryRow(context, Icons.store, 'Branch', branch.name),
                        const SizedBox(height: AppSpacing.m),
                        _buildSummaryRow(context, Icons.content_cut, 'Service', service.name),
                        const SizedBox(height: AppSpacing.m),
                        _buildSummaryRow(context, Icons.person, 'Stylist', stylist.name),
                        const SizedBox(height: AppSpacing.m),
                        _buildSummaryRow(context, Icons.calendar_today, 'Date', DateFormat('MMMM d, yyyy').format(date)),
                        const SizedBox(height: AppSpacing.m),
                        _buildSummaryRow(context, Icons.access_time, 'Time', DateFormat.jm().format(time)),
                        const Divider(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Price',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              '\$${service.price.toStringAsFixed(0)}',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (provider.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
                  child: Text(
                    provider.errorMessage!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.l),
                child: AppButton(
                  text: isRescheduling ? 'Confirm Reschedule' : 'Confirm Booking',
                  onPressed: () => _onConfirm(context, provider),
                  isLoading: provider.isLoading,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 20),
        const SizedBox(width: AppSpacing.s),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _onConfirm(BuildContext context, BookingProvider provider) async {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;
    
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: User not authenticated')),
      );
      return;
    }

    if (isRescheduling && existingAppointmentId != null) {
      await provider.rescheduleAppointment(
        appointmentId: existingAppointmentId!,
        newScheduledAt: provider.selectedTime!,
      );
    } else {
      await provider.bookAppointment(
        customerId: user.uid,
        customerName: user.name,
        branchId: provider.selectedBranch!.id,
        stylistId: provider.selectedStylist!.id,
        serviceId: provider.selectedService!.id,
        scheduledAt: provider.selectedTime!,
      );
    }

    if (provider.isSuccess && context.mounted) {
      provider.clearBookingState();
      
      // Navigate to Customer Home Screen on Appointments tab
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const CustomerHomeScreen(initialIndex: 1),
        ),
        (route) => false,
      );
    }
  }
}
