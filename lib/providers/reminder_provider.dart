import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reminder.dart';
import '../database/database.dart';
import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import 'database_provider.dart';

class ReminderNotifier extends StateNotifier<List<Reminder>> {
  final Ref ref;
  final NotificationService _notificationService;

  ReminderNotifier(this.ref)
      : _notificationService = NotificationService(),
        super([]) {
    _loadReminders();
  }

  AppDatabase get _database => ref.read(databaseProvider);

  Future<void> _loadReminders() async {
    final reminders = await _database.getAllReminders();
    state = reminders;
  }

  Future<void> addReminder(Reminder reminder, BuildContext context) async {
    await _database.saveReminder(reminder);
    if (reminder.isActive) {
      await _notificationService.requestPermissions(context);
      await _notificationService.scheduleReminderNotification(
          reminder, context);
    }
    await _loadReminders();
  }

  Future<void> updateReminder(Reminder reminder, BuildContext context) async {
    await _database.updateReminder(reminder);
    if (reminder.isActive) {
      await _notificationService.requestPermissions(context);
      await _notificationService.updateReminderNotifications(reminder, context);
      await _notificationService.scheduleReminderNotification(
          reminder, context);
    } else {
      await _notificationService.cancelReminderNotifications(reminder);
    }
    await _loadReminders();
  }

  Future<void> deleteReminder(String id) async {
    final reminder = state.firstWhere((r) => r.id == id);
    await _notificationService.cancelReminderNotifications(reminder);
    await _database.deleteReminder(id);
    await _loadReminders();
  }

  Future<void> toggleReminder(String id, BuildContext context) async {
    final reminder = state.firstWhere((r) => r.id == id);
    final updatedReminder = Reminder(
      id: reminder.id,
      medicationName: reminder.medicationName,
      quantity: reminder.quantity,
      time: reminder.time,
      days: reminder.days,
      isActive: !reminder.isActive,
    );
    await updateReminder(updatedReminder, context);
  }
}

final reminderProvider =
    StateNotifierProvider<ReminderNotifier, List<Reminder>>((ref) {
  return ReminderNotifier(ref);
});
