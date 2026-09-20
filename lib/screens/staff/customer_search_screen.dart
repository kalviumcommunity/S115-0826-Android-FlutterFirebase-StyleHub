import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stylehub/providers/staff_dashboard_provider.dart';
import 'package:stylehub/widgets/data_state_view.dart';
import 'package:stylehub/widgets/custom_text_field.dart';
import 'package:stylehub/widgets/primary_button.dart';
import 'package:stylehub/core/theme/app_colors.dart';
import 'package:stylehub/core/theme/app_typography.dart';
import 'package:stylehub/core/theme/app_constants.dart';

class CustomerSearchScreen extends StatefulWidget {
  const CustomerSearchScreen({super.key});

  @override
  State<CustomerSearchScreen> createState() => _CustomerSearchScreenState();
}

class _CustomerSearchScreenState extends State<CustomerSearchScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StaffDashboardProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Search Customers')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          children: [
            CustomTextField(
              label: 'Search',
              hint: 'Search by phone or email...',
              controller: _searchController,
              prefixIcon: const Icon(Icons.search),
              onChanged: (value) {
                context.read<StaffDashboardProvider>().updateSearch(value);
              },
            ),
            const SizedBox(height: AppSpacing.l),
            Expanded(
              child: DataStateView<List<dynamic>>(
                isLoading: provider.isLoading,
                errorMessage: provider.errorMessage,
                isEmpty: provider.customers.isEmpty,
                data: provider.customers,
                successBuilder: (customers) {
                  return ListView.separated(
                    itemCount: customers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s),
                    itemBuilder: (context, index) {
                      final user = customers[index];
                      return ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(user.displayName ?? 'Unknown User'),
                        subtitle: Text(user.email ?? ''),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.of(context).pushNamed('/customer-profile');
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
