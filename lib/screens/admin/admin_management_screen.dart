import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants.dart';
import '../../models/branch_model.dart';
import '../../models/service_model.dart';
import '../../models/stylist_model.dart';
import '../../services/operations_service.dart';

class AdminManagementScreen extends StatelessWidget {
  final OperationsService operations;

  const AdminManagementScreen({super.key, required this.operations});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Network Management'),
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
            _BranchesTab(operations: operations),
            _StylistsTab(operations: operations),
            _ServicesTab(operations: operations),
          ],
        ),
      ),
    );
  }
}

class _BranchesTab extends StatelessWidget {
  final OperationsService operations;

  const _BranchesTab({required this.operations});

  @override
  Widget build(BuildContext context) {
    return _CrudList<BranchModel>(
      title: 'branch',
      stream: operations.streamCollection(FirestoreCollections.branches),
      parse: operations.branchFrom,
      label: (branch) => branch.name,
      details: (branch) => '${branch.city} • ${branch.address}',
      onAdd: () => _editBranch(context, operations),
      onEdit: (branch) => _editBranch(context, operations, branch),
      onDelete: (branch) => operations.delete(
        collection: FirestoreCollections.branches,
        documentId: branch.id,
      ),
    );
  }

  Future<void> _editBranch(
    BuildContext context,
    OperationsService operations, [
    BranchModel? branch,
  ]) async {
    final values = await _form(context, 'Branch', [
      ('Name', branch?.name ?? ''),
      ('City', branch?.city ?? ''),
      ('Address', branch?.address ?? ''),
      ('Phone', branch?.phone ?? ''),
    ]);
    if (values == null || values.any((value) => value.trim().isEmpty)) return;
    await operations.save(
      collection: FirestoreCollections.branches,
      documentId: branch?.id,
      data: BranchModel(
        id: branch?.id ?? '',
        name: values[0],
        city: values[1],
        address: values[2],
        phone: values[3],
      ).toMap(),
    );
  }
}

class _StylistsTab extends StatelessWidget {
  final OperationsService operations;

  const _StylistsTab({required this.operations});

  @override
  Widget build(BuildContext context) {
    return _CrudList<StylistModel>(
      title: 'stylist',
      stream: operations.streamCollection(FirestoreCollections.stylists),
      parse: operations.stylistFrom,
      label: (stylist) => stylist.name,
      details: (stylist) =>
          '${stylist.branchId} • ${stylist.specialization.join(', ')}',
      onAdd: () => _editStylist(context, operations),
      onEdit: (stylist) => _editStylist(context, operations, stylist),
      onDelete: (stylist) => operations.delete(
        collection: FirestoreCollections.stylists,
        documentId: stylist.id,
      ),
    );
  }

  Future<void> _editStylist(
    BuildContext context,
    OperationsService operations, [
    StylistModel? stylist,
  ]) async {
    final values = await _form(context, 'Stylist', [
      ('Name', stylist?.name ?? ''),
      ('Branch ID', stylist?.branchId ?? ''),
      (
        'Specializations (comma separated)',
        stylist?.specialization.join(', ') ?? '',
      ),
      ('Working days (comma separated)', stylist?.workingDays.join(', ') ?? ''),
    ]);
    if (values == null || values.any((value) => value.trim().isEmpty)) return;
    await operations.save(
      collection: FirestoreCollections.stylists,
      documentId: stylist?.id,
      data: StylistModel(
        id: stylist?.id ?? '',
        name: values[0],
        branchId: values[1],
        specialization: _split(values[2]),
        workingDays: _split(values[3]),
      ).toMap(),
    );
  }
}

class _ServicesTab extends StatelessWidget {
  final OperationsService operations;

  const _ServicesTab({required this.operations});

  @override
  Widget build(BuildContext context) {
    return _CrudList<ServiceModel>(
      title: 'service',
      stream: operations.streamCollection(FirestoreCollections.services),
      parse: operations.serviceFrom,
      label: (service) => service.name,
      details: (service) =>
          '${service.category} • ${service.durationMinutes} min • ${service.price.toStringAsFixed(2)}',
      onAdd: () => _editService(context, operations),
      onEdit: (service) => _editService(context, operations, service),
      onDelete: (service) => operations.delete(
        collection: FirestoreCollections.services,
        documentId: service.id,
      ),
    );
  }

  Future<void> _editService(
    BuildContext context,
    OperationsService operations, [
    ServiceModel? service,
  ]) async {
    final values = await _form(context, 'Service', [
      ('Name', service?.name ?? ''),
      ('Category', service?.category ?? ''),
      ('Price', service?.price.toString() ?? ''),
      ('Duration in minutes', service?.durationMinutes.toString() ?? ''),
      ('Branch ID', service?.branchId ?? ''),
    ]);
    final price = double.tryParse(values?[2] ?? '');
    final duration = int.tryParse(values?[3] ?? '');
    if (values == null ||
        values.any((value) => value.trim().isEmpty) ||
        price == null ||
        duration == null) {
      return;
    }
    await operations.save(
      collection: FirestoreCollections.services,
      documentId: service?.id,
      data: ServiceModel(
        id: service?.id ?? '',
        name: values[0],
        category: values[1],
        price: price,
        durationMinutes: duration,
        branchId: values[4],
      ).toMap(),
    );
  }
}

class _CrudList<T> extends StatelessWidget {
  final String title;
  final Stream<QuerySnapshot<Map<String, dynamic>>> stream;
  final T Function(DocumentSnapshot<Map<String, dynamic>> document) parse;
  final String Function(T item) label;
  final String Function(T item) details;
  final Future<void> Function() onAdd;
  final Future<void> Function(T item) onEdit;
  final Future<void> Function(T item) onDelete;

  const _CrudList({
    required this.title,
    required this.stream,
    required this.parse,
    required this.label,
    required this.details,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Unable to load $title records.'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snapshot.data!.docs.map<T>(parse).toList();
        return Scaffold(
          body: items.isEmpty
              ? Center(child: Text('No $title records yet.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Card(
                      child: ListTile(
                        title: Text(label(item)),
                        subtitle: Text(details(item)),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'edit') await onEdit(item);
                            if (value == 'delete') await onDelete(item);
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'edit', child: Text('Edit')),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: Text('Add $title'),
          ),
        );
      },
    );
  }
}

List<String> _split(String value) => value
    .split(',')
    .map((item) => item.trim())
    .where((item) => item.isNotEmpty)
    .toList();

Future<List<String>?> _form(
  BuildContext context,
  String title,
  List<(String, String)> fields,
) async {
  final controllers = fields
      .map((field) => TextEditingController(text: field.$2))
      .toList();
  final result = await showDialog<List<String>>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('$title details'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var index = 0; index < fields.length; index++)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextField(
                  controller: controllers[index],
                  decoration: InputDecoration(labelText: fields[index].$1),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(
            context,
            controllers.map((controller) => controller.text.trim()).toList(),
          ),
          child: const Text('Save'),
        ),
      ],
    ),
  );
  for (final controller in controllers) {
    controller.dispose();
  }
  return result;
}
