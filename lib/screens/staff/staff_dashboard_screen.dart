import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../models/staff_dashboard_model.dart';
import '../../providers/staff_dashboard_provider.dart';
import '../../services/operations_service.dart';

class StaffDashboardScreen extends StatefulWidget {
  const StaffDashboardScreen({super.key});

  @override
  State<StaffDashboardScreen> createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends State<StaffDashboardScreen> {
  final _searchController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final branchId = context.read<AuthProvider>().currentUser?.branchId;
    context.read<StaffDashboardProvider>().initialize(branchId);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthProvider>().signOut(),
          ),
        ],
      ),
      body: Consumer<StaffDashboardProvider>(
        builder: (context, provider, _) {
          if (provider.errorMessage != null) {
            return Center(child: Text(provider.errorMessage!));
          }
          if (provider.isLoading && provider.customers.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            children: [
              _StatsRow(stats: provider.stats),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: TextField(
                  controller: _searchController,
                  onChanged: provider.updateSearch,
                  decoration: const InputDecoration(
                    labelText: 'Search customers across all branches',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Expanded(
                child: provider.isEmpty
                    ? const Center(child: Text('No matching customers.'))
                    : ListView.builder(
                        itemCount: provider.customers.length,
                        itemBuilder: (context, index) {
                          final customer = provider.customers[index];
                          return ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.person),
                            ),
                            title: Text(customer.name),
                            subtitle: Text(
                              '${customer.phone} • ${customer.email}',
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => _showCustomer(context, customer),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showCustomer(BuildContext context, UserModel customer) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => FutureBuilder<CustomerInsight>(
        future: context.read<StaffDashboardProvider>().loadCustomerInsight(
          customer.uid,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: Text('Unable to load customer history.'),
            );
          }
          if (!snapshot.hasData) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            );
          }
          final insight = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Wrap(
              runSpacing: 12,
              children: [
                Text(
                  customer.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Chip(
                  avatar: Icon(
                    insight.isReturning ? Icons.replay : Icons.person_add,
                  ),
                  label: Text(
                    insight.isReturning ? 'Returning Customer' : 'New Customer',
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Completed visits'),
                  trailing: Text('${insight.history.length}'),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Preferred stylist'),
                  trailing: Text(insight.preferredStylist ?? 'No history'),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Most-booked service'),
                  trailing: Text(insight.mostBookedService ?? 'No history'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final StaffDashboardStats? stats;

  const _StatsRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              label: "Today's appointments",
              value: stats?.todayAppointments,
              icon: Icons.today,
            ),
          ),
          Expanded(
            child: _StatCard(
              label: 'Pending appointments',
              value: stats?.pendingAppointments,
              icon: Icons.pending_actions,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int? value;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon),
            const SizedBox(height: 8),
            Text(
              value?.toString() ?? '--',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(label),
          ],
        ),
      ),
    );
  }
}
