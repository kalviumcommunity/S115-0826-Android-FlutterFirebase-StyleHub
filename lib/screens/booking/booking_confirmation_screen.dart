import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_constants.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';

class BookingConfirmationScreen extends StatelessWidget {
  const BookingConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();
    final authProvider = context.read<AuthProvider>();
    
    final branch = bookingProvider.selectedBranch;
    final service = bookingProvider.selectedService;
    final stylist = bookingProvider.selectedStylist;
    final date = bookingProvider.selectedDate;
    final timeSlot = bookingProvider.selectedTimeSlot;

    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Booking')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Booking Summary',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
            const SizedBox(height: AppSpacing.m),
            AppCard(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.m),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRow(context, 'Branch', branch?.name ?? '-'),
                    const Divider(),
                    _buildRow(context, 'Service', service?.name ?? '-'),
                    const Divider(),
                    _buildRow(context, 'Stylist', stylist?.name ?? '-'),
                    const Divider(),
                    _buildRow(context, 'Date',
                        date != null ? DateFormat('EEEE, MMM dd, yyyy').format(date) : '-'),
                    const Divider(),
                    _buildRow(context, 'Time', timeSlot ?? '-'),
                    const Divider(),
                    _buildRow(context, 'Duration',
                        service != null ? '${service.durationMinutes} minutes' : '-'),
                    const Divider(),
                    _buildRow(context, 'Price',
                        service != null ? '₹${service.price.toStringAsFixed(0)}' : '-',
                        isBold: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            if (bookingProvider.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.m),
                child: Text(bookingProvider.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center),
              ),
            AppButton(
              text: 'Confirm Booking',
              isLoading: bookingProvider.isLoading,
              onPressed: () async {
                final user = authProvider.currentUser;
                if (user != null) {
                  bookingProvider.setCustomerInfo(user.uid, user.name);
                  await bookingProvider.bookAppointment();
                  
                  if (bookingProvider.isSuccess && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Appointment booked successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    // Pop back to the branch list
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    bookingProvider.resetState();
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(BuildContext context, String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              )),
          Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                fontSize: isBold ? 18 : null,
              )),
        ],
      ),
    );
  }
}
