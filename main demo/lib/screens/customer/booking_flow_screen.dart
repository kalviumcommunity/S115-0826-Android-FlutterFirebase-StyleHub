import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/loading_widget.dart';
import '../../models/branch_model.dart';
import '../../models/service_model.dart';
import '../../models/stylist_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/branch_provider.dart';
import '../../providers/service_provider.dart';
import '../../providers/stylist_provider.dart';
import 'widgets/branch_card.dart';
import 'widgets/service_card.dart';
import 'widgets/stylist_card.dart';

class BookingFlowScreen extends StatefulWidget {
  final BranchModel? initialBranch;
  final ServiceModel? initialService;

  const BookingFlowScreen({
    super.key,
    this.initialBranch,
    this.initialService,
  });

  @override
  State<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends State<BookingFlowScreen> {
  int _currentStep = 0; // 0: Branch, 1: Service, 2: Stylist, 3: Date/Time, 4: Review
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedTimeSlot = AppConstants.defaultTimeSlots.first;
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bookingProv = context.read<BookingProvider>();
      bookingProv.resetDraft();
      if (widget.initialBranch != null) {
        bookingProv.selectBranch(widget.initialBranch!);
        _currentStep = 1;
      }
      if (widget.initialService != null) {
        bookingProv.selectService(widget.initialService!);
        if (widget.initialBranch != null) _currentStep = 2;
      }
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleConfirm() async {
    final authProv = context.read<AuthProvider>();
    final bookingProv = context.read<BookingProvider>();

    if (authProv.currentUser == null) return;

    bookingProv.selectDateTime(
      '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
      _selectedTimeSlot,
    );
    bookingProv.setNotes(_notesController.text.trim());

    final apt = await bookingProv.confirmBooking(authProv.currentUser!);
    if (apt != null && mounted) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Appointment confirmed at ${apt.branchName}!'),
          backgroundColor: AppColors.statusCompleted,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingProv = context.watch<BookingProvider>();
    final branchProv = context.watch<BranchProvider>();
    final serviceProv = context.watch<ServiceProvider>();
    final stylistProv = context.watch<StylistProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Salon Appointment'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Step progress indicators
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: List.generate(5, (index) {
                final isDone = index < _currentStep;
                final isCurrent = index == _currentStep;
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: isDone || isCurrent ? AppColors.primary : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          const Divider(height: 1),

          // Main Step Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildCurrentStep(branchProv, serviceProv, stylistProv, bookingProv),
            ),
          ),

          // Bottom action button bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => setState(() => _currentStep--),
                      child: const Text('Back'),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: AppButton(
                    label: _currentStep == 4 ? 'Confirm Booking' : 'Next Step',
                    isLoading: bookingProv.isSubmitting,
                    onPressed: () {
                      if (_currentStep == 0 && bookingProv.draft.isBranchSelected) {
                        setState(() => _currentStep = 1);
                      } else if (_currentStep == 1 && bookingProv.draft.isServiceSelected) {
                        setState(() => _currentStep = 2);
                      } else if (_currentStep == 2 && bookingProv.draft.isStylistSelected) {
                        setState(() => _currentStep = 3);
                      } else if (_currentStep == 3) {
                        setState(() => _currentStep = 4);
                      } else if (_currentStep == 4) {
                        _handleConfirm();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please make a selection to proceed')),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep(
    BranchProvider branchProv,
    ServiceProvider serviceProv,
    StylistProvider stylistProv,
    BookingProvider bookingProv,
  ) {
    switch (_currentStep) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('1. Choose Salon Branch', style: AppTypography.titleLarge),
            const SizedBox(height: 6),
            Text('Select an outlet in the centralized network', style: AppTypography.bodyMedium),
            const SizedBox(height: 16),
            ...branchProv.branches.map((b) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: BranchCard(
                branch: b,
                isSelected: bookingProv.draft.branchId == b.branchId,
                onTap: () {
                  bookingProv.selectBranch(b);
                  stylistProv.filterByBranch(b.branchId);
                  setState(() => _currentStep = 1);
                },
              ),
            )),
          ],
        );

      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('2. Select Service', style: AppTypography.titleLarge),
            const SizedBox(height: 6),
            Text('Available at ${bookingProv.draft.branchName}', style: AppTypography.bodyMedium),
            const SizedBox(height: 16),
            ...serviceProv.services.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ServiceCard(
                service: s,
                isSelected: bookingProv.draft.serviceId == s.serviceId,
                onTap: () {
                  bookingProv.selectService(s);
                  setState(() => _currentStep = 2);
                },
              ),
            )),
          ],
        );

      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('3. Select Specialist Stylist', style: AppTypography.titleLarge),
            const SizedBox(height: 6),
            Text('Stylists stationed at ${bookingProv.draft.branchName}', style: AppTypography.bodyMedium),
            const SizedBox(height: 16),
            ...stylistProv.stylists.map((st) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: StylistCard(
                stylist: st,
                isSelected: bookingProv.draft.stylistId == st.stylistId,
                onTap: () {
                  bookingProv.selectStylist(st);
                  setState(() => _currentStep = 3);
                },
              ),
            )),
          ],
        );

      case 3:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('4. Select Date & Time', style: AppTypography.titleLarge),
            const SizedBox(height: 16),
            CalendarDatePicker(
              initialDate: _selectedDate,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 60)),
              onDateChanged: (d) => setState(() => _selectedDate = d),
            ),
            const SizedBox(height: 16),
            Text('Available Time Slots', style: AppTypography.titleMedium),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppConstants.defaultTimeSlots.map((slot) {
                final isSelected = _selectedTimeSlot == slot;
                return ChoiceChip(
                  label: Text(slot),
                  selected: isSelected,
                  selectedColor: AppColors.primaryLight,
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedTimeSlot = slot);
                  },
                );
              }).toList(),
            ),
          ],
        );

      case 4:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('5. Review & Confirm', style: AppTypography.titleLarge),
            const SizedBox(height: 6),
            Text('Your centralized profile booking details', style: AppTypography.bodyMedium),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _buildSummaryRow('Salon Branch', bookingProv.draft.branchName ?? '-'),
                  const Divider(),
                  _buildSummaryRow('Service', bookingProv.draft.serviceName ?? '-'),
                  const Divider(),
                  _buildSummaryRow('Stylist', bookingProv.draft.stylistName ?? '-'),
                  const Divider(),
                  _buildSummaryRow(
                    'Appointment Date',
                    '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')} at $_selectedTimeSlot',
                  ),
                  const Divider(),
                  _buildSummaryRow(
                    'Total Price',
                    '\$${bookingProv.draft.servicePrice?.toStringAsFixed(0) ?? "0"}',
                    isPrice: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Special Requests / Notes (Optional)',
                hintText: 'e.g. skin allergies, preferred hair wash temperature',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        );

      default:
        return const SizedBox();
    }
  }

  Widget _buildSummaryRow(String title, String value, {bool isPrice = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTypography.bodyMedium),
          Text(
            value,
            style: isPrice
                ? AppTypography.titleLarge.copyWith(color: AppColors.primary, fontSize: 18)
                : AppTypography.titleMedium.copyWith(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
