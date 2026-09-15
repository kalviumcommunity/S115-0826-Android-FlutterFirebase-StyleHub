import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../core/constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_constants.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_error_widget.dart';
import '../../../models/appointment_model.dart';
import '../../../models/stylist_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/booking_provider.dart';
import '../../booking/date_time_selection_screen.dart';

class AppointmentsTab extends StatefulWidget {
  const AppointmentsTab({super.key});

  @override
  State<AppointmentsTab> createState() => _AppointmentsTabState();
}

class _AppointmentsTabState extends State<AppointmentsTab> {
  late Stream<QuerySnapshot<Map<String, dynamic>>> _appointmentsStream;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = context.read<AuthProvider>().currentUser?.uid;
    _initStream();
  }

  void _initStream() {
    if (_currentUserId == null) return;
    
    _appointmentsStream = FirebaseFirestore.instance
        .collection(FirestoreCollections.appointments)
        .where('customerId', isEqualTo: _currentUserId)
        .orderBy('scheduledAt', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUserId == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please log in to view your appointments.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _appointmentsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.m),
                child: AppErrorWidget(
                  message: 'Failed to load appointments.',
                  onRetry: () => setState(_initStream),
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: AppSpacing.m),
                  Text(
                    'No appointments yet',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            );
          }

          final appointments = docs.map((doc) => AppointmentModel.fromFirestore(doc)).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.m),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              return _AppointmentCard(appointment: appointments[index]);
            },
          );
        },
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;

  const _AppointmentCard({required this.appointment});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'completed':
        return AppColors.primary;
      case 'cancelled':
      case 'no_show':
        return AppColors.error;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPending = appointment.status == 'pending';
    final bookingProvider = context.watch<BookingProvider>();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.m),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('EEEE, MMM d').format(appointment.scheduledAt),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(appointment.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    appointment.status.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(appointment.status),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  DateFormat.jm().format(appointment.scheduledAt),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                const Icon(Icons.content_cut, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text('Service ID: ${appointment.serviceId}'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text('Stylist ID: ${appointment.stylistId}'),
              ],
            ),
            if (isPending) ...[
              const SizedBox(height: AppSpacing.m),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: bookingProvider.isLoading 
                          ? null 
                          : () => _showCancelDialog(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: AppButton(
                      text: 'Reschedule',
                      onPressed: bookingProvider.isLoading 
                          ? null 
                          : () => _startRescheduleFlow(context),
                      isLoading: false,
                    ),
                  ),
                ],
              ),
              if (bookingProvider.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.s),
                  child: Text(
                    bookingProvider.errorMessage!,
                    style: const TextStyle(color: AppColors.error, fontSize: 12),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content: const Text('Are you sure you want to cancel this appointment? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('No, Keep it'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<BookingProvider>().cancelAppointment(
                appointmentId: appointment.id,
              );
            },
            child: const Text('Yes, Cancel', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Future<void> _startRescheduleFlow(BuildContext context) async {
    final bookingProvider = context.read<BookingProvider>();
    
    // We need to fetch the StylistModel to know the stylist's details for time slots.
    // In a production app, we might already have it cached, or we should show a loading indicator.
    // Here we'll just fetch it quickly.
    try {
      final stylistDoc = await FirebaseFirestore.instance
          .collection(FirestoreCollections.stylists)
          .doc(appointment.stylistId)
          .get();
          
      if (stylistDoc.exists && context.mounted) {
        final stylist = StylistModel.fromFirestore(stylistDoc);
        bookingProvider.setStylist(stylist);
        
        // Navigate to Date/Time Selection for rescheduling
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DateTimeSelectionScreen(
              isRescheduling: true,
              existingAppointmentId: appointment.id,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to initialize reschedule flow.')),
        );
      }
    }
  }
}
