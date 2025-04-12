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

  Future<void> requestPermissions(BuildContext context) async {
    // Request notification permission
    var status = await Permission.notification.status;
    if (status.isDenied) {
      await Permission.notification.request();
    }

    if (Theme.of(context).platform == TargetPlatform.android) {
      // Request exact alarm permission
      var alarmStatus = await Permission.scheduleExactAlarm.status;
      if (alarmStatus.isDenied) {
        await Permission.scheduleExactAlarm.request();
      }
    }
  }

  Future<void> scheduleReminderNotification(
      Reminder reminder, BuildContext context) async {
    try {
      // Check permissions before scheduling
      if (Theme.of(context).platform == TargetPlatform.android) {
        var alarmStatus = await Permission.scheduleExactAlarm.status;
        if (alarmStatus.isDenied) {
          throw Exception('SCHEDULE_EXACT_ALARM permission denied');
        }
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
    } on Exception catch (e) {
      if (e.toString().contains('SCHEDULE_EXACT_ALARM')) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Permission Required'),
            content: const Text(
                'Please grant the SCHEDULE_EXACT_ALARM permission in the app settings to schedule exact alarms.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  await Permission.scheduleExactAlarm.request();
                  Navigator.of(context).pop();
                },
                child: const Text('Grant Permission'),
              ),
            ],
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to schedule notification: ${e.toString()}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> cancelReminderNotifications(Reminder reminder) async {
    for (int day in reminder.days) {
      final notificationId = reminder.id.hashCode ^ day.hashCode;
      await _notifications.cancel(notificationId);
    }
  }

  Future<void> updateReminderNotifications(
      Reminder reminder, BuildContext context) async {
    await cancelReminderNotifications(reminder);
    await scheduleReminderNotification(reminder, context);
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

  Future<void> showTestNotification(BuildContext context) async {
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
