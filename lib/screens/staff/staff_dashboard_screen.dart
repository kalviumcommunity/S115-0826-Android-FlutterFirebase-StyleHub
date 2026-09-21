import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_constants.dart';
import '../../core/widgets/app_loading.dart';
import '../../core/widgets/app_error_widget.dart';
import '../../providers/auth_provider.dart';
import '../../providers/staff_dashboard_provider.dart';
import '../../widgets/data_state_view.dart';
import '../../models/staff_dashboard_model.dart';

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
      final branchId = context.read<AuthProvider>().currentUser?.branchId;
      if (branchId != null && branchId.isNotEmpty) {
        context.read<StaffDashboardProvider>().initialize(branchId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashProvider = context.watch<StaffDashboardProvider>();
    final branchId = context.watch<AuthProvider>().currentUser?.branchId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (branchId != null) dashProvider.initialize(branchId);
            },
          ),
        ],
      ),
      body: DataStateView<StaffDashboardStats>(
        isLoading: dashProvider.isLoading,
        error: dashProvider.error,
        data: dashProvider.stats,
        onRetry: () {
          if (branchId != null) dashProvider.initialize(branchId);
        },
        successBuilder: (stats) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Overview',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        )),
                const SizedBox(height: AppSpacing.m),
                Row(
                  children: [
                    Expanded(child: _StatCard(
                      title: "Today's",
                      value: '${stats.todayAppointments}',
                      icon: Icons.today,
                      color: AppColors.primary,
                    )),
                    const SizedBox(width: AppSpacing.s),
                    Expanded(child: _StatCard(
                      title: 'Pending',
                      value: '${stats.pendingAppointments}',
                      icon: Icons.pending_actions,
                      color: Colors.orange,
                    )),
                    const SizedBox(width: AppSpacing.s),
                    Expanded(child: _StatCard(
                      title: 'Completed',
                      value: '${stats.completedAppointments}',
                      icon: Icons.check_circle_outline,
                      color: Colors.green,
                    )),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                Text('Quick Actions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        )),
                const SizedBox(height: AppSpacing.m),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.person_search),
                    title: const Text('Search Customers'),
                    subtitle: const Text('Find and view customer profiles'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // Navigate handled by bottom nav in StaffMainScaffold
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 8),
            Text(value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    )),
            Text(title,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center),
          ],
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
