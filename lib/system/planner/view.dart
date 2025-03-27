import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import 'add.dart'; // Import the add dialog
import 'modal.dart'; // Import the modal

class MealPlannerView extends StatefulWidget {
  final AuthService authService;

  const MealPlannerView({Key? key, required this.authService})
    : super(key: key);

  @override
  State<MealPlannerView> createState() => _MealPlannerViewState();
}

class _MealPlannerViewState extends State<MealPlannerView> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<dynamic>> _events = {};
  List<dynamic> _selectedEvents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _fetchMealSchedules();
  }

  Future<void> _fetchMealSchedules() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = widget.authService.currentUser;

      if (user != null) {
        final snapshot =
            await FirebaseFirestore.instance
                .collection('meals')
                .where('userId', isEqualTo: user.uid)
                .get();

        Map<DateTime, List<dynamic>> events = {};

        for (var doc in snapshot.docs) {
          final data = doc.data();
          if (data['scheduledAt'] != null) {
            final scheduledAt = (data['scheduledAt'] as Timestamp).toDate();
            final dateKey = DateTime(
              scheduledAt.year,
              scheduledAt.month,
              scheduledAt.day,
            );

            if (events[dateKey] != null) {
              events[dateKey]!.add(data);
            } else {
              events[dateKey] = [data];
            }
          }
        }

        if (mounted) {
          setState(() {
            _events = events;
            _selectedEvents = _getEventsForDay(_selectedDay!);
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching meal schedules: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _selectedEvents = _getEventsForDay(selectedDay);
      });
    }
  }

  // Add new method to show the add meal dialog
  void _showAddMealDialog() async {
    final user = widget.authService.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need to be logged in to add meals')),
      );
      return;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AddMealDialog(
          userId: user.uid,
          selectedDate: _selectedDay ?? DateTime.now(),
        );
      },
    );

    if (result == true) {
      // Refresh the meals list if a meal was added
      _fetchMealSchedules();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          eventLoader: _getEventsForDay,
          startingDayOfWeek: StartingDayOfWeek.monday,
          calendarStyle: CalendarStyle(
            markerDecoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
          ),
          onDaySelected: _onDaySelected,
          onFormatChanged: (format) {
            if (_calendarFormat != format) {
              setState(() {
                _calendarFormat = format;
              });
            }
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
        ),
        const SizedBox(height: 20),
        Expanded(
          child:
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildMealsList(),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildMealsList() {
    final selectedDate = DateFormat('EEEE, MMMM d, yyyy').format(_selectedDay!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Create a row with the title and add button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Meals for $selectedDate',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle),
              color: Theme.of(context).primaryColor,
              iconSize: 30,
              onPressed: _showAddMealDialog,
              tooltip: 'Add Meal',
            ),
          ],
        ),
        const SizedBox(height: 10),
        _selectedEvents.isEmpty
            ? const Expanded(
              child: Center(
                child: Text(
                  'No meals scheduled for this day',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            )
            : Expanded(
              child: ListView.builder(
                itemCount: _selectedEvents.length,
                itemBuilder: (context, index) {
                  final meal = _selectedEvents[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    elevation: 2,
                    child: ListTile(
                      title: Text(meal['name'] ?? 'Unnamed Meal'),
                      subtitle: Text(meal['category'] ?? 'No description'),
                      leading:
                          meal['imageUrl'] != null &&
                                  meal['imageUrl'].toString().isNotEmpty
                              ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  meal['imageUrl'],
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 50,
                                      height: 50,
                                      color: Colors.grey.shade300,
                                      child: const Icon(Icons.fastfood),
                                    );
                                  },
                                ),
                              )
                              : Container(
                                width: 50,
                                height: 50,
                                color: Colors.grey.shade300,
                                child: const Icon(Icons.fastfood),
                              ),
                      trailing: Text(
                        meal['area'] ?? 'N/A',
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                      onTap: () {
                        // Use the static method from MealDetailsModal
                        MealDetailsModal.showMealDetails(context, meal);
                      },
                    ),
                  );
                },
              ),
            ),
      ],
    );
  }
}
