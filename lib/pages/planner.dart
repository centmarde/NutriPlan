import 'package:flutter/material.dart';
import '../layout/layout.dart';
import '../router/routes.dart';
import '../common/navbar.dart';
import '../system/planner/view.dart'; // Import the planner view
import '../services/auth_service.dart'; // Import auth service
import '../system/scheduler/view_notif.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({Key? key}) : super(key: key);

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  final List<String> daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  int _selectedDay = 0;
  final AuthService _authService = AuthService();
  final MealNotificationScheduler _notificationScheduler =
      MealNotificationScheduler();

  @override
  void initState() {
    super.initState();
    _notificationScheduler.scheduleMealNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: 'Meal Planner',
      currentRoute: AppRoutes.planner,
      initialTabIndex: NavBarItems.planner,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: MealPlannerView(authService: _authService),
      ),
    );
  }
}
