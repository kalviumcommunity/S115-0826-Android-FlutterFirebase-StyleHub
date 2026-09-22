import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_button.dart';
import '../../models/branch_model.dart';
import '../../models/service_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/branch_provider.dart';
import '../../providers/service_provider.dart';
import 'booking_flow_screen.dart';
import 'widgets/branch_card.dart';
import 'widgets/service_card.dart';

class CustomerHomeScreen extends StatelessWidget {
  final VoidCallback onNavigateToAppointments;
  final VoidCallback onNavigateToHistory;

  const CustomerHomeScreen({
    super.key,
    required this.onNavigateToAppointments,
    required this.onNavigateToHistory,
  });

  void _startBooking(BuildContext context, {BranchModel? branch, ServiceModel? service}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BookingFlowScreen(
          initialBranch: branch,
          initialService: service,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProv = context.watch<AuthProvider>();
    final branchProv = context.watch<BranchProvider>();
    final serviceProv = context.watch<ServiceProvider>();
    final bookingProv = context.watch<BookingProvider>();

    final user = authProv.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.spa, size: 20, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppConstants.appName, style: AppTypography.titleLarge.copyWith(fontSize: 18)),
                Text(
                  'Hello, ${user?.name ?? "Guest"}',
                  style: AppTypography.bodyMedium.copyWith(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'Cross-Branch History',
            onPressed: onNavigateToHistory,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Unified Identity Cross-Branch Status Hero Banner
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.secondary, Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1F000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'CENTRALIZED IDENTITY',
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.white,
                            fontSize: 10,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.verified_user, color: Colors.white70, size: 16),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'One Profile across all StyleHub Outlets',
                    style: AppTypography.displayMedium.copyWith(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Book seamlessly at Downtown, Midtown, Uptown, or Brooklyn without re-registering.',
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    label: 'Book an Appointment',
                    height: 42,
                    icon: Icons.calendar_today_outlined,
                    onPressed: () => _startBooking(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Salon Branches Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Salon Branches', style: AppTypography.titleLarge),
                Text(
                  '${branchProv.branches.length} Outlets',
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...branchProv.branches.map((branch) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: BranchCard(
                branch: branch,
                onTap: () => _startBooking(context, branch: branch),
              ),
            )),
            const SizedBox(height: 16),

            // Service Catalogue Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Popular Services', style: AppTypography.titleLarge),
              ],
            ),
            const SizedBox(height: 10),

            // Category filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: serviceProv.categories.map((cat) {
                  final isSelected = serviceProv.selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      selectedColor: AppColors.primaryLight,
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                      onSelected: (_) => serviceProv.selectCategory(cat),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),

            ...serviceProv.services.take(4).map((service) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ServiceCard(
                service: service,
                onTap: () => _startBooking(context, service: service),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
