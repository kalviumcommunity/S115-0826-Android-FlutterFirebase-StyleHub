import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stylehub/providers/reference_data_provider.dart';
import 'package:stylehub/widgets/data_state_view.dart';
import 'package:stylehub/widgets/domain_cards.dart';
import 'package:stylehub/widgets/primary_button.dart';
import 'package:stylehub/widgets/custom_text_field.dart';
import 'package:stylehub/core/theme/app_colors.dart';
import 'package:stylehub/core/theme/app_typography.dart';
import 'package:stylehub/core/theme/app_constants.dart';

class AdminManagementScreen extends StatefulWidget {
  const AdminManagementScreen({super.key});

  @override
  State<AdminManagementScreen> createState() => _AdminManagementScreenState();
}

class _AdminManagementScreenState extends State<AdminManagementScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReferenceDataProvider>();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Management'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Branches'),
              Tab(text: 'Stylists'),
              Tab(text: 'Services'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildManagementTab(
              title: 'Manage Branches',
              data: provider.branches,
              isLoading: provider.branchesLoading,
              errorMessage: provider.branchesError,
              itemBuilder: (branch) => BranchCard(
                branch: branch,
                onTap: () => _showEditDialog(context, 'Branch', branch),
              ),
              onAdd: () => _showAddDialog(context, 'Branch'),
            ),
            _buildManagementTab(
              title: 'Manage Stylists',
              data: provider.stylists,
              isLoading: provider.stylistsLoading,
              errorMessage: provider.stylistsError,
              itemBuilder: (stylist) => StylistCard(
                stylist: stylist,
                onTap: () => _showEditDialog(context, 'Stylist', stylist),
              ),
              onAdd: () => _showAddDialog(context, 'Stylist'),
            ),
            _buildManagementTab(
              title: 'Manage Services',
              data: provider.services,
              isLoading: provider.servicesLoading,
              errorMessage: provider.servicesError,
              itemBuilder: (service) => ListTile(
                title: Text(service.name),
                subtitle: Text('\$${service.price}'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditDialog(context, 'Service', service),
                ),
              ),
              onAdd: () => _showAddDialog(context, 'Service'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementTab({
    required String title,
    required List<dynamic> data,
    required bool isLoading,
    required String? errorMessage,
    required Widget Function(dynamic) itemBuilder,
    required VoidCallback onAdd,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTypography.titleMedium),
              PrimaryButton(
                text: 'Add New',
                onPressed: onAdd,
                isLoading: false,
              ),
            ],
          ),
        ),
        Expanded(
          child: DataStateView<List<dynamic>>(
            isLoading: isLoading,
            errorMessage: errorMessage,
            isEmpty: data.isEmpty && !isLoading,
            data: data,
            successBuilder: (list) {
              return ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.m),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s),
                itemBuilder: (context, index) => itemBuilder(list[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddDialog(BuildContext context, String type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: AppSpacing.m,
          right: AppSpacing.m,
          top: AppSpacing.m,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Add New $type', style: AppTypography.titleMedium),
            const SizedBox(height: AppSpacing.m),
            CustomTextField(label: 'Name', hint: 'Enter $type name', controller: TextEditingController()),
            const SizedBox(height: AppSpacing.m),
            PrimaryButton(text: 'Save', onPressed: () => Navigator.pop(context)),
            const SizedBox(height: AppSpacing.m),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, String type, dynamic item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: AppSpacing.m,
          right: AppSpacing.m,
          top: AppSpacing.m,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Edit $type', style: AppTypography.titleMedium),
            const SizedBox(height: AppSpacing.m),
            CustomTextField(label: 'Name', hint: 'Edit name', controller: TextEditingController()),
            const SizedBox(height: AppSpacing.m),
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(text: 'Delete', onPressed: () => Navigator.pop(context)),
                ),
                const SizedBox(width: AppSpacing.s),
                Expanded(
                  child: PrimaryButton(text: 'Update', onPressed: () => Navigator.pop(context)),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.m),
          ],
        ),
      ),
    );
  }
}
