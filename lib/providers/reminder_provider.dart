import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reminder.dart';
import '../database/database.dart';
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

  Future<void> addReminder(Reminder reminder) async {
    try {
      await _database.saveReminder(reminder);
      if (reminder.isActive) {
        await _notificationService.scheduleReminderNotification(reminder);
      }
      await _loadReminders();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateReminder(Reminder reminder) async {
    try {
      await _database.updateReminder(reminder);
      if (reminder.isActive) {
        await _notificationService.updateReminderNotifications(reminder);
      } else {
        await _notificationService.cancelReminderNotifications(reminder);
      }
      await _loadReminders();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteReminder(String id) async {
    try {
      final reminder = state.firstWhere((r) => r.id == id);
      await _notificationService.cancelReminderNotifications(reminder);
      await _database.deleteReminder(id);
      await _loadReminders();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> toggleReminder(String id) async {
    try {
      final reminder = state.firstWhere((r) => r.id == id);
      final updatedReminder = Reminder(
        id: reminder.id,
        medicationName: reminder.medicationName,
        quantity: reminder.quantity,
        time: reminder.time,
        days: reminder.days,
        isActive: !reminder.isActive,
      );
      await updateReminder(updatedReminder);
    } catch (e) {
      rethrow;
    }
  }
}

final reminderProvider =
    StateNotifierProvider<ReminderNotifier, List<Reminder>>((ref) {
  return ReminderNotifier(ref);
});
