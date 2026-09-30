import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../providers/admin_provider.dart';
import '../../staff/staff_customer_details_screen.dart';

class AdminCustomersTab extends StatefulWidget {
  const AdminCustomersTab({super.key});
  
  @override
  State<AdminCustomersTab> createState() => _AdminCustomersTabState();
}

class _AdminCustomersTabState extends State<AdminCustomersTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().listenToCustomers();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final adminProv = context.watch<AdminProvider>();
    final customers = adminProv.customers;
    
    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: customers.length,
        itemBuilder: (ctx, i) {
          final c = customers[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primaryLight,
                child: const Icon(Icons.person, color: AppColors.primary),
              ),
              title: Text(
                c.name.isEmpty ? 'Unknown Customer' : c.name,
                style: AppTypography.titleMedium,
              ),
              subtitle: Text('${c.email}\n${c.phone.isNotEmpty ? c.phone : "No phone provided"}'),
              trailing: const Icon(Icons.history, color: AppColors.textMuted),
              isThreeLine: true,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => StaffCustomerDetailsScreen(customer: c),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
