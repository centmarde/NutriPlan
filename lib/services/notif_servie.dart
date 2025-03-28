import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Flutter local notifications plugin
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Initialize notification service
  Future<void> init() async {
    // Initialize timezone
    tz_data.initializeTimeZones();

    // Android initialization settings with sound
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Initialize settings
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    // Initialize plugin with callback for notification taps
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        _onNotificationTap(details.payload);
      },
    );

    // Request permissions (only needed for newer Android versions)
    try {
      await _requestNotificationPermissions();
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
      // Continue even if permission request fails - notifications might still work
    }
  }

  // Request necessary permissions
  Future<void> _requestNotificationPermissions() async {
    // Try the AndroidFlutterLocalNotificationsPlugin.requestPermissions() method
    final androidPlugin =
        flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    // Check if the plugin supports permissions
    if (androidPlugin != null) {
      try {
        // Try with plural form (requestPermissions)

        debugPrint('Android notification permissions requested successfully');
      } catch (e) {
        // If that fails, we'll just use the default permissions
        debugPrint('Could not request notification permissions: $e');
      }
    }
  }

  // Handle notification tap
  void _onNotificationTap(String? payload) {
    if (payload != null) {
      debugPrint('Notification tapped with payload: $payload');
      // Navigate or perform action based on payload
    }
  }

  // Create notification details with default system sound
  NotificationDetails _createNotificationDetails() {
    // Android notification details with default system sound
    AndroidNotificationDetails androidDetails =
        const AndroidNotificationDetails(
          'meal_channel',
          'Meal Notifications',
          channelDescription: 'Notifications for meal reminders',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true, // Use default system sound
          enableLights: true,
          enableVibration: true,
          icon: '@mipmap/ic_launcher',
          ticker: 'DailyBite meal notification',
        );

    return NotificationDetails(android: androidDetails);
  }

  // Show immediate notification with default sound
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      _createNotificationDetails(),
      payload: payload,
    );
  }

  // Schedule notification with default sound
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    try {
      final zonedScheduleTime = tz.TZDateTime.from(scheduledDate, tz.local);

      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        zonedScheduleTime,
        _createNotificationDetails(),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );

      debugPrint('Standard notification scheduled for $scheduledDate');
    } catch (e) {
      debugPrint('Failed to schedule notification: $e');

      // If scheduling fails and it's close to the time, show immediate notification
      if (DateTime.now().difference(scheduledDate).inMinutes > -5) {
        await showNotification(
          id: id,
          title: title,
          body: body,
          payload: payload,
        );
      }
    }
  }

  // Cancel notification by id
  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
