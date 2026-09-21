import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/branch_model.dart';
import '../../providers/booking_provider.dart';
import '../../providers/reference_data_provider.dart';
import '../booking/service_selection_screen.dart';

class BranchDetailsScreen extends StatelessWidget {
  final BranchModel branch;

  const BranchDetailsScreen({super.key, required this.branch});

  @override
  Widget build(BuildContext context) {
    final refProvider = context.watch<ReferenceDataProvider>();
    final branchStylists = refProvider.stylists
        .where((s) => s.branchId == branch.id)
        .toList();
    final branchServices = refProvider.services
        .where((s) => s.branchId == branch.id)
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(branch.name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Branch image
            if (branch.imageUrl != null && branch.imageUrl!.isNotEmpty)
              Image.network(
                branch.imageUrl!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: const Icon(Icons.store, size: 64, color: Colors.grey),
                ),
              )
            else
              Container(
                height: 200,
                width: double.infinity,
                color: Colors.grey[200],
                child: const Icon(Icons.store, size: 64, color: Colors.grey),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Contact info
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Text(branch.address)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.phone_outlined, size: 18),
                      const SizedBox(width: 8),
                      Text(branch.phone),
                    ],
                  ),

                  // Opening Hours
                  if (branch.openingHours.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text('Opening Hours',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            )),
                    const SizedBox(height: 8),
                    ...branch.openingHours.entries.map((entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(entry.key, style: Theme.of(context).textTheme.bodyMedium),
                              Text(entry.value,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppColors.textSecondary,
                                      )),
                            ],
                          ),
                        )),
                  ],

                  // Stylists
                  const SizedBox(height: 20),
                  Text('Stylists (${branchStylists.length})',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          )),
                  const SizedBox(height: 8),
                  if (branchStylists.isEmpty)
                    const Text('No stylists available', style: TextStyle(color: Colors.grey))
                  else
                    ...branchStylists.map((stylist) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundImage: stylist.photoUrl != null
                                ? NetworkImage(stylist.photoUrl!)
                                : null,
                            child: stylist.photoUrl == null
                                ? Text(stylist.name.isNotEmpty ? stylist.name[0].toUpperCase() : '?')
                                : null,
                          ),
                          title: Text(stylist.name),
                          subtitle: Text(stylist.specialization.join(', ')),
                        )),

                  // Services
                  const SizedBox(height: 20),
                  Text('Services (${branchServices.length})',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          )),
                  const SizedBox(height: 8),
                  if (branchServices.isEmpty)
                    const Text('No services available', style: TextStyle(color: Colors.grey))
                  else
                    ...branchServices.map((service) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(service.name),
                          subtitle: Text('${service.durationMinutes} min • ${service.category}'),
                          trailing: Text('₹${service.price.toStringAsFixed(0)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        )),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.read<BookingProvider>().selectBranch(branch);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ServiceSelectionScreen()),
          );
        },
        icon: const Icon(Icons.calendar_today),
        label: const Text('Book Now'),
      ),
    );
  }
}
