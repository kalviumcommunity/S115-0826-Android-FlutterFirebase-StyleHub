import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_constants.dart';
import '../../core/widgets/app_loading.dart';
import '../../core/widgets/app_error_widget.dart';
import '../../models/branch_model.dart';
import '../../models/stylist_model.dart';
import '../../models/service_model.dart';
import '../../providers/reference_data_provider.dart';
import '../../widgets/data_state_view.dart';

class AdminManagementScreen extends StatefulWidget {
  const AdminManagementScreen({super.key});

  @override
  State<AdminManagementScreen> createState() => _AdminManagementScreenState();
}

class _AdminManagementScreenState extends State<AdminManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ReferenceDataProvider>();
      if (provider.branches.isEmpty && !provider.isLoading) {
        provider.initialize();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Branches'),
            Tab(text: 'Stylists'),
            Tab(text: 'Services'),
          ],
        ),
      ),
      body: Consumer<ReferenceDataProvider>(
        builder: (context, provider, _) {
          return TabBarView(
            controller: _tabController,
            children: [
              _BranchesTab(provider: provider),
              _StylistsTab(provider: provider),
              _ServicesTab(provider: provider),
            ],
          );
        },
      ),
    );
  }
}

class _BranchesTab extends StatelessWidget {
  final ReferenceDataProvider provider;
  const _BranchesTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DataStateView<List<BranchModel>>(
        isLoading: provider.isLoading,
        error: provider.error,
        data: provider.branches,
        onRetry: () => provider.initialize(),
        successBuilder: (branches) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: branches.length,
          itemBuilder: (context, index) {
            final branch = branches[index];
            return Card(
              child: ListTile(
                title: Text(branch.name),
                subtitle: Text('${branch.city} • ${branch.address}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showBranchDialog(context, branch: branch),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDelete(context, branch.id, 'branch'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBranchDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showBranchDialog(BuildContext context, {BranchModel? branch}) {
    final nameCtrl = TextEditingController(text: branch?.name ?? '');
    final cityCtrl = TextEditingController(text: branch?.city ?? '');
    final addressCtrl = TextEditingController(text: branch?.address ?? '');
    final phoneCtrl = TextEditingController(text: branch?.phone ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(branch == null ? 'Add Branch' : 'Edit Branch'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: cityCtrl, decoration: const InputDecoration(labelText: 'City')),
              TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: 'Address')),
              TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final data = {
                'name': nameCtrl.text.trim(),
                'city': cityCtrl.text.trim(),
                'address': addressCtrl.text.trim(),
                'phone': phoneCtrl.text.trim(),
              };
              try {
                if (branch == null) {
                  await provider.createBranch(data);
                } else {
                  await provider.updateBranch(branch.id, data);
                }
                if (ctx.mounted) Navigator.pop(ctx);
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: Text(branch == null ? 'Create' : 'Update'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id, String type) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete $type?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                await provider.deleteBranch(id);
                if (ctx.mounted) Navigator.pop(ctx);
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _StylistsTab extends StatelessWidget {
  final ReferenceDataProvider provider;
  const _StylistsTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DataStateView<List<StylistModel>>(
        isLoading: provider.isLoading,
        error: provider.error,
        data: provider.stylists,
        onRetry: () => provider.initialize(),
        successBuilder: (stylists) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: stylists.length,
          itemBuilder: (context, index) {
            final stylist = stylists[index];
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(stylist.name.isNotEmpty ? stylist.name[0] : '?'),
                ),
                title: Text(stylist.name),
                subtitle: Text('${stylist.specialization.join(', ')} • ${stylist.active ? 'Active' : 'Inactive'}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showStylistDialog(context, stylist: stylist),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        try { await provider.deleteStylist(stylist.id); }
                        catch (e) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'))); }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showStylistDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showStylistDialog(BuildContext context, {StylistModel? stylist}) {
    final nameCtrl = TextEditingController(text: stylist?.name ?? '');
    final branchIdCtrl = TextEditingController(text: stylist?.branchId ?? '');
    final specCtrl = TextEditingController(text: stylist?.specialization.join(', ') ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(stylist == null ? 'Add Stylist' : 'Edit Stylist'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
              // Branch picker - show dropdown of available branches
              DropdownButtonFormField<String>(
                value: branchIdCtrl.text.isNotEmpty ? branchIdCtrl.text : null,
                decoration: const InputDecoration(labelText: 'Branch'),
                items: provider.branches.map((b) => DropdownMenuItem(
                  value: b.id,
                  child: Text(b.name),
                )).toList(),
                onChanged: (v) => branchIdCtrl.text = v ?? '',
              ),
              TextField(controller: specCtrl, decoration: const InputDecoration(labelText: 'Specializations (comma separated)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final data = {
                'name': nameCtrl.text.trim(),
                'branchId': branchIdCtrl.text.trim(),
                'specialization': specCtrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
                'active': true,
                'startTime': '09:00',
                'endTime': '18:00',
                'breakStart': '13:00',
                'breakEnd': '14:00',
                'workingDays': ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'],
              };
              try {
                if (stylist == null) {
                  await provider.createStylist(data);
                } else {
                  await provider.updateStylist(stylist.id, data);
                }
                if (ctx.mounted) Navigator.pop(ctx);
              } catch (e) {
                if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: Text(stylist == null ? 'Create' : 'Update'),
          ),
        ],
      ),
    );
  }
}

class _ServicesTab extends StatelessWidget {
  final ReferenceDataProvider provider;
  const _ServicesTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DataStateView<List<ServiceModel>>(
        isLoading: provider.isLoading,
        error: provider.error,
        data: provider.services,
        onRetry: () => provider.initialize(),
        successBuilder: (services) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: services.length,
          itemBuilder: (context, index) {
            final service = services[index];
            return Card(
              child: ListTile(
                title: Text(service.name),
                subtitle: Text('${service.category} • ₹${service.price.toStringAsFixed(0)} • ${service.durationMinutes} min'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showServiceDialog(context, service: service),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        try { await provider.deleteService(service.id); }
                        catch (e) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'))); }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showServiceDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showServiceDialog(BuildContext context, {ServiceModel? service}) {
    final nameCtrl = TextEditingController(text: service?.name ?? '');
    final categoryCtrl = TextEditingController(text: service?.category ?? '');
    final descCtrl = TextEditingController(text: service?.description ?? '');
    final priceCtrl = TextEditingController(text: service?.price.toString() ?? '');
    final durationCtrl = TextEditingController(text: service?.durationMinutes.toString() ?? '');
    final branchIdCtrl = TextEditingController(text: service?.branchId ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(service == null ? 'Add Service' : 'Edit Service'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: categoryCtrl, decoration: const InputDecoration(labelText: 'Category')),
              TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description')),
              TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Price (₹)'), keyboardType: TextInputType.number),
              TextField(controller: durationCtrl, decoration: const InputDecoration(labelText: 'Duration (minutes)'), keyboardType: TextInputType.number),
              DropdownButtonFormField<String>(
                value: branchIdCtrl.text.isNotEmpty ? branchIdCtrl.text : null,
                decoration: const InputDecoration(labelText: 'Branch'),
                items: provider.branches.map((b) => DropdownMenuItem(
                  value: b.id,
                  child: Text(b.name),
                )).toList(),
                onChanged: (v) => branchIdCtrl.text = v ?? '',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final data = {
                'name': nameCtrl.text.trim(),
                'category': categoryCtrl.text.trim(),
                'description': descCtrl.text.trim(),
                'price': double.tryParse(priceCtrl.text) ?? 0.0,
                'durationMinutes': int.tryParse(durationCtrl.text) ?? 30,
                'branchId': branchIdCtrl.text.trim(),
              };
              try {
                if (service == null) {
                  await provider.createService(data);
                } else {
                  await provider.updateService(service.id, data);
                }
                if (ctx.mounted) Navigator.pop(ctx);
              } catch (e) {
                if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: Text(service == null ? 'Create' : 'Update'),
          ),
        ],
      ),
    );
  }
}
