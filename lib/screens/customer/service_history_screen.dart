import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../core/widgets/app_error_widget.dart';
import '../../core/widgets/app_loading.dart';
import '../../models/service_history_model.dart';
import '../../providers/auth_provider.dart';
import '../../repositories/appointment_repository.dart';

class ServiceHistoryScreen extends StatefulWidget {
  const ServiceHistoryScreen({super.key});

  @override
  State<ServiceHistoryScreen> createState() => _ServiceHistoryScreenState();
}

class _ServiceHistoryScreenState extends State<ServiceHistoryScreen> {
  Stream<QuerySnapshot<Map<String, dynamic>>>? _historyStream;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthProvider>().currentUser?.uid;
      if (uid != null) {
        setState(() {
          _historyStream = context.read<AppointmentRepository>()
              .getCustomerServiceHistoryStream(uid);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Service History')),
      body: _historyStream == null
          ? const Center(child: Text('No history yet'))
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _historyStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: AppErrorWidget(
                      message: 'Failed to load service history',
                      onRetry: () => setState(() {}),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: AppCircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text('No service history yet',
                            style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                      ],
                    ),
                  );
                }

                final history = docs
                    .map((doc) => ServiceHistoryModel.fromFirestore(doc))
                    .toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final entry = history[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  entry.serviceName.isNotEmpty ? entry.serviceName : 'Service',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                if (entry.price > 0)
                                  Text('₹${entry.price.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold, fontSize: 16)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (entry.stylistName.isNotEmpty)
                              Text('Stylist: ${entry.stylistName}'),
                            if (entry.branchName.isNotEmpty)
                              Text('Branch: ${entry.branchName}'),
                            Text('Completed: ${DateFormat('MMM dd, yyyy').format(entry.completedAt)}'),
                            if (entry.notes.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text('Notes: ${entry.notes}',
                                  style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic)),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
