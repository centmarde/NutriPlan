import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nutriplan/services/auth_service.dart';
import 'package:nutriplan/services/notif_servie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class MealNotificationScheduler {
  final AuthService _authService = AuthService();
  final NotificationService _notificationService = NotificationService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot>? _mealSubscription;

  static final MealNotificationScheduler _instance =
      MealNotificationScheduler._internal();

  factory MealNotificationScheduler() {
    return _instance;
  }

  MealNotificationScheduler._internal();

  // Initialize and schedule all notifications
  Future<void> setupNotifications() async {
    try {
      debugPrint('Setting up meal notifications...');
      await _notificationService.init();
      await scheduleMealNotifications();
      debugPrint('Meal notifications setup complete');
    } catch (e) {
      debugPrint('Error setting up meal notifications: $e');
    }
  }

  // Schedule notifications for all upcoming meals with real-time updates
  Future<void> scheduleMealNotifications() async {
    try {
      // Cancel existing subscription if any
      await _mealSubscription?.cancel();

      // Get current user
      final user = _authService.currentUser;
      if (user == null) {
        debugPrint('No user logged in, skipping meal notifications setup');
        return;
      }

      // Set up real-time listener for meals collection
      _mealSubscription = _firestore
          .collection('meals')
          .where('userId', isEqualTo: user.uid)
          .snapshots()
          .listen(
            (snapshot) async {
              debugPrint('Meal data changed, updating notifications...');

              // Cancel existing notifications first to avoid duplicates
              await _notificationService.cancelAllNotifications();

              if (snapshot.docs.isEmpty) {
                debugPrint('No scheduled meals found for user ${user.uid}');
                return;
              }

              debugPrint('Found ${snapshot.docs.length} meals to process');

              // Schedule notifications for each meal
              for (var mealDoc in snapshot.docs) {
                final mealData = mealDoc.data();
                final mealId = mealDoc.id;

                // Check if meal has a scheduled time
                if (mealData.containsKey('scheduledAt') &&
                    mealData['scheduledAt'] != null) {
                  final scheduledAt =
                      (mealData['scheduledAt'] as Timestamp).toDate();

                  // Skip past meals
                  if (!scheduledAt.isAfter(DateTime.now())) continue;

                  final mealName = mealData['name'] ?? 'Your scheduled meal';

                  // Schedule notification exactly at the scheduled time
                  await _notificationService.scheduleNotification(
                    id: mealId.hashCode,
                    title: 'Meal Time',
                    body: 'It\'s time for: $mealName',
                    scheduledDate: scheduledAt,
                    payload: mealId,
                  );

                  debugPrint(
                    'Scheduled notification for meal $mealName at $scheduledAt',
                  );

                  // Schedule a reminder notification 30 minutes before
                  final reminderTime = scheduledAt.subtract(
                    const Duration(minutes: 30),
                  );

                  if (reminderTime.isAfter(DateTime.now())) {
                    await _notificationService.scheduleNotification(
                      id: (mealId + "_reminder").hashCode,
                      title: 'Meal Reminder',
                      body: 'Prepare for $mealName in 30 minutes',
                      scheduledDate: reminderTime,
                      payload: '$mealId:reminder',
                    );

                    debugPrint(
                      'Scheduled reminder notification for meal $mealName at $reminderTime',
                    );
                  }
                }
              }

              debugPrint('Successfully updated all meal notifications');
            },
            onError: (error) {
              debugPrint('Error in meal listener: $error');
            },
          );

      debugPrint('Real-time meal notification listener established');
    } catch (e) {
      debugPrint('Error scheduling meal notifications: $e');
    }
  }

  // Dispose method to clean up resources
  void dispose() {
    _mealSubscription?.cancel();
    debugPrint('Meal notification scheduler disposed');
  }

  // Setup listener to watch for auth state changes
  void setupAuthListener() {
    _authService.authStateChanges.listen((User? user) {
      if (user != null) {
        debugPrint('User signed in, scheduling meal notifications');
        scheduleMealNotifications();
      } else {
        debugPrint('User signed out, canceling notifications');
        _notificationService.cancelAllNotifications();
        _mealSubscription?.cancel();
      }
    });
  }

  // This method is now redundant as we're using a real-time listener
  // in scheduleMealNotifications, but keeping it for backward compatibility
  void setupMealChangeListener() {
    scheduleMealNotifications();
  }
}
