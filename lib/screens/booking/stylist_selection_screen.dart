import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_constants.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../models/stylist_model.dart';
import '../../providers/booking_provider.dart';
import '../../providers/reference_data_provider.dart';
import 'date_time_selection_screen.dart';

class StylistSelectionScreen extends StatefulWidget {
  const StylistSelectionScreen({super.key});

  @override
  State<StylistSelectionScreen> createState() => _StylistSelectionScreenState();
}

class _StylistSelectionScreenState extends State<StylistSelectionScreen> {
  StylistModel? _selectedStylist;

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();
    final refProvider = context.watch<ReferenceDataProvider>();
    final branchId = bookingProvider.selectedBranch?.id;

    final stylists = branchId != null
        ? refProvider.stylists
            .where((s) => s.branchId == branchId && s.active)
            .toList()
        : <StylistModel>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Select Stylist')),
      body: stylists.isEmpty
          ? const Center(child: Text('No stylists available for this branch'))
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.m),
              itemCount: stylists.length,
              itemBuilder: (context, index) {
                final stylist = stylists[index];
                final isSelected = _selectedStylist?.id == stylist.id;
                return AppCard(
                  onTap: () => setState(() => _selectedStylist = stylist),
                  color: isSelected ? AppColors.primaryContainer : null,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.m),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundImage: stylist.photoUrl != null
                              ? NetworkImage(stylist.photoUrl!)
                              : null,
                          child: stylist.photoUrl == null
                              ? Text(stylist.name.isNotEmpty ? stylist.name[0].toUpperCase() : '?',
                                  style: const TextStyle(fontSize: 20))
                              : null,
                        ),
                        const SizedBox(width: AppSpacing.m),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(stylist.name,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      )),
                              const SizedBox(height: 4),
                              Text(stylist.specialization.join(', '),
                                  style: Theme.of(context).textTheme.bodySmall),
                              if (stylist.bio != null && stylist.bio!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(stylist.bio!,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                    maxLines: 2, overflow: TextOverflow.ellipsis),
                              ],
                              const SizedBox(height: 4),
                              Text('${stylist.startTime} – ${stylist.endTime}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.grey[600],
                                      )),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle, color: AppColors.primary),
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
          isDisabled: _selectedStylist == null,
          onPressed: () {
            if (_selectedStylist != null) {
              bookingProvider.selectStylist(_selectedStylist!);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DateTimeSelectionScreen()),
              );
            }
          },
        ),
      ),
    );
  }
}
