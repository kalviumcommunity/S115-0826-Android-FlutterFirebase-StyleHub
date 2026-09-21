import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_constants.dart';
import '../../core/widgets/app_loading.dart';
import '../../core/widgets/app_error_widget.dart';
import '../../models/appointment_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/domain_cards.dart';

class BranchAppointmentsScreen extends StatefulWidget {
  const BranchAppointmentsScreen({super.key});

  @override
  State<BranchAppointmentsScreen> createState() => _BranchAppointmentsScreenState();
}

class _BranchAppointmentsScreenState extends State<BranchAppointmentsScreen> {
  Stream<QuerySnapshot<Map<String, dynamic>>>? _appointmentsStream;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final branchId = context.read<AuthProvider>().currentUser?.branchId;
      if (branchId != null && branchId.isNotEmpty) {
        setState(() {
          _appointmentsStream = FirebaseFirestore.instance
              .collection('appointments')
              .where('branchId', isEqualTo: branchId)
              .orderBy('scheduledAt', descending: false)
              .snapshots();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Branch Appointments')),
      body: _appointmentsStream == null
          ? const Center(child: Text('No branch assigned'))
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _appointmentsStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: AppErrorWidget(
                    message: 'Failed to load appointments',
                    onRetry: () => setState(() {}),
                  ));
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
                        Text('No appointments',
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
                      onTap: () => _showStaffActions(context, appt),
                    );
                  },
                );
              },
            ),
    );
  }

  void _showStaffActions(BuildContext context, AppointmentModel appt) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('${appt.customerName.isNotEmpty ? appt.customerName : 'Customer'} - ${appt.serviceName.isNotEmpty ? appt.serviceName : 'Service'}',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text('Status: ${appt.status.toUpperCase()} • ${DateFormat('MMM dd, hh:mm a').format(appt.scheduledAt)}',
                style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 16),
            if (appt.status == 'pending')
              FilledButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await _updateStatus(appt.id, 'confirmed');
                },
                child: const Text('Confirm'),
              ),
            if (appt.status == 'pending' || appt.status == 'confirmed') ...[
              const SizedBox(height: 8),
              FilledButton.tonal(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await context.read<BookingProvider>().completeAppointment(
                    appointmentId: appt.id,
                    customerId: appt.customerId,
                    branchId: appt.branchId,
                    branchName: appt.branchName,
                    stylistId: appt.stylistId,
                    stylistName: appt.stylistName,
                    serviceId: appt.serviceId,
                    serviceName: appt.serviceName,
                    price: appt.price,
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Appointment completed')),
                    );
                  }
                },
                child: const Text('Mark Complete'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await context.read<BookingProvider>().cancelAppointment(appointmentId: appt.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Appointment cancelled')),
                    );
                  }
                },
                child: const Text('Cancel'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await _updateStatus(appt.id, 'no_show');
                },
                child: const Text('Mark No-Show', style: TextStyle(color: Colors.red)),
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

  Future<void> _updateStatus(String appointmentId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(appointmentId)
          .update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status updated to $newStatus')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: $e')),
        );
      }
    }
  }
}
