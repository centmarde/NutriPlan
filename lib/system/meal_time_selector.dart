import 'package:flutter/material.dart';

class MealTimeSelector extends StatefulWidget {
  final Function(TimeOfDay) onTimeSelected;
  final Function() onCancel;

  const MealTimeSelector({
    Key? key,
    required this.onTimeSelected,
    required this.onCancel,
  }) : super(key: key);

  @override
  MealTimeSelectorState createState() => MealTimeSelectorState();
}

class MealTimeSelectorState extends State<MealTimeSelector>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Pre-defined times for each meal type
  final Map<String, List<TimeOfDay>> mealTimes = {
    'Breakfast': [
      const TimeOfDay(hour: 6, minute: 0),
      const TimeOfDay(hour: 7, minute: 0),
      const TimeOfDay(hour: 8, minute: 0),
      const TimeOfDay(hour: 9, minute: 0),
    ],
    'Lunch': [
      const TimeOfDay(hour: 11, minute: 30),
      const TimeOfDay(hour: 12, minute: 0),
      const TimeOfDay(hour: 12, minute: 30),
      const TimeOfDay(hour: 13, minute: 0),
    ],
    'Snack': [
      const TimeOfDay(hour: 10, minute: 0),
      const TimeOfDay(hour: 15, minute: 0),
      const TimeOfDay(hour: 16, minute: 0),
      const TimeOfDay(hour: 20, minute: 0),
    ],
    'Dinner': [
      const TimeOfDay(hour: 17, minute: 0),
      const TimeOfDay(hour: 18, minute: 0),
      const TimeOfDay(hour: 19, minute: 0),
      const TimeOfDay(hour: 20, minute: 0),
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Breakfast'),
            Tab(text: 'Lunch'),
            Tab(text: 'Snack'),
            Tab(text: 'Dinner'),
          ],
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorSize: TabBarIndicatorSize.tab,
        ),
        const SizedBox(height: 10), // Reduced from 16
        SizedBox(
          height: 130, // Reduced from 150
          child: TabBarView(
            controller: _tabController,
            children:
                mealTimes.keys.map((mealType) {
                  return GridView.count(
                    crossAxisCount: 2,
                    childAspectRatio: 2.5,
                    mainAxisSpacing: 4, // Added explicit spacing
                    crossAxisSpacing: 4,
                    padding: const EdgeInsets.all(2), // Smaller padding
                    children:
                        mealTimes[mealType]!.map((time) {
                          return ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(
                                2,
                              ), // Reduced padding
                            ),
                            onPressed: () => widget.onTimeSelected(time),
                            child: Text(time.format(context)),
                          );
                        }).toList(),
                  );
                }).toList(),
          ),
        ),
        const SizedBox(height: 8), // Reduced from 10
        ElevatedButton(
          onPressed: () async {
            final time = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    timePickerTheme: TimePickerThemeData(
                      backgroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (time != null) {
              widget.onTimeSelected(time);
            }
          },
          child: const Text('Custom Time'),
        ),
      ],
    );
  }
}
