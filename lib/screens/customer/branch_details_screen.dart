import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:stylehub/providers/reference_data_provider.dart';
import 'package:stylehub/widgets/data_state_view.dart';
import 'package:stylehub/widgets/domain_cards.dart';
import 'package:stylehub/widgets/primary_button.dart';
import 'package:stylehub/models/branch_model.dart';
import 'package:stylehub/core/theme/app_colors.dart';
import 'package:stylehub/core/theme/app_typography.dart';
import 'package:stylehub/core/theme/app_constants.dart';

class BranchDetailsScreen extends StatelessWidget {
  const BranchDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final branch = ModalRoute.of(context)!.settings.arguments as BranchModel;
    final provider = context.watch<ReferenceDataProvider>();

    // Filter stylists and services for this specific branch
    final branchStylists = provider.stylists.where((s) => s.branchId == branch.id).toList();
    final branchServices = provider.services.where((s) => s.branchId == branch.id).toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(branch.name),
              background: CachedNetworkImage(
                imageUrl: branch.imageUrl ?? '',
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: AppColors.secondaryContainer),
                errorWidget: (context, url, error) => const Icon(Icons.store),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('About this Branch', style: AppTypography.titleLarge),
                  const SizedBox(height: AppSpacing.s),
                  Text(
                    '${branch.address}, ${branch.city}\nPhone: ${branch.phone}',
                    style: AppTypography.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.l),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Available Stylists', style: AppTypography.titleMedium),
                      TextButton(
                        onPressed: () {},
                        child: const Text('See All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s),
                  SizedBox(
                    height: 120,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: branchStylists.map((s) => Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.m),
                        child: StylistCard(
                          stylist: s,
                          onTap: () {},
                        ),
                      )).toList(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.l),

                  Text('Services Offered', style: AppTypography.titleMedium),
                  const SizedBox(height: AppSpacing.s),
                  // We'll use a simpler list for services here
                  ...branchServices.map((service) => ListTile(
                    title: Text(service.name, style: AppTypography.bodyLarge),
                    subtitle: Text('${service.durationMinutes} mins'),
                    trailing: Text('\$${service.price}', style: AppTypography.titleSmall),
                    onTap: () {},
                  )).toList(),

                  const SizedBox(height: AppSpacing.xl),
                  PrimaryButton(
                    text: 'Book Appointment',
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        '/service-selection',
                        arguments: branch,
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.l),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
