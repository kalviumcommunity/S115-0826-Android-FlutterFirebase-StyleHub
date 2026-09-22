import 'package:flutter/material.dart';
import '../../../models/stylist_model.dart';
import '../app_card.dart';
import '../app_button.dart';
import '../../theme/app_colors.dart';

class StylistCard extends StatelessWidget {
  final StylistModel stylist;
  final VoidCallback? onSelect;
  final bool selected;

  const StylistCard({
    super.key,
    required this.stylist,
    this.onSelect,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      borderColor: selected ? AppColors.primary : AppColors.border,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image on top, centered
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
                      ],
                    ),
                    child: ClipOval(
                      child: Image.network(
                        stylist.profileImage,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Image.network(
                          'https://images.unsplash.com/photo-1595152772835-219674b2a8a6?q=80&w=200&auto=format&fit=crop',
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          errorBuilder: (c2, e2, s2) => Container(width: 64, height: 64, color: Colors.grey[300]),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB), // amber-50
                        border: Border.all(color: const Color(0xFFFDE68A)), // amber-200
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 10),
                          const SizedBox(width: 2),
                          Text(
                            stylist.rating.toString(),
                            style: const TextStyle(
                              color: Color(0xFF92400E), // amber-800
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Name and Details (Centered)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  stylist.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  stylist.bio, // used as specialization
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                if (stylist.branchName != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on, color: Colors.grey, size: 12),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          stylist.branchName!,
                          style: TextStyle(color: Colors.grey[600], fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.military_tech, color: Colors.grey, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      '5+ yrs exp',
                      style: TextStyle(color: Colors.grey[600], fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // Bottom section
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(height: 1, color: AppColors.border),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Available',
                        style: TextStyle(color: Colors.grey[400], fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    if (onSelect != null)
                      AppButton(
                        label: selected ? 'Selected' : 'Book',
                        variant: selected ? AppButtonVariant.primary : AppButtonVariant.outline,
                        height: 32,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        fontSize: 11,
                        onPressed: onSelect,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
