import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/widgets/app_button.dart';
import '../../models/branch_model.dart';
import '../../models/service_model.dart';
import '../../models/stylist_model.dart';
import '../../providers/reference_data_provider.dart';
import '../../providers/booking_provider.dart';
import 'date_time_selection_screen.dart';

class StylistSelectionScreen extends StatefulWidget {
  final BranchModel branch;
  final ServiceModel service;

  const StylistSelectionScreen({
    super.key,
    required this.branch,
    required this.service,
  });

  @override
  State<StylistSelectionScreen> createState() => _StylistSelectionScreenState();
}

class _StylistSelectionScreenState extends State<StylistSelectionScreen> {
  StylistModel? _selectedStylist;

  void _onContinue() {
    if (_selectedStylist != null) {
      context.read<BookingProvider>().setStylist(_selectedStylist!);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const DateTimeSelectionScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReferenceDataProvider>();
    
    // Stylists for this specific branch
    final stylists = provider.stylists.where((s) => s.branchId == widget.branch.id).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Stylist'),
      ),
      body: Column(
        children: [
          Expanded(
            child: stylists.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_off_outlined, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No stylists available at this branch',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: stylists.length,
                    itemBuilder: (context, index) {
                      final stylist = stylists[index];
                      final isSelected = _selectedStylist?.id == stylist.id;

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
                          leading: CircleAvatar(
                            radius: 28,
                            backgroundImage: stylist.photoUrl != null
                                ? NetworkImage(stylist.photoUrl!)
                                : null,
                            child: stylist.photoUrl == null
                                ? const Icon(Icons.person, size: 32)
                                : null,
                          ),
                          title: Text(
                            stylist.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Wrap(
                              spacing: 8,
                              children: stylist.specialization.map((spec) {
                                return Chip(
                                  label: Text(
                                    spec,
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                  padding: EdgeInsets.zero,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                );
                              }).toList(),
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              _selectedStylist = stylist;
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
              onPressed: _selectedStylist != null ? _onContinue : null,
              isLoading: false,
            ),
          ),
        ],
      ),
    );
  }
}
