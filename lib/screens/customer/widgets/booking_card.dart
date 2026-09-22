import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../models/appointment_model.dart';

class BookingCard extends StatelessWidget {
  final AppointmentModel appointment;
  final VoidCallback? onRebook;
  final VoidCallback? onCancel;

  const BookingCard({
    super.key,
    required this.appointment,
    this.onRebook,
    this.onCancel,
  });

  Color _getStatusBg() {
    if (appointment.isConfirmed) {
      return AppColors.statusConfirmedBg;
    } else if (appointment.isCompleted) {
      return AppColors.statusCompletedBg;
    } else if (appointment.isCancelled) {
      return AppColors.statusCancelledBg;
    } else {
      return AppColors.statusPendingBg;
    }
  }

  Color _getStatusFg() {
    if (appointment.isConfirmed) {
      return AppColors.statusConfirmed;
    } else if (appointment.isCompleted) {
      return AppColors.statusCompleted;
    } else if (appointment.isCancelled) {
      return AppColors.statusCancelled;
    } else {
      return AppColors.statusPending;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Branch Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.storefront, size: 13, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      appointment.branchName,
                      style: AppTypography.labelSmall.copyWith(color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
              // Status Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _getStatusBg(),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  appointment.status[0].toUpperCase() + appointment.status.substring(1),
                  style: AppTypography.labelSmall.copyWith(
                    color: _getStatusFg(),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            appointment.serviceName,
            style: AppTypography.titleMedium.copyWith(fontSize: 17),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(
                'Stylist: ${appointment.stylistName}',
                style: AppTypography.bodyMedium,
              ),
              const Spacer(),
              Text(
                '₹${appointment.servicePrice.toStringAsFixed(0)}',
                style: AppTypography.titleMedium.copyWith(color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(
                '${appointment.appointmentDate} at ${appointment.startTime}',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          if (onRebook != null || onCancel != null) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onCancel != null && (appointment.isPending || appointment.isConfirmed))
                  TextButton(
                    onPressed: onCancel,
                    child: Text(
                      'Cancel',
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.statusCancelled,
                        fontSize: 13,
                      ),
                    ),
                  ),
                if (onRebook != null)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                    icon: const Icon(Icons.refresh, size: 14),
                    label: const Text('Rebook Service', style: TextStyle(fontSize: 12)),
                    onPressed: onRebook,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
