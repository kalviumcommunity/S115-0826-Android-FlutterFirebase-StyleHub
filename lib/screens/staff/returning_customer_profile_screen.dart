import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_constants.dart';
import '../../core/widgets/app_loading.dart';
import '../../core/widgets/app_error_widget.dart';
import '../../providers/staff_dashboard_provider.dart';
import '../../services/operations_service.dart';
import '../../models/user_model.dart';
import '../../repositories/auth_repository.dart';

class ReturningCustomerProfileScreen extends StatefulWidget {
  final String customerId;

  const ReturningCustomerProfileScreen({super.key, required this.customerId});

  @override
  State<ReturningCustomerProfileScreen> createState() =>
      _ReturningCustomerProfileScreenState();
}

class _ReturningCustomerProfileScreenState
    extends State<ReturningCustomerProfileScreen> {
  CustomerInsight? _insight;
  UserModel? _customer;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final provider = context.read<StaffDashboardProvider>();
      final insight = await provider.loadCustomerInsight(widget.customerId);
      
      // Also load the customer's basic profile
      // We'll use the auth repository to get the user doc
      final authRepo = context.read<AuthRepository>();
      UserModel? customer;
      try {
        customer = await authRepo.getUserProfile(widget.customerId);
      } catch (_) {
        // Customer profile might not be accessible, continue without it
      }
      
      setState(() {
        _insight = insight;
        _customer = customer;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load customer data: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customer Profile')),
      body: _isLoading
          ? const Center(child: AppCircularProgressIndicator())
          : _error != null
              ? Center(child: AppErrorWidget(message: _error!, onRetry: _loadData))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Customer header
                      Center(
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundImage: _customer?.profileImageUrl != null
                                  ? NetworkImage(_customer!.profileImageUrl!)
                                  : null,
                              child: _customer?.profileImageUrl == null
                                  ? Text(
                                      _customer?.name.isNotEmpty == true
                                          ? _customer!.name[0].toUpperCase()
                                          : '?',
                                      style: const TextStyle(fontSize: 32),
                                    )
                                  : null,
                            ),
                            const SizedBox(height: AppSpacing.s),
                            Text(_customer?.name ?? 'Customer',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    )),
                            if (_customer?.email != null)
                              Text(_customer!.email,
                                  style: TextStyle(color: Colors.grey[600])),
                            if (_customer?.phone != null && _customer!.phone.isNotEmpty)
                              Text(_customer!.phone,
                                  style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.l),

                      // Stats row
                      if (_insight != null) ...[
                        Row(
                          children: [
                            Expanded(child: _StatTile(
                              label: 'Total Visits',
                              value: '${_insight!.totalVisits}',
                            )),
                            Expanded(child: _StatTile(
                              label: 'Branches',
                              value: '${_insight!.branchesVisited}',
                            )),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.m),

                        // Preferred stylist
                        if (_insight!.preferredStylist != null)
                          Card(
                            child: ListTile(
                              leading: const Icon(Icons.star, color: Colors.amber),
                              title: const Text('Preferred Stylist'),
                              subtitle: Text(_insight!.preferredStylist!),
                            ),
                          ),

                        // Most booked service
                        if (_insight!.mostBookedService != null)
                          Card(
                            child: ListTile(
                              leading: const Icon(Icons.favorite, color: Colors.red),
                              title: const Text('Most Booked Service'),
                              subtitle: Text(_insight!.mostBookedService!),
                            ),
                          ),

                        const SizedBox(height: AppSpacing.l),
                        Text('Recent History',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                )),
                        const SizedBox(height: AppSpacing.s),
                        if (_insight!.history.isEmpty)
                          const Text('No history available',
                              style: TextStyle(color: Colors.grey))
                        else
                          ...(_insight!.history.take(10).map((entry) {
                            final completedAt = entry['completedAt'];
                            String dateStr = '';
                            if (completedAt != null) {
                              try {
                                final date = (completedAt as dynamic).toDate();
                                dateStr = DateFormat('MMM dd, yyyy').format(date);
                              } catch (_) {}
                            }
                            return Card(
                              child: ListTile(
                                title: Text(entry['serviceName'] as String? ?? 'Service'),
                                subtitle: Text(
                                  '${entry['stylistName'] ?? 'Stylist'} • ${entry['branchName'] ?? 'Branch'}\n$dateStr',
                                ),
                                isThreeLine: true,
                              ),
                            );
                          })),
                      ],
                    ],
                  ),
                ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;

  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          children: [
            Text(value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    )),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
