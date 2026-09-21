import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_constants.dart';
import '../../core/widgets/app_loading.dart';
import '../../models/user_model.dart';
import '../../providers/staff_dashboard_provider.dart';

class CustomerSearchScreen extends StatefulWidget {
  const CustomerSearchScreen({super.key});

  @override
  State<CustomerSearchScreen> createState() => _CustomerSearchScreenState();
}

class _CustomerSearchScreenState extends State<CustomerSearchScreen> {
  final _searchController = TextEditingController();
  List<UserModel> _results = [];
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() { _results = []; _error = null; });
      return;
    }

    setState(() { _isLoading = true; _error = null; });
    try {
      final staffProvider = context.read<StaffDashboardProvider>();
      final rawResults = await staffProvider.searchCustomers(query.trim());
      setState(() {
        _results = rawResults.map((data) => UserModel.fromMap(data, data['uid'] as String? ?? '')).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Search failed: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customer Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, email, or phone...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() { _results = []; });
                        },
                      )
                    : null,
              ),
              onSubmitted: _search,
              onChanged: (value) {
                if (value.length >= 3) _search(value);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(AppSpacing.m),
              child: AppCircularProgressIndicator(),
            ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          Expanded(
            child: _results.isEmpty && !_isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_search, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          _searchController.text.isEmpty
                              ? 'Search for customers by name, email, or phone'
                              : 'No customers found',
                          style: TextStyle(color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      final user = _results[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: user.profileImageUrl != null
                              ? NetworkImage(user.profileImageUrl!)
                              : null,
                          child: user.profileImageUrl == null
                              ? Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?')
                              : null,
                        ),
                        title: Text(user.name),
                        subtitle: Text('${user.email} • ${user.phone}'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/customer-profile',
                            arguments: user.uid,
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
