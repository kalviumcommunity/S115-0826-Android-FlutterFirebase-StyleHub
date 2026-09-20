import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:stylehub/core/theme/app_colors.dart';
import 'package:stylehub/core/theme/app_typography.dart';
import 'package:stylehub/core/theme/app_constants.dart';
import 'package:stylehub/models/branch_model.dart';
import 'package:stylehub/models/stylist_model.dart';
import 'package:stylehub/models/appointment_model.dart';

class BranchCard extends StatelessWidget {
  final BranchModel branch;
  final VoidCallback onTap;

  const BranchCard({super.key, required this.branch, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.small),
                child: CachedNetworkImage(
                  imageUrl: branch.imageUrl ?? '',
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: AppColors.secondaryContainer),
                  errorWidget: (context, url, error) => const Icon(Icons.store, color: AppColors.secondary),
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      branch.name,
                      style: AppTypography.titleMedium,
                    ),
                    Text(
                      branch.city,
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class StylistCard extends StatelessWidget {
  final StylistModel stylist;
  final VoidCallback onTap;

  const StylistCard({super.key, required this.stylist, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundImage: stylist.photoUrl != null
                  ? CachedNetworkImageProvider(stylist.photoUrl!)
                  : null,
                child: stylist.photoUrl == null ? const Icon(Icons.person) : null,
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stylist.name,
                      style: AppTypography.titleSmall,
                    ),
                    Text(
                      stylist.specialization.join(', '),
                      style: AppTypography.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final VoidCallback onTap;

  const AppointmentCard({super.key, required this.appointment, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    appointment.serviceName,
                    style: AppTypography.titleSmall,
                  ),
                  _buildStatusChip(appointment.status),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${appointment.stylistName} • ${appointment.branchName}',
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 14, color: AppColors.secondary),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    appointment.scheduledAt.toLocal().toString().split(' ')[0],
                    style: AppTypography.bodySmall,
                  ),
                  const SizedBox(width: AppSpacing.m),
                  const Icon(Icons.access_time, size: 14, color: AppColors.secondary),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    appointment.scheduledAt.toLocal().toString().split(' ')[1].substring(0, 5),
                    style: AppTypography.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'confirmed': color = Colors.green; break;
      case 'pending': color = Colors.orange; break;
      case 'cancelled': color = Colors.red; break;
      default: color = AppColors.secondary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.small),
        border: Border.all(color: color),
      ),
      child: Text(
        status.toUpperCase(),
        style: AppTypography.labelSmall.copyWith(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
