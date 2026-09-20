import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/booking_provider.dart';
import '../../providers/reference_data_provider.dart';
import '../../core/app_exceptions.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedBranchId;
  String? _selectedStylistId;
  String? _selectedServiceId;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    // Initialize reference data if not already loaded.
    final referenceDataProvider =
        context.read<ReferenceDataProvider>();
    if (referenceDataProvider.branches.isEmpty &&
        !referenceDataProvider.branchesLoading) {
      referenceDataProvider.initialize();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  DateTime _combineDateAndTime() {
    return DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
  }

  Future<void> _bookAppointment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final bookingProvider = context.read<BookingProvider>();
    final user = context.read<UserModel>(); // Assuming we have a UserModel provider? We don't.

    // We need to get the current user's details. We'll use the AuthProvider.
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;

    if (currentUser == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to book an appointment.')),
      );
      return;
    }

    final selectedDateTime = _combineDateAndTime();

    try {
      await bookingProvider.bookAppointment(
        customerId: currentUser.uid,
        customerName: currentUser.name,
        branchId: _selectedBranchId!,
        stylistId: _selectedStylistId!,
        serviceId: _selectedServiceId!,
        scheduledAt: selectedDateTime,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment booked successfully!')),
      );
      // Optionally, navigate back or to a confirmation screen.
      Navigator.of(context).pop();
    } on SlotAlreadyBookedException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('The selected time slot is already booked.')),
      );
    } on AppException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final referenceDataProvider = context.watch<ReferenceDataProvider>();
    final bookingProvider = context.watch<BookingProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () =>
                context.read<AuthProvider>().signOut(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Branch Selection
              const Text(
                'Select Branch',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              referenceDataProvider.branchesLoading
                  ? const Center(child: CircularProgressIndicator())
                  : referenceDataProvider.branchesError != null
                      ? Text(
                          'Error: ${referenceDataProvider.branchesError}',
                          style: TextStyle(color: Colors.red),
                        )
                      : DropdownButtonFormField<String>(
                          value: _selectedBranchId,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Select a branch',
                          ),
                          items: referenceDataProvider.branches.map((branch) {
                            return DropdownMenuItem<String>(
                              value: branch['id'] as String,
                              child: Text(branch['name'] as String? ?? ''),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedBranchId = value;
                            });
                          },
                          validator: (value) =>
                              value == null ? 'Please select a branch' : null,
                        ),
              const SizedBox(height: 16),

              // Stylist Selection
              const Text(
                'Select Stylist',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              referenceDataProvider.stylistsLoading
                  ? const Center(child: CircularProgressIndicator())
                  : referenceDataProvider.stylistsError != null
                      ? Text(
                          'Error: ${referenceDataProvider.stylistsError}',
                          style: TextStyle(color: Colors.red),
                        )
                      : DropdownButtonFormField<String>(
                          value: _selectedStylistId,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Select a stylist',
                          ),
                          items: referenceDataProvider.stylists.map((stylist) {
                            return DropdownMenuItem<String>(
                              value: stylist['id'] as String,
                              child: Text(stylist['name'] as String? ?? ''),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedStylistId = value;
                            });
                          },
                          validator: (value) =>
                              value == null ? 'Please select a stylist' : null,
                        ),
              const SizedBox(height: 16),

              // Service Selection
              const Text(
                'Select Service',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              referenceDataProvider.servicesLoading
                  ? const Center(child: CircularProgressIndicator())
                  : referenceDataProvider.servicesError != null
                      ? Text(
                          'Error: ${referenceDataProvider.servicesError}',
                          style: TextStyle(color: Colors.red),
                        )
                      : DropdownButtonFormField<String>(
                          value: _selectedServiceId,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Select a service',
                          ),
                          items: referenceDataProvider.services.map((service) {
                            return DropdownMenuItem<String>(
                              value: service['id'] as String,
                              child: Text(service['name'] as String? ?? ''),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedServiceId = value;
                            });
                          },
                          validator: (value) =>
                              value == null ? 'Please select a service' : null,
                        ),
              const SizedBox(height: 24),

              // Date and Time Selection
              const Text(
                'Select Date and Time',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _selectDate(context),
                      child: Text(
                        '${_selectedDate.toLocal()}'.split(' ')[0],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _selectTime(context),
                      child: Text(
                        _selectedTime.format(context),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Book Button
              ElevatedButton(
                onPressed: bookingProvider.isLoading ? null : _bookAppointment,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: bookingProvider.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Book Appointment'),
              ),
              const SizedBox(height: 16),

              // Loading and Error Indicators from BookingProvider
              if (bookingProvider.isLoading)
                const Center(child: CircularProgressIndicator()),
              if (bookingProvider.errorMessage != null)
                Text(
                  bookingProvider.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              if (bookingProvider.isSuccess)
                const Text(
                  'Appointment booked successfully!',
                  style: TextStyle(color: Colors.green),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }
}