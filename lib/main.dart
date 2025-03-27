import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'router/app_router.dart';
import 'theme/theme.dart';
import 'system/scheduler/view_notif.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // Initialize meal notification scheduler
  final mealNotificationScheduler = MealNotificationScheduler();
  await mealNotificationScheduler.setupNotifications();

  // Set up listeners for user login/logout and meal changes
  mealNotificationScheduler.setupAuthListener();
  mealNotificationScheduler
      .setupMealChangeListener(); // Ensure real-time listener is set up

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final MealNotificationScheduler _notificationScheduler =
      MealNotificationScheduler();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Ensure notifications are scheduled when app starts
    _notificationScheduler.scheduleMealNotifications();
  }

  @override
  void dispose() {
    // Clean up resources when app is closed
    _notificationScheduler.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh notifications when the app is resumed
      _notificationScheduler.scheduleMealNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriPlan',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppTheme.darkest),
        useMaterial3: true,
      ),
      initialRoute: '/',
      onGenerateRoute: AppRouter.generateRoute,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        // Add global error handling for the app
        return ErrorHandler(child: child ?? const SizedBox());
      },
    );
  }
}

class ErrorHandler extends StatelessWidget {
  final Widget child;

  const ErrorHandler({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(color: Colors.white, child: child);
  }
}
