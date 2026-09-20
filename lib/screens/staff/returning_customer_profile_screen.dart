import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stylehub/providers/staff_dashboard_provider.dart';
import 'package:stylehub/core/theme/app_colors.dart';
import 'package:stylehub/core/theme/app_typography.dart';
import 'package:stylehub/core/theme/app_constants.dart';

class ReturningCustomerProfileScreen extends StatelessWidget {
  const ReturningCustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StaffDashboardProvider>();
    // In a real app, we'd get the customerId from route arguments

    return Scaffold(
      appBar: AppBar(title: const Text('Customer Insights')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: CircleAvatar(
                radius: 50,
                child: Icon(Icons.person, size: 50),
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            Center(
              child: Text(
                'Customer Name',
                style: AppTypography.headlineSmall,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            _buildInsightTile('Preferred Stylist', 'Alex Rivera', Icons.star),
            _buildInsightTile('Most Booked Service', 'Haircut & Style', Icons.cut),
            _buildInsightTile('Total Visits', '12', Icons.history),
            _buildInsightTile('Last Visit', '2 weeks ago', Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightTile(String label, String value, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(label, style: AppTypography.bodySmall),
        trailing: Text(value, style: AppTypography.titleMedium),
      ),
    );
  }
}
