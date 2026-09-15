import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/branch_model.dart';
import '../../models/stylist_model.dart';
import '../../core/constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_constants.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_loading.dart';
import '../../core/widgets/app_error_widget.dart';
import '../../services/firestore_service.dart';
import '../../providers/booking_provider.dart';
import 'date_time_selection_screen.dart';

class StylistSelectionScreen extends StatefulWidget {
  final BranchModel branch;

  const StylistSelectionScreen({
    super.key,
    required this.branch,
  });

  @override
  State<StylistSelectionScreen> createState() => _StylistSelectionScreenState();
}

class _StylistSelectionScreenState extends State<StylistSelectionScreen> {
  late Stream<QuerySnapshot<Map<String, dynamic>>> _stylistsStream;
  StylistModel? _selectedStylist;

  @override
  void initState() {
    super.initState();
    _initStream();
  }

  void _initStream() {
    _stylistsStream = context.read<FirestoreService>().streamCollection(
      collection: FirestoreCollections.stylists,
      queryBuilder: (query) => query.where('branchId', isEqualTo: widget.branch.id),
    );
  }

  void _onContinue() {
    if (_selectedStylist != null) {
      final bookingProvider = context.read<BookingProvider>();
      bookingProvider.setStylist(_selectedStylist!);
      
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Stylist'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _buildStylistList(),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
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

  Widget _buildStylistList() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _stylistsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: AppErrorWidget(
                message: 'Failed to load stylists. Please try again.',
                onRetry: () => setState(_initStream),
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: AppCircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_off, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No stylists available here',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          );
        }

        final stylists = docs.map((doc) => StylistModel.fromFirestore(doc)).toList();

        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.m),
          itemCount: stylists.length,
          itemBuilder: (context, index) {
            final stylist = stylists[index];
            final isSelected = _selectedStylist?.id == stylist.id;

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s),
              child: AppCard(
                onTap: () {
                  setState(() {
                    _selectedStylist = stylist;
                  });
                },
                padding: const EdgeInsets.all(AppSpacing.m),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: stylist.photoUrl != null 
                          ? NetworkImage(stylist.photoUrl!) 
                          : null,
                      child: stylist.photoUrl == null 
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    const SizedBox(width: AppSpacing.m),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stylist.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          if (stylist.specialization.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              stylist.specialization.join(', '),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ),
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
      },
    );
  }
}
