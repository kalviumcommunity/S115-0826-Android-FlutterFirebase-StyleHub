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
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().listenToAllAppointments();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddBranchDialog() {
    final nameCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final cityCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final hoursCtrl = TextEditingController(text: '9:00 AM - 8:00 PM');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add New Salon Branch'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Branch Name')),
              TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: 'Street Address')),
              TextField(controller: cityCtrl, decoration: const InputDecoration(labelText: 'City')),
              TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone Number')),
              TextField(controller: hoursCtrl, decoration: const InputDecoration(labelText: 'Opening Hours')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          AppButton(
            label: 'Save Branch',
            height: 38,
            onPressed: () async {
              if (nameCtrl.text.isNotEmpty) {
                final newBranch = BranchModel(
                  branchId: 'branch_${DateTime.now().millisecondsSinceEpoch}',
                  name: nameCtrl.text.trim(),
                  address: addressCtrl.text.trim(),
                  city: cityCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                  openingHours: hoursCtrl.text.trim(),
                  description: 'Luxury StyleHub partner salon outlet.',
                  image: 'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=500',
                );
                await context.read<BranchProvider>().saveBranch(newBranch);
                if (mounted) Navigator.of(ctx).pop();
              }
            },
          ),
        ],
      ),
    );
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
            icon: const Icon(Icons.swap_horiz),
            tooltip: 'Return to Customer View',
            onPressed: () {
              authProv.switchRole(AppConstants.roleCustomer);
              Navigator.of(context).pushReplacementNamed(AppRoutes.customerMain);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
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
          tabs: const [
            Tab(text: 'Analytics'),
            Tab(text: 'Branches'),
            Tab(text: 'Stylists'),
            Tab(text: 'Services'),
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
                    _buildStatCard('Network Revenue', '\$${totalRevenue.toStringAsFixed(0)}', Icons.monetization_on_outlined, AppColors.accent),
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
                      Text('\$${a.servicePrice.toStringAsFixed(0)}', style: AppTypography.titleMedium.copyWith(color: AppColors.primary)),
                    ],
                  ),
                )),
              ],
            ),
          ),

          // 2. BRANCHES MANAGEMENT TAB
          Scaffold(
            body: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: branchProv.branches.length,
              itemBuilder: (ctx, i) {
                final b = branchProv.branches[i];
                return ListTile(
                  leading: const Icon(Icons.storefront, color: AppColors.primary),
                  title: Text(b.name, style: AppTypography.titleMedium),
                  subtitle: Text('${b.address}, ${b.city} • ${b.openingHours}'),
                  trailing: Text('${b.rating} ★'),
                );
              },
            ),
            floatingActionButton: FloatingActionButton.extended(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              onPressed: _showAddBranchDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add Branch'),
            ),
          ),

          // 3. STYLISTS TAB
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: stylistProv.stylists.length,
            itemBuilder: (ctx, i) {
              final s = stylistProv.stylists[i];
              return ListTile(
                leading: CircleAvatar(backgroundImage: NetworkImage(s.profileImage)),
                title: Text(s.name, style: AppTypography.titleMedium),
                subtitle: Text('${s.specialization} • ${s.experience}'),
                trailing: Text('${s.rating} ★'),
              );
            },
          ),

          // 4. SERVICES CATALOGUE TAB
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: serviceProv.services.length,
            itemBuilder: (ctx, i) {
              final s = serviceProv.services[i];
              return ListTile(
                leading: const Icon(Icons.spa, color: AppColors.primary),
                title: Text(s.name, style: AppTypography.titleMedium),
                subtitle: Text('${s.category} • ${s.duration} mins'),
                trailing: Text('\$${s.price.toStringAsFixed(0)}', style: AppTypography.titleMedium.copyWith(color: AppColors.primary)),
              );
            },
          ),
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
