import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../models/appointment_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/branch_provider.dart';
import '../../routes/app_routes.dart';

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
      final branchId = auth.currentUser?.assignedBranchId ?? 'branch_downtown';
      context.read<BookingProvider>().listenToBranchAppointments(branchId);
    });
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
                AppConstants.statusCancelled,
              ].map((status) {
                return ListTile(
                  leading: Icon(
                    status == AppConstants.statusCompleted
                        ? Icons.check_circle_outline
                        : status == AppConstants.statusConfirmed
                            ? Icons.thumb_up_outlined
                            : status == AppConstants.statusCancelled
                                ? Icons.cancel_outlined
                                : Icons.schedule,
                    color: status == AppConstants.statusCompleted
                        ? AppColors.statusCompleted
                        : status == AppConstants.statusConfirmed
                            ? AppColors.statusConfirmed
                            : status == AppConstants.statusCancelled
                                ? AppColors.statusCancelled
                                : AppColors.statusPending,
                  ),
                  title: Text(status, style: AppTypography.titleMedium.copyWith(fontSize: 15)),
                  trailing: apt.status == status ? const Icon(Icons.check, color: AppColors.primary) : null,
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    await context.read<BookingProvider>().updateStatus(apt.appointmentId, status);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Updated to $status')),
                      );
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
    final branchId = user?.assignedBranchId ?? 'branch_downtown';
    final branch = branchProv.branches.firstWhere(
      (b) => b.branchId == branchId,
      orElse: () => branchProv.branches.isNotEmpty
          ? branchProv.branches.first
          : const BranchModel(
              branchId: 'branch_downtown',
              name: 'Downtown Flagship',
              address: '100 Main St',
              city: 'New York',
              phone: '555-0100',
              openingHours: '9am - 8pm',
              description: '',
              image: '',
            ),
    );

    var appointments = bookingProv.branchAppointments;
    if (_selectedStatusFilter != 'All') {
      appointments = appointments.where((a) => a.status == _selectedStatusFilter).toList();
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
            icon: const Icon(Icons.swap_horiz),
            tooltip: 'Return to Customer View',
            onPressed: () {
              authProv.switchRole(AppConstants.roleCustomer);
              Navigator.of(context).pushReplacementNamed(AppRoutes.customerMain);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
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
                children: ['All', 'Pending', 'Confirmed', 'Completed', 'Cancelled'].map((st) {
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
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: apt.status == 'Confirmed'
                                          ? AppColors.statusConfirmedBg
                                          : apt.status == 'Completed'
                                              ? AppColors.statusCompletedBg
                                              : apt.status == 'Cancelled'
                                                  ? AppColors.statusCancelledBg
                                                  : AppColors.statusPendingBg,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      apt.status,
                                      style: AppTypography.labelSmall.copyWith(
                                        color: apt.status == 'Confirmed'
                                            ? AppColors.statusConfirmed
                                            : apt.status == 'Completed'
                                                ? AppColors.statusCompleted
                                                : apt.status == 'Cancelled'
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
