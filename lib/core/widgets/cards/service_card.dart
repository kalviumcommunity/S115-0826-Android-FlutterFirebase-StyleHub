import 'package:flutter/material.dart';
import '../../../models/service_model.dart';
import '../app_card.dart';
import '../app_button.dart';
import '../../theme/app_colors.dart';

class ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback? onSelect;
  final bool selected;

  const ServiceCard({
    super.key,
    required this.service,
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
          // Image Header
          SizedBox(
            height: 144, // h-36 in tailwind
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  service.image,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Image.network(
                    'https://images.unsplash.com/photo-1560066984-138dadb4c035?q=80&w=400&auto=format&fit=crop',
                    fit: BoxFit.cover,
                    errorBuilder: (c2, e2, s2) => Container(color: Colors.grey[200]),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.local_offer, color: Colors.redAccent, size: 10),
                        const SizedBox(width: 4),
                        Text(
                          service.category.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '₹${service.price.toInt()}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Details
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  service.description,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12, height: 1.5),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: AppColors.border),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.access_time_rounded, color: Colors.grey, size: 12),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '${service.duration}m',
                              style: const TextStyle(color: Colors.grey, fontSize: 11),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
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
