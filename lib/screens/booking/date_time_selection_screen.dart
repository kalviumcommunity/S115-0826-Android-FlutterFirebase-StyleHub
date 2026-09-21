import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_constants.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../models/stylist_model.dart';
import '../../providers/booking_provider.dart';
import 'booking_confirmation_screen.dart';

class DateTimeSelectionScreen extends StatefulWidget {
  const DateTimeSelectionScreen({super.key});

  @override
  State<DateTimeSelectionScreen> createState() => _DateTimeSelectionScreenState();
}

class _DateTimeSelectionScreenState extends State<DateTimeSelectionScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedTimeSlot;

  List<String> _generateSlots(StylistModel stylist) {
    final slots = <String>[];
    final startParts = stylist.startTime.split(':');
    final endParts = stylist.endTime.split(':');
    final breakStartParts = stylist.breakStart.split(':');
    final breakEndParts = stylist.breakEnd.split(':');

    int startHour = int.tryParse(startParts[0]) ?? 9;
    int startMinute = int.tryParse(startParts.length > 1 ? startParts[1] : '0') ?? 0;
    int endHour = int.tryParse(endParts[0]) ?? 18;
    int endMinute = int.tryParse(endParts.length > 1 ? endParts[1] : '0') ?? 0;
    int breakStartHour = int.tryParse(breakStartParts[0]) ?? 13;
    int breakStartMinute = int.tryParse(breakStartParts.length > 1 ? breakStartParts[1] : '0') ?? 0;
    int breakEndHour = int.tryParse(breakEndParts[0]) ?? 14;
    int breakEndMinute = int.tryParse(breakEndParts.length > 1 ? breakEndParts[1] : '0') ?? 0;

    int currentMinutes = startHour * 60 + startMinute;
    final endMinutes = endHour * 60 + endMinute;
    final breakStartMinutes = breakStartHour * 60 + breakStartMinute;
    final breakEndMinutes = breakEndHour * 60 + breakEndMinute;

    while (currentMinutes < endMinutes) {
      // Skip break time
      if (currentMinutes >= breakStartMinutes && currentMinutes < breakEndMinutes) {
        currentMinutes += 30;
        continue;
      }
      final hour = currentMinutes ~/ 60;
      final minute = currentMinutes % 60;
      slots.add('${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}');
      currentMinutes += 30;
    }
    return slots;
  }

  bool _isWorkingDay(StylistModel stylist, DateTime date) {
    final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final dayName = dayNames[date.weekday - 1];
    return stylist.workingDays.isEmpty || stylist.workingDays.contains(dayName);
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();
    final stylist = bookingProvider.selectedStylist;
    final isWorkingDay = stylist != null && _isWorkingDay(stylist, _selectedDate);
    final slots = stylist != null && isWorkingDay ? _generateSlots(stylist) : <String>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Select Date & Time')),
      body: Column(
        children: [
          // Date picker
          CalendarDatePicker(
            initialDate: _selectedDate,
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 90)),
            onDateChanged: (date) {
              setState(() {
                _selectedDate = date;
                _selectedTimeSlot = null;
              });
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
            child: Text(
              isWorkingDay
                  ? 'Available Time Slots'
                  : 'Stylist does not work on this day',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          Expanded(
            child: isWorkingDay && slots.isNotEmpty
                ? GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 2.2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: slots.length,
                    itemBuilder: (context, index) {
                      final slot = slots[index];
                      final isSelected = _selectedTimeSlot == slot;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedTimeSlot = slot),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            slot,
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : Center(
                    child: Text(
                      isWorkingDay ? 'No slots available' : 'Please select a working day',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: AppButton(
          text: 'Continue',
          isDisabled: _selectedTimeSlot == null,
          onPressed: () {
            if (_selectedTimeSlot != null) {
              bookingProvider.selectDate(_selectedDate);
              bookingProvider.selectTimeSlot(_selectedTimeSlot!);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BookingConfirmationScreen()),
              );
            }
          },
        ),
      ),
    );
  }
}
