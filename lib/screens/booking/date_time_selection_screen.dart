import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_constants.dart';
import '../../core/widgets/app_button.dart';
import '../../providers/booking_provider.dart';
import 'booking_confirmation_screen.dart';

class DateTimeSelectionScreen extends StatefulWidget {
  final bool isRescheduling;
  final String? existingAppointmentId;

  const DateTimeSelectionScreen({
    super.key, 
    this.isRescheduling = false,
    this.existingAppointmentId,
  });

  @override
  State<DateTimeSelectionScreen> createState() => _DateTimeSelectionScreenState();
}

class _DateTimeSelectionScreenState extends State<DateTimeSelectionScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime? _selectedTime;
  
  // Available slots for the day (e.g., 9 AM to 5 PM every 30 mins)
  final List<TimeOfDay> _allSlots = List.generate(
    17, 
    (index) => TimeOfDay(hour: 9 + (index ~/ 2), minute: (index % 2) * 30),
  );

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.read<BookingProvider>();
    final stylist = bookingProvider.selectedStylist;
    
    if (stylist == null) {
      return const Scaffold(body: Center(child: Text('Error: No Stylist Selected')));
    }

    // Start of the day and end of the day for the Firestore query
    final startOfDay = DateTime(
      _selectedDate.year, 
      _selectedDate.month, 
      _selectedDate.day,
    );
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Date & Time'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildDateSelector(),
          const Divider(),
          Expanded(
            child: FutureBuilder<List<DateTime>>(
              future: bookingProvider.getBookedSlots(stylist.id, _selectedDate),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(child: Text('Failed to load available slots.'));
                }

                // Extract booked times
                final bookedTimes = <String>{};
                for (var scheduledAt in snapshot.data ?? <DateTime>[]) {
                  bookedTimes.add('${scheduledAt.hour}:${scheduledAt.minute}');
                }

                return _buildTimeSlots(bookedTimes);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: AppButton(
              text: widget.isRescheduling ? 'Review Reschedule' : 'Continue',
              onPressed: _selectedTime != null ? _onContinue : null,
              isLoading: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selected Date',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppSpacing.s),
          InkWell(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.m,
                horizontal: AppSpacing.s,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.m),
                  Text(
                    DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlots(Set<String> bookedTimes) {
    // Filter slots based on current time if the selected date is today
    final now = DateTime.now();
    final isToday = _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;

    final availableSlots = _allSlots.where((slot) {
      if (isToday) {
        if (slot.hour < now.hour || (slot.hour == now.hour && slot.minute <= now.minute)) {
          return false;
        }
      }
      return !bookedTimes.contains('${slot.hour}:${slot.minute}');
    }).toList();

    if (availableSlots.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No slots available on this date.',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.m),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.5,
        crossAxisSpacing: AppSpacing.s,
        mainAxisSpacing: AppSpacing.s,
      ),
      itemCount: availableSlots.length,
      itemBuilder: (context, index) {
        final slot = availableSlots[index];
        final slotDateTime = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          slot.hour,
          slot.minute,
        );
        
        final isSelected = _selectedTime?.isAtSameMomentAs(slotDateTime) ?? false;

        return InkWell(
          onTap: () {
            setState(() {
              _selectedTime = slotDateTime;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.white,
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.grey[300]!,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              DateFormat.jm().format(slotDateTime),
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isBefore(now) ? now : _selectedDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _selectedTime = null; // Reset time on date change
      });
    }
  }

  void _onContinue() {
    if (_selectedTime != null) {
      final bookingProvider = context.read<BookingProvider>();
      bookingProvider.setDate(_selectedDate);
      bookingProvider.setTime(_selectedTime!);
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookingConfirmationScreen(
            isRescheduling: widget.isRescheduling,
            existingAppointmentId: widget.existingAppointmentId,
          ),
        ),
      );
    }
  }
}
