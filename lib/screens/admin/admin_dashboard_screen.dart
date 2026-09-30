import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../models/branch_model.dart';
import '../../models/service_model.dart';
import '../../models/stylist_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/branch_provider.dart';
import '../../providers/service_provider.dart';
import '../../providers/stylist_provider.dart';
import '../../routes/app_routes.dart';
import 'tabs/admin_branches_tab.dart';
import 'tabs/admin_stylists_tab.dart';
import 'tabs/admin_services_tab.dart';
import 'tabs/admin_staff_tab.dart';
import 'tabs/admin_customers_tab.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().listenToAllAppointments();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final authProv = context.watch<AuthProvider>();
    final branchProv = context.watch<BranchProvider>();
    final stylistProv = context.watch<StylistProvider>();
    final serviceProv = context.watch<ServiceProvider>();
    final bookingProv = context.watch<BookingProvider>();

    final allAppointments = bookingProv.allAppointments;
    final totalRevenue = allAppointments.fold<double>(0.0, (sum, a) => sum + a.servicePrice);
    final uniqueCustomers = allAppointments.map((a) => a.customerId).toSet().length;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: AppColors.roleAdmin, borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Text('HQ Admin Center', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              context.read<BookingProvider>().clearAllListeners();
              await authProv.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed(AppRoutes.login);
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.primary,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Analytics'),
            Tab(text: 'Branches'),
            Tab(text: 'Stylists'),
            Tab(text: 'Services'),
            Tab(text: 'Staff'),
            Tab(text: 'Customers'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. NETWORK ANALYTICS TAB
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cross-Branch Network Overview', style: AppTypography.titleLarge),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.4,
                  children: [
                    _buildStatCard('Active Outlets', branchProv.branches.length.toString(), Icons.storefront, AppColors.primary),
                    _buildStatCard('Unified Customers', uniqueCustomers.toString(), Icons.people_outline, AppColors.roleStaff),
                    _buildStatCard('Total Bookings', allAppointments.length.toString(), Icons.calendar_month, AppColors.statusCompleted),
                    _buildStatCard('Network Revenue', '₹${totalRevenue.toStringAsFixed(0)}', Icons.monetization_on_outlined, AppColors.accent),
                  ],
                ),
                const SizedBox(height: 20),

                Text('Recent Network Bookings', style: AppTypography.titleLarge),
                const SizedBox(height: 12),
                ...allAppointments.take(5).map((a) => AppCard(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(a.customerName, style: AppTypography.titleMedium),
                          Text('${a.serviceName} at ${a.branchName}', style: AppTypography.bodyMedium.copyWith(fontSize: 12)),
                          Text('${a.appointmentDate} • ${a.startTime}', style: AppTypography.bodyMedium.copyWith(fontSize: 11, color: AppColors.textMuted)),
                        ],
                      ),
                      Text('₹${a.servicePrice.toStringAsFixed(0)}', style: AppTypography.titleMedium.copyWith(color: AppColors.primary)),
                    ],
                  ),
                )),
              ],
            ),
          ),

          // 2. BRANCHES MANAGEMENT TAB
          const AdminBranchesTab(),

          // 3. STYLISTS TAB
          const AdminStylistsTab(),

          // 4. SERVICES CATALOGUE TAB
          const AdminServicesTab(),

          // 5. STAFF MANAGEMENT TAB
          const AdminStaffTab(),

          // 6. CUSTOMERS TAB
          const AdminCustomersTab(),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: AppTypography.titleLarge.copyWith(color: color, fontSize: 22)),
          Text(title, style: AppTypography.bodyMedium.copyWith(fontSize: 12)),
        ],
      ),
    );
  }
}
