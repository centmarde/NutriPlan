import 'package:flutter/material.dart';
import '../common/navbar.dart';
import '../theme/theme.dart';
import '../layout/layout.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({Key? key}) : super(key: key);

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: 'Schedule your Meal',
      initialTabIndex: NavBarItems.schedule,
      currentRoute: NavBarItems.getRouteForIndex(NavBarItems.schedule),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Meal Schedule',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    _buildScheduleItem(
                      'Breakfast',
                      '8:00 AM',
                      'Oatmeal with fruits',
                      Icons.free_breakfast,
                    ),
                    _buildScheduleItem(
                      'Lunch',
                      '12:30 PM',
                      'Grilled chicken salad',
                      Icons.lunch_dining,
                    ),
                    _buildScheduleItem(
                      'Snack',
                      '4:00 PM',
                      'Greek yogurt with nuts',
                      Icons.emoji_food_beverage,
                    ),
                    _buildScheduleItem(
                      'Dinner',
                      '7:30 PM',
                      'Salmon with vegetables',
                      Icons.dinner_dining,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleItem(
    String mealType,
    String time,
    String description,
    IconData icon,
  ) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.darker),
        title: Text(
          mealType,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
        trailing: Text(
          time,
          style: TextStyle(color: AppTheme.darker, fontWeight: FontWeight.bold),
        ),
        onTap: () {
          // TODO: Navigate to meal details
        },
      ),
    );
  }
}
