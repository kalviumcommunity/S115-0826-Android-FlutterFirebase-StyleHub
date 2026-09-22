import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../models/appointment_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import 'booking_flow_screen.dart';
import 'widgets/booking_card.dart';

class CustomerHistoryScreen extends StatelessWidget {
  final VoidCallback onStartBooking;

  const CustomerHistoryScreen({
    super.key,
    required this.onStartBooking,
  });

  @override
  Widget build(BuildContext context) {
    final authProv = context.watch<AuthProvider>();
    final bookingProv = context.watch<BookingProvider>();

    // All appointments across all branches for this centralized customer
    final allApts = bookingProv.customerAppointments;
    final branchesVisited = bookingProv.customerBranchesVisited;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cross-Branch History'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Unified Identity Architecture Information Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.hub_outlined, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Centralized Customer Record',
                        style: AppTypography.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'All appointments across any StyleHub salon branch are linked to your single Firebase UID: ${authProv.currentUser?.uid.substring(0, 10)}...',
                    style: AppTypography.bodyMedium.copyWith(fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildMetricChip(
                        label: 'Total Visits',
                        value: allApts.length.toString(),
                        color: AppColors.primary,
                      ),
                      _buildMetricChip(
                        label: 'Branches Visited',
                        value: '${branchesVisited.length} Outlets',
                        color: AppColors.secondary,
                      ),
                      _buildMetricChip(
                        label: 'Customer Status',
                        value: allApts.length > 1 ? 'Repeat Patron' : 'New Member',
                        color: AppColors.statusCompleted,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Text('Complete Timeline', style: AppTypography.titleLarge),
            const SizedBox(height: 12),

            if (allApts.isEmpty)
              EmptyStateWidget(
                icon: Icons.history,
                title: 'No Visit History Yet',
                message: 'Your past appointments across all salon outlets will automatically appear here.',
                actionLabel: 'Explore Services',
                onAction: onStartBooking,
              )
            else
              ...allApts.map((apt) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: BookingCard(
                  appointment: apt,
                  onRebook: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const BookingFlowScreen(),
                      ),
                    );
                  },
                ),
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricChip({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted, fontSize: 10)),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTypography.titleMedium.copyWith(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
