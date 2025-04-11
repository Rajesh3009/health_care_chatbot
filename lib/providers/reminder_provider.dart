import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/reminder.dart';
import '../database/database.dart';
import 'history_provider.dart';

class ReminderNotifier extends StateNotifier<List<Reminder>> {
  final AppDatabase _db;
  ReminderNotifier(this._db) : super([]) {
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    state = await _db.getAllReminders();
  }

  Future<void> addReminder(Reminder reminder) async {
    await _db.saveReminder(reminder);
    await _loadReminders();
  }

  Future<void> updateReminder(Reminder updatedReminder) async {
    await _db.updateReminder(updatedReminder);
    await _loadReminders();
  }

  Future<void> deleteReminder(String id) async {
    await _db.deleteReminder(id);
    await _loadReminders();
  }

  Future<void> toggleReminder(String id) async {
    final reminder = state.firstWhere((r) => r.id == id);
    await _db.toggleReminder(id, !reminder.isActive);
    await _loadReminders();
  }
}

final reminderProvider =
    StateNotifierProvider<ReminderNotifier, List<Reminder>>((ref) {
  final db = ref.watch(databaseProvider);
  return ReminderNotifier(db);
});
