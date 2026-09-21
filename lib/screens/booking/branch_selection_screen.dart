import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_loading.dart';
import '../../core/widgets/app_error_widget.dart';
import '../../core/widgets/branch_card.dart';
import '../../models/branch_model.dart';
import '../../providers/reference_data_provider.dart';
import 'service_selection_screen.dart';

class BranchSelectionScreen extends StatefulWidget {
  const BranchSelectionScreen({super.key});

  @override
  State<BranchSelectionScreen> createState() => _BranchSelectionScreenState();
}

class _BranchSelectionScreenState extends State<BranchSelectionScreen> {
  BranchModel? _selectedBranch;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReferenceDataProvider>().initialize();
    });
  }

  void _onContinue() {
    if (_selectedBranch != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ServiceSelectionScreen(
            branch: _selectedBranch!,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReferenceDataProvider>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Branch'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Builder(
              builder: (context) {
                if (provider.branchesError != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: AppErrorWidget(
                        message: 'Failed to load branches. Please try again.',
                        onRetry: () => provider.initialize(),
                      ),
                    ),
                  );
                }

                if (provider.branchesLoading) {
                  return const Center(child: AppCircularProgressIndicator());
                }

                final branches = provider.branches;

                if (branches.isEmpty) {
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

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: branches.length,
                  itemBuilder: (context, index) {
                    final branch = branches[index];
                    final isSelected = _selectedBranch?.id == branch.id;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Stack(
                        children: [
                          BranchCard(
                            branch: branch,
                            onTap: () {
                              setState(() {
                                _selectedBranch = branch;
                              });
                            },
                          ),
                          if (isSelected)
                            Positioned.fill(
                              child: IgnorePointer(
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Theme.of(context).colorScheme.primary,
                                      width: 3,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                          if (isSelected)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: CircleAvatar(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                radius: 14,
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: AppButton(
              text: 'Continue',
              onPressed: _selectedBranch != null ? _onContinue : null,
              isLoading: false,
            ),
          ),
        ],
      ),
    );
  }
}
