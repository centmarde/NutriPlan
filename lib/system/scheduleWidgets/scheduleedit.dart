import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ScheduleEditDialog extends StatefulWidget {
  final String mealId;
  final Map<String, dynamic> meal;
  final Function(String, DateTime) onReschedule;

  const ScheduleEditDialog({
    Key? key,
    required this.mealId,
    required this.meal,
    required this.onReschedule,
  }) : super(key: key);

  @override
  State<ScheduleEditDialog> createState() => _ScheduleEditDialogState();
}

class _ScheduleEditDialogState extends State<ScheduleEditDialog> {
  late DateTime selectedDateTime;

  @override
  void initState() {
    super.initState();
    // Initialize with the current scheduled date or now
    selectedDateTime =
        widget.meal['scheduledAt'] != null
            ? (widget.meal['scheduledAt'] as Timestamp).toDate()
            : DateTime.now();
  }

  Future<void> _pickDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedDateTime),
      );

      if (pickedTime != null) {
        setState(() {
          selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Reschedule Meal'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.meal['name'] ?? 'Unnamed Meal',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          SizedBox(height: 16),
          Text('Select a new date and time:'),
          SizedBox(height: 8),
          InkWell(
            onTap: _pickDateTime,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.blue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      DateFormat('MMM d, y - h:mm a').format(selectedDateTime),
                      style: TextStyle(fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('CANCEL'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            widget.onReschedule(widget.mealId, selectedDateTime);
          },
          child: Text('SAVE'),
        ),
      ],
    );
  }
}

// Helper function to show the schedule edit dialog
void showScheduleEditDialog({
  required BuildContext context,
  required String mealId,
  required Map<String, dynamic> meal,
  required Function(String, DateTime) onReschedule,
}) {
  showDialog(
    context: context,
    builder:
        (context) => ScheduleEditDialog(
          mealId: mealId,
          meal: meal,
          onReschedule: onReschedule,
        ),
  );
}
