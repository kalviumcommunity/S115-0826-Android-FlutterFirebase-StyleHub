import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../models/stylist_model.dart';

class StylistCard extends StatelessWidget {
  final StylistModel stylist;
  final VoidCallback onTap;
  final bool isSelected;

  const StylistCard({
    super.key,
    required this.stylist,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      borderColor: isSelected ? AppColors.primary : AppColors.border,
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.surfaceVariant,
            backgroundImage: NetworkImage(stylist.profileImage),
            onBackgroundImageError: (_, __) {},
            child: stylist.profileImage.isEmpty
                ? const Icon(Icons.person, color: AppColors.textMuted, size: 28)
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      stylist.name,
                      style: AppTypography.titleMedium,
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text(
                          stylist.rating.toStringAsFixed(1),
                          style: AppTypography.labelSmall,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  stylist.specialization,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  stylist.experience,
                  style: AppTypography.bodyMedium.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  '${stylist.availability.length} slots available today',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.statusCompleted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
