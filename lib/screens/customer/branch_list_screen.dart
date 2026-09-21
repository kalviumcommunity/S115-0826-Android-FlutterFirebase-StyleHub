import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_constants.dart';
import '../../core/widgets/app_loading.dart';
import '../../core/widgets/app_error_widget.dart';
import '../../models/branch_model.dart';
import '../../providers/reference_data_provider.dart';
import '../../widgets/data_state_view.dart';
import 'branch_details_screen.dart';

class BranchListScreen extends StatefulWidget {
  const BranchListScreen({super.key});

  @override
  State<BranchListScreen> createState() => _BranchListScreenState();
}

class _BranchListScreenState extends State<BranchListScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ReferenceDataProvider>();
      if (provider.branches.isEmpty && !provider.isLoading) {
        provider.initialize();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Branches'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: _BranchSearchDelegate(
                  branches: context.read<ReferenceDataProvider>().branches,
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<ReferenceDataProvider>(
        builder: (context, provider, _) {
          return DataStateView<List<BranchModel>>(
            isLoading: provider.isLoading,
            error: provider.error,
            data: provider.branches,
            onRetry: () => provider.initialize(),
            emptyBuilder: () => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.store_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('No branches available',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[600],
                          )),
                ],
              ),
            ),
            successBuilder: (branches) {
              final filtered = _searchQuery.isEmpty
                  ? branches
                  : branches.where((b) =>
                      b.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                      b.city.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
              
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final branch = filtered[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BranchDetailsScreen(branch: branch),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (branch.imageUrl != null && branch.imageUrl!.isNotEmpty)
                            Image.network(
                              branch.imageUrl!,
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height: 150,
                                color: Colors.grey[200],
                                child: const Icon(Icons.store, size: 50, color: Colors.grey),
                              ),
                            )
                          else
                            Container(
                              height: 150,
                              width: double.infinity,
                              color: Colors.grey[200],
                              child: const Icon(Icons.store, size: 50, color: Colors.grey),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(branch.name,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        )),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Expanded(child: Text('${branch.city} • ${branch.address}',
                                        style: Theme.of(context).textTheme.bodySmall,
                                        maxLines: 1, overflow: TextOverflow.ellipsis)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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

class _BranchSearchDelegate extends SearchDelegate<BranchModel?> {
  final List<BranchModel> branches;
  _BranchSearchDelegate({required this.branches});

  @override
  List<Widget> buildActions(BuildContext context) => [
        IconButton(icon: const Icon(Icons.clear), onPressed: () { query = ''; }),
      ];

  @override
  Widget buildLeading(BuildContext context) =>
      IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, null));

  @override
  Widget buildResults(BuildContext context) => _buildList(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildList(context);

  Widget _buildList(BuildContext context) {
    final results = branches.where((b) =>
        b.name.toLowerCase().contains(query.toLowerCase()) ||
        b.city.toLowerCase().contains(query.toLowerCase())).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final branch = results[index];
        return ListTile(
          leading: const Icon(Icons.store),
          title: Text(branch.name),
          subtitle: Text(branch.city),
          onTap: () {
            close(context, branch);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BranchDetailsScreen(branch: branch),
              ),
            );
          },
        );
      },
    );
  }
}
