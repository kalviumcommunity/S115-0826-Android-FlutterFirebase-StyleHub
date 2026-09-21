import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/widgets/app_error_widget.dart';
import '../../core/widgets/app_loading.dart';
import '../../models/appointment_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/domain_cards.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final bookingProvider = context.read<BookingProvider>();
      if (authProvider.currentUser != null) {
        bookingProvider.loadCustomerAppointments(authProvider.currentUser!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('My Appointments')),
      body: bookingProvider.customerAppointmentsStream == null
          ? const Center(child: Text('No appointments yet'))
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: bookingProvider.customerAppointmentsStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: AppErrorWidget(
                      message: 'Failed to load appointments',
                      onRetry: () {
                        final uid = context.read<AuthProvider>().currentUser?.uid;
                        if (uid != null) bookingProvider.loadCustomerAppointments(uid);
                      },
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: AppCircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text('No appointments yet',
                            style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                      ],
                    ),
                  );
                }

                final appointments = docs
                    .map((doc) => AppointmentModel.fromFirestore(doc))
                    .toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: appointments.length,
                  itemBuilder: (context, index) {
                    final appt = appointments[index];
                    return AppointmentCard(
                      appointment: appt,
                      onTap: () => _showAppointmentActions(context, appt),
                    );
                  },
                );
              },
            ),
    );
  }

  void _showAppointmentActions(BuildContext context, AppointmentModel appt) {
    final canCancel = appt.status == 'pending' || appt.status == 'confirmed';
    
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(appt.serviceName.isNotEmpty ? appt.serviceName : 'Appointment',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Status: ${appt.status.toUpperCase()}',
                style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 16),
            if (canCancel) ...[
              FilledButton.tonal(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await context.read<BookingProvider>().cancelAppointment(
                    appointmentId: appt.id,
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Appointment cancelled')),
                    );
                  }
                },
                child: const Text('Cancel Appointment'),
              ),
            ],
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}
