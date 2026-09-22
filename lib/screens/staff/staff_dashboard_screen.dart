import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../models/appointment_model.dart';
import '../../models/branch_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/branch_provider.dart';
import '../../routes/app_routes.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class StaffDashboardScreen extends StatefulWidget {
  const StaffDashboardScreen({super.key});

  @override
  State<StaffDashboardScreen> createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends State<StaffDashboardScreen> {
  String _selectedStatusFilter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final branchId = auth.currentUser?.assignedBranchId;
      _runDiagnostics(branchId);
      if (branchId != null && branchId.isNotEmpty) {
        context.read<BookingProvider>().listenToBranchAppointments(branchId);
      }
    });
  }

  Future<void> _runDiagnostics(String? assignedBranchId) async {
    debugPrint('\n==================================================');
    debugPrint('PART 3 — VERIFY AUTH TOKEN / USER');
    final user = FirebaseAuth.instance.currentUser;
    debugPrint('uid: ${user?.uid}');
    debugPrint('email: ${user?.email}');
    debugPrint('emailVerified: ${user?.emailVerified}');
    
    try {
      await user?.getIdToken(true);
      debugPrint('Force-refresh ID token: SUCCESS');
    } catch (e) {
      debugPrint('Force-refresh ID token: FAILED - $e');
    }

    debugPrint('\n==================================================');
    debugPrint('PART 7 — VERIFY STAFF USER DOCUMENT');
    if (user != null) {
      try {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        debugPrint('Staff Doc exists: ${userDoc.exists}');
        debugPrint('role: ${userDoc.data()?['role']}');
        debugPrint('assignedBranchId: ${userDoc.data()?['assignedBranchId']}');
        debugPrint('name: ${userDoc.data()?['name']}');
        debugPrint('email: ${userDoc.data()?['email']}');
      } catch (e) {
        debugPrint('Error reading staff user doc: $e');
      }
    }

    debugPrint('\n==================================================');
    debugPrint('PART 6 — DEBUG STAFF QUERY');
    debugPrint('STAFF QUERY START');
    debugPrint('uid = ${user?.uid}');
    debugPrint('assignedBranchId = $assignedBranchId');
    debugPrint('EXACT QUERY: appointments where branchId == $assignedBranchId');

    debugPrint('\n==================================================');
    debugPrint('PART 2 — DIRECT FIRESTORE READ TEST');
    debugPrint('DIRECT FIRESTORE TEST START');
    debugPrint('projectId: ${Firebase.app().options.projectId}');
    
    try {
      final aptQuery = await FirebaseFirestore.instance.collection('appointments').limit(1).get();
      debugPrint('collection: appointments');
      debugPrint('result document count: ${aptQuery.docs.length}');
      if (aptQuery.docs.isNotEmpty) {
        debugPrint('First doc ID: ${aptQuery.docs.first.id}');
        debugPrint('First doc branchId: ${aptQuery.docs.first.data()['branchId']}');
      }
    } catch (e) {
      debugPrint('collection: appointments -> FAILED');
      if (e is FirebaseException) {
        debugPrint('exception code: ${e.code}');
        debugPrint('exception message: ${e.message}');
      } else {
        debugPrint('exception: $e');
      }
    }

    try {
      final slotQuery = await FirebaseFirestore.instance.collection('appointmentSlots').limit(1).get();
      debugPrint('\ncollection: appointmentSlots');
      debugPrint('result document count: ${slotQuery.docs.length}');
    } catch (e) {
      debugPrint('collection: appointmentSlots -> FAILED');
      if (e is FirebaseException) {
        debugPrint('exception code: ${e.code}');
        debugPrint('exception message: ${e.message}');
      } else {
        debugPrint('exception: $e');
      }
    }
    debugPrint('==================================================\n');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = context.watch<AuthProvider>();
    final newBranchId = auth.currentUser?.assignedBranchId;
    if (newBranchId != null) {
      context.read<BookingProvider>().listenToBranchAppointments(newBranchId);
    }
  }

  void _showStatusUpdateDialog(AppointmentModel apt) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Update Appointment Status', style: AppTypography.titleLarge),
              const SizedBox(height: 4),
              Text(
                'Customer: ${apt.customerName} • ${apt.serviceName}',
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: 16),
              ...[
                AppConstants.statusPending,
                AppConstants.statusConfirmed,
                AppConstants.statusCompleted,
                AppConstants.statusRejected,
                AppConstants.statusCancelled,
              ].map((status) {
                final displayStatus = status[0].toUpperCase() + status.substring(1);
                return ListTile(
                  leading: Icon(
                    status == AppConstants.statusCompleted
                        ? Icons.check_circle_outline
                        : status == AppConstants.statusConfirmed
                            ? Icons.thumb_up_outlined
                            : status == AppConstants.statusCancelled || status == AppConstants.statusRejected
                                ? Icons.cancel_outlined
                                : Icons.schedule,
                    color: status == AppConstants.statusCompleted
                        ? AppColors.statusCompleted
                        : status == AppConstants.statusConfirmed
                            ? AppColors.statusConfirmed
                            : status == AppConstants.statusCancelled || status == AppConstants.statusRejected
                                ? AppColors.statusCancelled
                                : AppColors.statusPending,
                  ),
                  title: Text(displayStatus, style: AppTypography.titleMedium.copyWith(fontSize: 15)),
                  trailing: apt.status == status ? const Icon(Icons.check, color: AppColors.primary) : null,
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    
                    debugPrint('\n==================================================');
                    debugPrint('APPROVE PRESSED');
                    debugPrint('appointmentId = ${apt.appointmentId}');
                    debugPrint('currentStatus = ${apt.status}');
                    
                    try {
                      await context.read<BookingProvider>().updateStatus(apt.appointmentId, status);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Updated to $displayStatus')),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to update: $e'),
                            backgroundColor: AppColors.statusCancelled,
                            duration: const Duration(seconds: 5),
                          ),
                        );
                      }
                    }
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showCustomerDetailModal(AppointmentModel apt) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.person_pin, color: AppColors.primary),
            const SizedBox(width: 8),
            Text('Centralized Customer Details', style: AppTypography.titleMedium),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Customer Name', apt.customerName),
            _buildDetailRow('Unified UID', apt.customerId),
            _buildDetailRow('Email', apt.customerEmail),
            _buildDetailRow('Phone', apt.customerPhone),
            _buildDetailRow('Service Requested', apt.serviceName),
            _buildDetailRow('Assigned Stylist', apt.stylistName),
            _buildDetailRow('Date & Time', '${apt.appointmentDate} ${apt.startTime}'),
            if (apt.notes != null && apt.notes!.isNotEmpty)
              _buildDetailRow('Notes', apt.notes!),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted)),
          Text(value, style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProv = context.watch<AuthProvider>();
    final bookingProv = context.watch<BookingProvider>();
    final branchProv = context.watch<BranchProvider>();

    final user = authProv.currentUser;
    final branchId = user?.assignedBranchId;

    if (branchId == null || branchId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Staff Console')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.statusCancelled),
              const SizedBox(height: 16),
              const Text('No Branch Assigned', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Please contact an Admin to assign you to a branch.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  context.read<BookingProvider>().clearAllListeners();
                  await authProv.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
                  }
                },
                child: const Text('Logout'),
              )
            ],
          ),
        ),
      );
    }

    final branch = branchProv.branches.firstWhere(
      (b) => b.branchId == branchId,
      orElse: () => BranchModel(
              branchId: branchId,
              name: 'Unknown Branch',
              address: '',
              city: '',
              phone: '',
              openingHours: '',
              description: '',
              image: '',
            ),
    );

    var appointments = bookingProv.branchAppointments;
    if (_selectedStatusFilter != 'All') {
      appointments = appointments.where((a) => a.status == _selectedStatusFilter.toLowerCase()).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Staff Console', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(
              '${branch.name} • Station Desk',
              style: AppTypography.bodyMedium.copyWith(fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              context.read<BookingProvider>().clearAllListeners();
              await authProv.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed(AppRoutes.login);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColors.surface,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Pending', 'Confirmed', 'Completed', 'Rejected', 'Cancelled'].map((st) {
                  final isSel = _selectedStatusFilter == st;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(st),
                      selected: isSel,
                      selectedColor: AppColors.primaryLight,
                      labelStyle: TextStyle(
                        color: isSel ? AppColors.primary : AppColors.textPrimary,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                      onSelected: (_) => setState(() => _selectedStatusFilter = st),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const Divider(height: 1),

          if (bookingProv.errorMessage != null)
            Container(
              padding: const EdgeInsets.all(8),
              color: AppColors.statusCancelledBg,
              width: double.infinity,
              child: Text(
                'Sync Error: ${bookingProv.errorMessage}',
                style: const TextStyle(color: AppColors.statusCancelled),
                textAlign: TextAlign.center,
              ),
            ),
          Expanded(
            child: appointments.isEmpty
                ? const EmptyStateWidget(
                    icon: Icons.event_available,
                    title: 'No Appointments Found',
                    message: 'No bookings match the selected status filter for this branch.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: appointments.length,
                    itemBuilder: (ctx, i) {
                      final apt = appointments[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    apt.customerName,
                                    style: AppTypography.titleMedium,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: apt.isConfirmed
                                          ? AppColors.statusConfirmedBg
                                          : apt.isCompleted
                                              ? AppColors.statusCompletedBg
                                              : apt.isCancelled
                                                  ? AppColors.statusCancelledBg
                                                  : AppColors.statusPendingBg,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      apt.status[0].toUpperCase() + apt.status.substring(1),
                                      style: TextStyle(
                                        color: apt.isConfirmed
                                            ? AppColors.statusConfirmed
                                            : apt.isCompleted
                                                ? AppColors.statusCompleted
                                                : apt.isCancelled
                                                    ? AppColors.statusCancelled
                                                    : AppColors.statusPending,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${apt.serviceName} • Stylist: ${apt.stylistName}',
                                style: AppTypography.bodyMedium,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.schedule, size: 14, color: AppColors.textMuted),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${apt.appointmentDate} at ${apt.startTime}',
                                    style: AppTypography.bodyMedium.copyWith(fontSize: 12),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    icon: const Icon(Icons.info_outline, size: 16),
                                    label: const Text('Customer Info', style: TextStyle(fontSize: 12)),
                                    onPressed: () => _showCustomerDetailModal(apt),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    icon: const Icon(Icons.edit, size: 14),
                                    label: const Text('Update Status', style: TextStyle(fontSize: 12)),
                                    onPressed: () => _showStatusUpdateDialog(apt),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
