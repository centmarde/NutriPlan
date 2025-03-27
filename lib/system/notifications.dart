import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_init;
import '../services/auth_service.dart';
import 'package:flutter/material.dart';
import 'schedule_fetch.dart';
import '../utils/notification_debugger.dart';

class NotificationService {
  // Singleton instance
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final NotificationDebugger _debugger = NotificationDebugger();

  // Callback for handling notification selection
  static Function(String)? onNotificationSelected;

  // Initialize notifications
  Future<void> init() async {
    _debugger.info('Initializing notification service');
    try {
      // Initialize timezone
      tz_init.initializeTimeZones();

      // Define notification settings for Android
      const AndroidInitializationSettings androidInitializationSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // Define notification settings for iOS
      final DarwinInitializationSettings darwinInitializationSettings =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );

      // Initialize settings
      final InitializationSettings initializationSettings =
          InitializationSettings(
            android: androidInitializationSettings,
            iOS: darwinInitializationSettings,
          );

      // Initialize plugin
      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: handleNotificationResponse,
      );

      // Request permissions (iOS)
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);

      _debugger.logNotificationSuccess('initialize', 'notification service');
    } catch (e, stackTrace) {
      _debugger.logNotificationError(
        'initialize',
        'notification service',
        e,
        stackTrace,
      );
    }
  }

  // Handle notification taps
  void handleNotificationResponse(NotificationResponse response) {
    _debugger.info('Notification tapped: ${response.payload}');

    if (response.payload != null) {
      // Extract meal ID from payload
      final mealId = response.payload!;
      _debugger.info('Retrieved scheduled meal ID: $mealId');

      // Call the callback if set
      if (onNotificationSelected != null) {
        onNotificationSelected!(mealId);
      }
    }
  }

  // Schedule a notification for a meal
  Future<void> scheduleMealNotification(Meal meal) async {
    if (meal.scheduledAt == null) {
      _debugger.warning(
        'Cannot schedule notification: No scheduled time for meal ${meal.name}',
      );
      return;
    }

    // Set notification time to 30 minutes before scheduled meal time
    final notificationTime = meal.scheduledAt!.toDate().subtract(
      const Duration(minutes: 30),
    );

    // Skip if notification time is in the past
    if (notificationTime.isBefore(DateTime.now())) {
      _debugger.warning(
        'Skipping notification for ${meal.name}: time is in the past',
      );
      return;
    }

    final int notificationId = meal.mealId.hashCode;

    _debugger.logNotificationScheduling(
      meal.name,
      notificationTime,
      'ID: $notificationId, Original meal time: ${meal.scheduledAt!.toDate()}',
    );

    // Define notification details for Android
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'meal_schedule_channel',
          'Meal Schedule Notifications',
          channelDescription: 'Notifications for scheduled meals',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
        );

    // Define notification details for iOS
    const DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    // Combine notification details
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
    );

    try {
      // Schedule the notification
      await flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        'Time to prepare: ${meal.name}',
        'Your scheduled meal ${meal.name} is coming up in 30 minutes!',
        tz.TZDateTime.from(notificationTime, tz.local),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: meal.mealId, // Use meal ID as payload
      );

      _debugger.logNotificationSuccess('scheduled', meal.name);
    } catch (e, stackTrace) {
      _debugger.logNotificationError('schedule', meal.name, e, stackTrace);
    }
  }

  // Cancel a notification for a meal
  Future<void> cancelMealNotification(Meal meal) async {
    try {
      final int notificationId = meal.mealId.hashCode;
      await flutterLocalNotificationsPlugin.cancel(notificationId);
      _debugger.logNotificationSuccess('cancelled', meal.name);
    } catch (e, stackTrace) {
      _debugger.logNotificationError('cancel', meal.name, e, stackTrace);
    }
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await flutterLocalNotificationsPlugin.cancelAll();
      _debugger.logNotificationSuccess('cancelled', 'all notifications');
    } catch (e, stackTrace) {
      _debugger.logNotificationError(
        'cancel all',
        'notifications',
        e,
        stackTrace,
      );
    }
  }

  // Schedule notifications for all scheduled meals
  Future<void> scheduleAllMealNotifications(List<Meal> scheduledMeals) async {
    _debugger.info(
      'Scheduling notifications for ${scheduledMeals.length} meals',
    );
    for (final meal in scheduledMeals) {
      await scheduleMealNotification(meal);
    }
  }

  // For debugging purposes - Dump pending notifications
  Future<void> dumpPendingNotifications() async {
    try {
      final List<PendingNotificationRequest>? pendingNotifications =
          await flutterLocalNotificationsPlugin.pendingNotificationRequests();

      _debugger.info('==== PENDING NOTIFICATIONS ====');
      _debugger.info('Count: ${pendingNotifications?.length ?? 0}');

      pendingNotifications?.forEach((notification) {
        _debugger.info(
          'ID: ${notification.id}, '
          'Title: ${notification.title}, '
          'Body: ${notification.body}, '
          'Payload: ${notification.payload}',
        );
      });

      _debugger.info('================================');
    } catch (e, stackTrace) {
      _debugger.error('Failed to dump pending notifications', e, stackTrace);
    }
  }
}
