import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../core/widgets/app_error_widget.dart';
import '../../../core/widgets/branch_card.dart';
import '../../../models/branch_model.dart';
import '../../../services/firestore_service.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  late Stream<QuerySnapshot<Map<String, dynamic>>> _branchesStream;

  @override
  void initState() {
    super.initState();
    _initStream();
  }

  void _initStream() {
    _branchesStream = context.read<FirestoreService>().streamCollection(
      collection: FirestoreCollections.branches,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Branches'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _branchesStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: AppErrorWidget(
                  message: 'Failed to load branches. Please try again.',
                  onRetry: () => setState(_initStream),
                ),
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
                  Icon(Icons.store_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No branches available',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            );
          }

          final branches = docs.map((doc) => BranchModel.fromFirestore(doc)).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: branches.length,
            itemBuilder: (context, index) {
              final branch = branches[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: BranchCard(
                  branch: branch,
                  onTap: () {
                    // Future interaction: branch details
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
