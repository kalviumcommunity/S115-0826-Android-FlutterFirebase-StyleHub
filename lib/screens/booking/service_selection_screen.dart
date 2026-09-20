import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/widgets/app_button.dart';
import '../../models/branch_model.dart';
import '../../models/service_model.dart';
import '../../providers/reference_data_provider.dart';
import '../../providers/booking_provider.dart';
import 'stylist_selection_screen.dart';

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
  ServiceModel? _selectedService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().setBranch(widget.branch);
    });
  }

  void _onContinue() {
    if (_selectedService != null) {
      context.read<BookingProvider>().setService(_selectedService!);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StylistSelectionScreen(
            branch: widget.branch,
            service: _selectedService!,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReferenceDataProvider>();
    
    // Services for this specific branch
    final services = provider.services.where((s) => s.branchId == widget.branch.id).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Service'),
      ),
      body: Column(
        children: [
          Expanded(
            child: services.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.spa_outlined, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No services available at this branch',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      final service = services[index];
                      final isSelected = _selectedService?.id == service.id;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey.shade200,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            service.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(service.category),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$${service.price.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${service.durationMinutes} min',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                              ),
                            ],
                          ),
                          onTap: () {
                            setState(() {
                              _selectedService = service;
                            });
                          },
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: AppButton(
              text: 'Continue',
              onPressed: _selectedService != null ? _onContinue : null,
              isLoading: false,
            ),
          ),
        ],
      ),
    );
  }
}
