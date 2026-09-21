import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_constants.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../models/service_model.dart';
import '../../providers/booking_provider.dart';
import '../../providers/reference_data_provider.dart';
import 'stylist_selection_screen.dart';

class ServiceSelectionScreen extends StatefulWidget {
  const ServiceSelectionScreen({super.key});

  @override
  State<ServiceSelectionScreen> createState() => _ServiceSelectionScreenState();
}

class _ServiceSelectionScreenState extends State<ServiceSelectionScreen> {
  ServiceModel? _selectedService;

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();
    final refProvider = context.watch<ReferenceDataProvider>();
    final branchId = bookingProvider.selectedBranch?.id;
    
    final services = branchId != null
        ? refProvider.services.where((s) => s.branchId == branchId).toList()
        : <ServiceModel>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Select Service')),
      body: services.isEmpty
          ? const Center(child: Text('No services available for this branch'))
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.m),
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
                final isSelected = _selectedService?.id == service.id;
                return AppCard(
                  onTap: () => setState(() => _selectedService = service),
                  color: isSelected ? AppColors.primaryContainer : null,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.m),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(service.name,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      )),
                              const SizedBox(height: 4),
                              Text('${service.durationMinutes} min • ${service.category}',
                                  style: Theme.of(context).textTheme.bodySmall),
                              if (service.description.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(service.description,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis),
                              ],
                            ],
                          ),
                        ),
                        Text('₹${service.price.toStringAsFixed(0)}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                )),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: AppButton(
          text: 'Continue',
          isDisabled: _selectedService == null,
          onPressed: () {
            if (_selectedService != null) {
              bookingProvider.selectService(_selectedService!);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StylistSelectionScreen()),
              );
            }
          },
        ),
      ),
    );
  }
}
