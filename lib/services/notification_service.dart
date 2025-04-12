import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:permission_handler/permission_handler.dart';
import '../models/reminder.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tzdata.initializeTimeZones();
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iOSSettings =
        DarwinInitializationSettings();
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iOSSettings,
    );

    await _notifications.initialize(initSettings);
  }

  Future<bool> requestNotificationPermission() async {
    var status = await Permission.notification.status;
    if (status.isDenied) {
      status = await Permission.notification.request();
    }
    return status.isGranted;
  }

  Future<bool> requestExactAlarmPermission() async {
    var status = await Permission.scheduleExactAlarm.status;
    if (status.isDenied) {
      status = await Permission.scheduleExactAlarm.request();
    }
    return status.isGranted;
  }

  Future<bool> checkAndRequestPermissions() async {
    final notificationGranted = await requestNotificationPermission();
    final exactAlarmGranted = await requestExactAlarmPermission();
    return notificationGranted && exactAlarmGranted;
  }

  Future<void> scheduleReminderNotification(Reminder reminder) async {
    try {
      // Check permissions before scheduling
      final permissionsGranted = await checkAndRequestPermissions();
      if (!permissionsGranted) {
        throw Exception('Required permissions not granted');
      }

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'reminder_channel',
        'Reminder Notifications',
        channelDescription: 'Notifications for medication reminders',
        importance: Importance.high,
        priority: Priority.high,
      );

      const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails();

      final NotificationDetails notificationDetails = const NotificationDetails(
        android: androidDetails,
        iOS: iOSDetails,
      );

      // Schedule notifications for each selected day
      for (int day in reminder.days) {
        final now = DateTime.now();
        final scheduledDate = _getNextScheduledDate(now, day, reminder.time);
        final notificationId = reminder.id.hashCode ^ day.hashCode;

        await _notifications.zonedSchedule(
          notificationId,
          'Medication Reminder',
          'Time to take ${reminder.medicationName} (${reminder.quantity} pills)',
          scheduledDate,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      }
    } on Exception {
      rethrow;
    }
  }

  Future<void> cancelReminderNotifications(Reminder reminder) async {
    for (int day in reminder.days) {
      final notificationId = reminder.id.hashCode ^ day.hashCode;
      await _notifications.cancel(notificationId);
    }
  }

  Future<void> updateReminderNotifications(Reminder reminder) async {
    await cancelReminderNotifications(reminder);
    await scheduleReminderNotification(reminder);
  }

  tz.TZDateTime _getNextScheduledDate(DateTime now, int day, TimeOfDay time) {
    final scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // Adjust the day to match the selected day of the week
    final currentDay = scheduledDate.weekday;
    int daysToAdd = day - currentDay;
    if (daysToAdd <= 0) {
      daysToAdd += 7;
    }

    return tz.TZDateTime.from(
        scheduledDate.add(Duration(days: daysToAdd)), tz.local);
  }

  Future<void> showTestNotification() async {
    await initialize();
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'reminder_channel',
      'Reminder Notifications',
      channelDescription: 'Notifications for medication reminders',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails();

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await _notifications.show(
      0,
      'Test Notification',
      'This is a test notification for medication reminder',
      notificationDetails,
    );
  }
}
