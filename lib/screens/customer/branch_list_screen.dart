import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stylehub/providers/reference_data_provider.dart';
import 'package:stylehub/widgets/data_state_view.dart';
import 'package:stylehub/widgets/domain_cards.dart';
import 'package:stylehub/core/theme/app_constants.dart';

class BranchListScreen extends StatefulWidget {
  const BranchListScreen({super.key});

  @override
  State<BranchListScreen> createState() => _BranchListScreenState();
}

class _BranchListScreenState extends State<BranchListScreen> {
  @override
  void initState() {
    super.initState();
    // Ensure data is loaded when entering the home screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReferenceDataProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReferenceDataProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Salons'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search logic
            },
          ),
        ],
      ),
      body: DataStateView<List<dynamic>>(
        isLoading: provider.branchesLoading,
        errorMessage: provider.branchesError,
        isEmpty: provider.branches.isEmpty && !provider.branchesLoading,
        data: provider.branches,
        successBuilder: (branches) {
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.m),
            itemCount: branches.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.s),
            itemBuilder: (context, index) {
              final branch = branches[index];
              return BranchCard(
                branch: branch,
                onTap: () {
                  Navigator.of(context).pushNamed(
                    '/branch-details',
                    arguments: branch,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
