import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_button.dart';
import '../../../models/user_model.dart';
import '../../../providers/admin_provider.dart';
import '../../../providers/branch_provider.dart';

class AdminStaffTab extends StatefulWidget {
  const AdminStaffTab({super.key});
  
  @override
  State<AdminStaffTab> createState() => _AdminStaffTabState();
}

class _AdminStaffTabState extends State<AdminStaffTab> {
  String _selectedBranchFilter = 'All';
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().listenToStaff();
    });
  }
  
  void _showCreateStaffDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController(text: '+91 ');
    final passwordCtrl = TextEditingController();
    String gender = 'Prefer not to say';
    String? selectedBranchId;
    
    final branchProv = context.read<BranchProvider>();
    final branches = branchProv.branches.where((b) => b.isActive).toList();
    if (branches.isNotEmpty) selectedBranchId = branches.first.branchId;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          final adminProv = context.watch<AdminProvider>();
          
          return AlertDialog(
            title: const Text('Provision Staff Account'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name')),
                  TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email Address')),
                  TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone Number')),
                  TextField(controller: passwordCtrl, decoration: const InputDecoration(labelText: 'Temporary Password')),
                  DropdownButtonFormField<String>(
                    value: gender,
                    decoration: const InputDecoration(labelText: 'Gender'),
                    items: const [
                      DropdownMenuItem(value: 'Male', child: Text('Male')),
                      DropdownMenuItem(value: 'Female', child: Text('Female')),
                      DropdownMenuItem(value: 'Other', child: Text('Other')),
                      DropdownMenuItem(value: 'Prefer not to say', child: Text('Prefer not to say')),
                    ],
                    onChanged: (val) => setState(() => gender = val!),
                  ),
                  DropdownButtonFormField<String?>(
                    value: selectedBranchId,
                    decoration: const InputDecoration(labelText: 'Assign Branch'),
                    items: branches.map((b) => DropdownMenuItem(
                      value: b.branchId,
                      child: Text(b.name),
                    )).toList(),
                    onChanged: (val) => setState(() => selectedBranchId = val),
                  ),
                  if (adminProv.errorMessage != null) ...[
                    const SizedBox(height: 10),
                    Text(adminProv.errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                  ]
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: adminProv.isLoading ? null : () => Navigator.of(ctx).pop(),
                child: const Text('Cancel')
              ),
              AppButton(
                label: 'Create',
                height: 38,
                isLoading: adminProv.isLoading,
                onPressed: () async {
                  if (nameCtrl.text.isEmpty || emailCtrl.text.isEmpty || phoneCtrl.text.isEmpty || passwordCtrl.text.isEmpty || selectedBranchId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All fields are required.')));
                    return;
                  }
                  
                  try {
                    await context.read<AdminProvider>().createStaffAccount(
                      name: nameCtrl.text.trim(),
                      email: emailCtrl.text.trim(),
                      phone: phoneCtrl.text.trim(),
                      gender: gender,
                      assignedBranchId: selectedBranchId!,
                      password: passwordCtrl.text,
                    );
                    if (ctx.mounted) {
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Staff account successfully created.')));
                    }
                  } catch (e) {
                    // Error is displayed via provider errorMessage state.
                  }
                },
              ),
            ],
          );
        }
      ),
    );
  }
  
  void _showAssignBranchDialog(BuildContext context, UserModel staff) {
    final branchProv = context.read<BranchProvider>();
    String? selectedBranchId = staff.assignedBranchId;
    
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Assign/Reassign Branch'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Staff: ${staff.name}'),
              const SizedBox(height: 16),
              DropdownButtonFormField<String?>(
                value: selectedBranchId,
                decoration: const InputDecoration(labelText: 'Select Branch'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Unassigned')),
                  ...branchProv.branches.map((b) => DropdownMenuItem(
                        value: b.branchId,
                        child: Text(b.name),
                      )),
                ],
                onChanged: (val) => setState(() => selectedBranchId = val),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            AppButton(
              label: 'Save Assignment',
              height: 38,
              isLoading: context.watch<AdminProvider>().isLoading,
              onPressed: () async {
                await context.read<AdminProvider>().updateStaffBranch(staff.uid, selectedBranchId);
                if (ctx.mounted) Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
  
  void _showEditStaffDialog(BuildContext context, UserModel staff) {
    final nameCtrl = TextEditingController(text: staff.name);
    final phoneCtrl = TextEditingController(text: staff.phone);
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Staff Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          AppButton(
            label: 'Save',
            height: 38,
            isLoading: context.watch<AdminProvider>().isLoading,
            onPressed: () async {
              await context.read<AdminProvider>().updateStaffDetails(staff.uid, nameCtrl.text, phoneCtrl.text);
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }
  
  void _toggleStaffStatus(BuildContext context, UserModel staff) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(staff.isActive ? 'Deactivate Staff?' : 'Activate Staff?'),
        content: Text(
          staff.isActive
              ? 'Are you sure you want to deactivate ${staff.name}? They will lose dashboard access.'
              : 'Are you sure you want to activate ${staff.name}?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          AppButton(
            label: 'Confirm',
            height: 38,
            isLoading: context.watch<AdminProvider>().isLoading,
            onPressed: () async {
              await context.read<AdminProvider>().toggleUserStatus(staff.uid, !staff.isActive);
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final adminProv = context.watch<AdminProvider>();
    final branchProv = context.watch<BranchProvider>();
    
    final staffList = adminProv.staffMembers.where((s) {
      if (_selectedBranchFilter == 'All') return true;
      if (_selectedBranchFilter == 'Unassigned') return s.assignedBranchId == null;
      return s.assignedBranchId == _selectedBranchFilter;
    }).toList();
    
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<String>(
              value: _selectedBranchFilter,
              decoration: const InputDecoration(labelText: 'Filter by Branch'),
              items: [
                const DropdownMenuItem(value: 'All', child: Text('All Branches')),
                const DropdownMenuItem(value: 'Unassigned', child: Text('Unassigned Staff')),
                ...branchProv.branches.map((b) => DropdownMenuItem(
                      value: b.branchId,
                      child: Text(b.name),
                    )),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _selectedBranchFilter = val);
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: staffList.length,
              itemBuilder: (ctx, i) {
                final staff = staffList[i];
                final branchName = branchProv.branches
                    .where((b) => b.branchId == staff.assignedBranchId)
                    .map((b) => b.name)
                    .firstWhere((_) => true, orElse: () => 'Unassigned');
                    
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: staff.isActive ? AppColors.primaryLight : Colors.grey,
                      child: Icon(Icons.badge, color: staff.isActive ? AppColors.primary : Colors.white),
                    ),
                    title: Text(
                      staff.name,
                      style: AppTypography.titleMedium.copyWith(
                        color: staff.isActive ? AppColors.textPrimary : Colors.grey,
                      ),
                    ),
                    subtitle: Text('${staff.email}\nBranch: $branchName • ${staff.phone}'),
                    trailing: PopupMenuButton<String>(
                      onSelected: (val) {
                        if (val == 'edit') {
                          _showEditStaffDialog(context, staff);
                        } else if (val == 'assign') {
                          _showAssignBranchDialog(context, staff);
                        } else if (val == 'toggle') {
                          _toggleStaffStatus(context, staff);
                        }
                      },
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit Details')),
                        const PopupMenuItem(value: 'assign', child: Text('Reassign Branch')),
                        PopupMenuItem(
                          value: 'toggle',
                          child: Text(staff.isActive ? 'Deactivate' : 'Activate'),
                        ),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () => _showCreateStaffDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Staff'),
      ),
    );
  }
}