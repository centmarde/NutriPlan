import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'meal_time_selector.dart';

class MealScheduler {
  // Calendar configuration
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  // Show date selection calendar
  Future<DateTime?> showDateSelectionCalendar(BuildContext context) async {
    DateTime? selectedDate;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Schedule Meal'),
            content: SizedBox(
              width: double.maxFinite,
              height: 380, // Slightly reduced height
              child: StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    children: [
                      const SizedBox(height: 8), // Reduced padding
                      TableCalendar(
                        firstDay: DateTime.now(),
                        lastDay: DateTime.now().add(const Duration(days: 365)),
                        focusedDay: _focusedDay,
                        calendarFormat: _calendarFormat,
                        selectedDayPredicate: (day) {
                          return isSameDay(_selectedDay, day);
                        },
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                        },
                        onFormatChanged: (format) {
                          setState(() {
                            _calendarFormat = format;
                          });
                        },
                        // Make calendar more minimalist with styling
                        headerStyle: HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                          titleTextStyle: const TextStyle(fontSize: 15),
                          leftChevronIcon: const Icon(
                            Icons.chevron_left,
                            size: 18,
                          ),
                          rightChevronIcon: const Icon(
                            Icons.chevron_right,
                            size: 18,
                          ),
                          headerPadding: const EdgeInsets.symmetric(
                            vertical: 5.0,
                          ),
                        ),
                        daysOfWeekStyle: const DaysOfWeekStyle(
                          weekdayStyle: TextStyle(fontSize: 12),
                          weekendStyle: TextStyle(fontSize: 12),
                        ),
                        calendarStyle: CalendarStyle(
                          defaultTextStyle: const TextStyle(fontSize: 12),
                          weekendTextStyle: const TextStyle(fontSize: 12),
                          outsideTextStyle: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                          ),
                          selectedTextStyle: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                          todayTextStyle: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                          cellPadding: const EdgeInsets.all(4),
                          cellMargin: const EdgeInsets.all(2),
                        ),
                        rowHeight: 36, // Reduce row height for compactness
                      ),
                    ],
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => _showCancelConfirmation(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  selectedDate = _selectedDay;
                  Navigator.of(context).pop();
                },
                child: const Text('Next'),
              ),
            ],
          ),
    );

    return selectedDate;
  }

  // Show time selection dialog
  Future<TimeOfDay?> showTimeSelectionDialog(BuildContext context) async {
    TimeOfDay? selectedTime;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Select Time'),
            content: SizedBox(
              width: double.maxFinite,
              height: 250, // Reduced from 250 to avoid overflow
              child: MealTimeSelector(
                onTimeSelected: (time) {
                  selectedTime = time;
                  Navigator.of(context).pop();
                },
                onCancel: () => _showCancelConfirmation(context),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => _showCancelConfirmation(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );

    return selectedTime;
  }

  // Show cancel confirmation dialog
  Future<bool> _showCancelConfirmation(BuildContext context) async {
    bool shouldCancel = false;

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cancel Scheduling?'),
            content: const Text(
              'This operation cannot be undone. Any unsaved meal information will be lost.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Continue Scheduling'),
              ),
              TextButton(
                onPressed: () {
                  shouldCancel = true;
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    return shouldCancel;
  }

  // Show final confirmation dialog
  Future<bool> showFinalConfirmation(
    BuildContext context,
    String mealName,
    DateTime date,
    TimeOfDay time,
  ) async {
    bool shouldSave = false;

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Meal Schedule'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Meal: $mealName'),
                const SizedBox(height: 8),
                Text('Date: ${date.month}/${date.day}/${date.year}'),
                Text('Time: ${time.format(context)}'),
                const SizedBox(height: 12),
                const Text('Save this meal schedule?'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => _showCancelConfirmation(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  shouldSave = true;
                  Navigator.of(context).pop();
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );

    return shouldSave;
  }
}
