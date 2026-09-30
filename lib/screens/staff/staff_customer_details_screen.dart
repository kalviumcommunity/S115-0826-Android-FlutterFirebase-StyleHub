import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/user_model.dart';
import '../../providers/booking_provider.dart';

class StaffCustomerDetailsScreen extends StatefulWidget {
  final UserModel customer;

  const StaffCustomerDetailsScreen({super.key, required this.customer});

  @override
  State<StaffCustomerDetailsScreen> createState() => _StaffCustomerDetailsScreenState();
}

class _StaffCustomerDetailsScreenState extends State<StaffCustomerDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().listenToCustomerAppointments(widget.customer.uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookingProv = context.watch<BookingProvider>();
    final history = bookingProv.customerAppointments;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.customer.name} Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Contact Info', style: AppTypography.titleLarge),
            const SizedBox(height: 8),
            Text('Email: ${widget.customer.email}', style: AppTypography.bodyMedium),
            Text('Phone: ${widget.customer.phone}', style: AppTypography.bodyMedium),
            Text('Gender: ${widget.customer.gender ?? "Not specified"}', style: AppTypography.bodyMedium),
            const SizedBox(height: 24),
            Text('Appointment History', style: AppTypography.titleLarge),
            const SizedBox(height: 8),
            if (history.isEmpty)
              const Text('No appointment history found.')
            else
              Expanded(
                child: ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (ctx, i) {
                    final apt = history[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text('${apt.serviceName} at ${apt.branchName}', style: AppTypography.titleMedium),
                        subtitle: Text('${apt.appointmentDate} ${apt.startTime}\nStatus: ${apt.status.toUpperCase()}'),
                        isThreeLine: true,
                        trailing: Text('₹${apt.servicePrice.toStringAsFixed(0)}', style: AppTypography.titleMedium.copyWith(color: AppColors.primary)),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
