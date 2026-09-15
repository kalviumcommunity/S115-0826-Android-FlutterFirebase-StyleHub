import 'package:flutter/material.dart';
import '../../models/branch_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_constants.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';

class ServiceSelectionScreen extends StatefulWidget {
  final BranchModel branch;

  const ServiceSelectionScreen({
    super.key,
    required this.branch,
  });

  @override
  State<ServiceSelectionScreen> createState() => _ServiceSelectionScreenState();
}

class _ServiceSelectionScreenState extends State<ServiceSelectionScreen> {
  // Temporary static data for scaffolding purposes.
  // This will be replaced by a live service stream later.
  final List<Map<String, dynamic>> _dummyServices = [
    {
      'id': 's1',
      'name': 'Men\'s Haircut',
      'duration': '30 min',
      'price': '\$25',
      'category': 'Hair',
    },
    {
      'id': 's2',
      'name': 'Women\'s Haircut',
      'duration': '60 min',
      'price': '\$45',
      'category': 'Hair',
    },
    {
      'id': 's3',
      'name': 'Hair Coloring',
      'duration': '120 min',
      'price': '\$90',
      'category': 'Color',
    },
    {
      'id': 's4',
      'name': 'Beard Trim',
      'duration': '20 min',
      'price': '\$15',
      'category': 'Grooming',
    },
  ];

  String? _selectedServiceId;

  void _onContinue() {
    if (_selectedServiceId != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Next step: Stylist Selection (Not implemented yet)')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Service'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Selected Branch Info
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Row(
              children: [
                const Icon(Icons.store, color: AppColors.textSecondary),
                const SizedBox(width: AppSpacing.s),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Booking at',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                      Text(
                        '${widget.branch.name} - ${widget.branch.city}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Services List
          Expanded(
            child: _buildServiceList(),
          ),
          // Continue Button
          Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: AppButton(
              text: 'Continue',
              onPressed: _selectedServiceId != null ? _onContinue : null,
              isLoading: false,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the service list UI.
  /// 
  /// In the future, wrap this with a StreamBuilder/FutureBuilder
  /// connecting to the real service backend.
  Widget _buildServiceList() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.m),
      itemCount: _dummyServices.length,
      itemBuilder: (context, index) {
        final service = _dummyServices[index];
        final isSelected = _selectedServiceId == service['id'];

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.s),
          child: AppCard(
            onTap: () {
              setState(() {
                _selectedServiceId = service['id'] as String;
              });
            },
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service['name'] as String,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${service['category']} • ${service['duration']}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                Text(
                  service['price'] as String,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(width: AppSpacing.m),
                Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: isSelected 
                      ? Theme.of(context).colorScheme.primary 
                      : AppColors.textSecondary,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
