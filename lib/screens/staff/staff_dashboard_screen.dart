import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stylehub/providers/staff_dashboard_provider.dart';
import 'package:stylehub/widgets/data_state_view.dart';
import 'package:stylehub/core/theme/app_colors.dart';
import 'package:stylehub/core/theme/app_typography.dart';
import 'package:stylehub/core/theme/app_constants.dart';

class StaffDashboardScreen extends StatefulWidget {
  const StaffDashboardScreen({super.key});

  @override
  State<StaffDashboardScreen> createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends State<StaffDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StaffDashboardProvider>().initialize('branch_123');
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StaffDashboardProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.of(context).pushNamed('/customer-search'),
          ),
        ],
      ),
      body: DataStateView<dynamic>(
        isLoading: provider.isLoading,
        errorMessage: provider.errorMessage,
        isEmpty: provider.isEmpty,
        data: provider.stats,
        successBuilder: (stats) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Today\'s Overview', style: AppTypography.titleLarge),
                const SizedBox(height: AppSpacing.m),
                Row(
                  children: [
                    _buildStatCard('Total', '0', Colors.blue),
                    _buildStatCard('Completed', '0', Colors.green),
                    _buildStatCard('Pending', '0', Colors.orange),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                Text('Upcoming Appointments', style: AppTypography.titleMedium),
                const SizedBox(height: AppSpacing.s),
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.l),
                    child: Text('No appointments for the current time slot'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Card(
        color: color.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Column(
            children: [
              Text(value, style: AppTypography.headlineSmall.copyWith(color: color, fontWeight: FontWeight.bold)),
              Text(label, style: AppTypography.labelSmall),
            ],
          ),
        ),
      ),
    );
  }
}

class StaffDashboardStats {
  final int totalAppointments;
  final int completedAppointments;
  final int pendingTasks;

  StaffDashboardStats({
    required this.totalAppointments,
    required this.completedAppointments,
    required this.pendingTasks,
  });
}
