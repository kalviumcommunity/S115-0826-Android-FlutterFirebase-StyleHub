import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stylehub/providers/booking_provider.dart';
import 'package:stylehub/models/branch_model.dart';
import 'package:stylehub/models/service_model.dart';
import 'package:stylehub/models/stylist_model.dart';
import 'package:stylehub/providers/reference_data_provider.dart';
import 'package:stylehub/widgets/primary_button.dart';
import 'package:stylehub/widgets/custom_text_field.dart';
import 'package:stylehub/core/theme/app_colors.dart';
import 'package:stylehub/core/theme/app_typography.dart';
import 'package:stylehub/core/theme/app_constants.dart';

enum BookingStep { branch, service, stylist, dateTime, confirmation }

class BookingFlowScreen extends StatefulWidget {
  const BookingFlowScreen({super.key});

  @override
  State<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends State<BookingFlowScreen> {
  BookingStep _currentStep = BookingStep.branch;

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();
    final refProvider = context.watch<ReferenceDataProvider>();
    final branch = ModalRoute.of(context)!.settings.arguments as BranchModel;

    return Scaffold(
      appBar: AppBar(
        title: Text(_getStepTitle()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_currentStep == BookingStep.branch) {
              Navigator.of(context).pop();
            } else {
              setState(() => _currentStep = _getPreviousStep());
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          children: [
            _buildStepIndicator(),
            const SizedBox(height: AppSpacing.l),
            Expanded(
              child: _buildStepContent(branch, refProvider, bookingProvider),
            ),
            const SizedBox(height: AppSpacing.m),
            _buildNavigationButtons(branch),
          ],
        ),
      ),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case BookingStep.branch: return 'Select Branch';
      case BookingStep.service: return 'Select Service';
      case BookingStep.stylist: return 'Select Stylist';
      case BookingStep.dateTime: return 'Select Date & Time';
      case BookingStep.confirmation: return 'Confirm Booking';
    }
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: BookingStep.values.map((step) {
        bool isActive = step == _currentStep;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.secondaryContainer,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStepContent(BranchModel branch, ReferenceDataProvider ref, BookingProvider bookingProvider) {
    switch (_currentStep) {
      case BookingStep.branch:
        return Text('You selected: ${branch.name}');
      case BookingStep.service:
        final services = ref.services.where((s) => s.branchId == branch.id).toList();
        return ListView(
          children: services.map((s) => RadioListTile(
            title: Text(s.name),
            subtitle: Text('\$${s.price} • ${s.durationMinutes} min'),
            value: bookingProvider.selectedService == s,
            onChanged: (val) {
              if (val == true) context.read<BookingProvider>().setService(s);
            },
          )).toList(),
        );
      case BookingStep.stylist:
        final stylists = ref.stylists.where((s) => s.branchId == branch.id).toList();
        return ListView(
          children: stylists.map((s) => RadioListTile(
            title: Text(s.name),
            subtitle: Text(s.specialization.join(', ')),
            value: bookingProvider.selectedStylist == s,
            onChanged: (val) {
              if (val == true) context.read<BookingProvider>().setStylist(s);
            },
          )).toList(),
        );
      case BookingStep.dateTime:
        return Column(
          children: [
            const Text('Select a convenient slot'),
            const SizedBox(height: AppSpacing.m),
            ElevatedButton(
              onPressed: () {
                // Trigger native date picker
              },
              child: const Text('Open Calendar'),
            ),
          ],
        );
      case BookingStep.confirmation:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Review your booking:', style: AppTypography.titleMedium),
            const Divider(),
            ListTile(title: const Text('Branch'), trailing: Text(branch.name)),
            ListTile(title: const Text('Service'), trailing: Text(bookingProvider.selectedService?.name ?? 'None')),
            ListTile(title: const Text('Stylist'), trailing: Text(bookingProvider.selectedStylist?.name ?? 'None')),
            ListTile(title: const Text('Time'), trailing: const Text('TBD')),
          ],
        );
    }
  }

  Widget _buildNavigationButtons(BranchModel branch) {
    if (_currentStep == BookingStep.confirmation) {
      final bp = context.read<BookingProvider>();
      return PrimaryButton(
        text: 'Confirm Appointment',
        isLoading: context.watch<BookingProvider>().isLoading,
        onPressed: () async {
          await bp.bookAppointment(
            customerId: 'customer_123',
            customerName: 'Customer Name',
            branchId: branch.id,
            stylistId: bp.selectedStylist?.id ?? '',
            serviceId: bp.selectedService?.id ?? '',
            scheduledAt: DateTime.now(),
          );
          if (bp.isSuccess) {
            Navigator.of(context).pushNamedAndRemoveUntil('/customer-main', (route) => false);
          }
        },
      );
    }
    return PrimaryButton(
      text: 'Next',
      onPressed: () => setState(() => _currentStep = _getNextStep()),
    );
  }

  BookingStep _getNextStep() {
    int nextIndex = _currentStep.index + 1;
    return BookingStep.values[nextIndex];
  }

  BookingStep _getPreviousStep() {
    int prevIndex = _currentStep.index - 1;
    return BookingStep.values[prevIndex];
  }
}
