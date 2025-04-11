import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../models/message.dart';
import '../models/reminder.dart';

part 'database.g.dart';

@DataClassName('DbMessage')
class Messages extends Table {
  TextColumn get id => text()();
  TextColumn get content => text()();
  TextColumn get role => textEnum<MessageRole>()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get conversationId => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class ChatHistory extends Table {
  TextColumn get id => text()();
  TextColumn get firstMessage => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ReminderData')
class Reminders extends Table {
  TextColumn get id => text()();
  TextColumn get medicationName => text()();
  IntColumn get quantity => integer()();
  IntColumn get hour => integer()();
  IntColumn get minute => integer()();
  TextColumn get days => text()(); // Store as comma-separated string
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Messages, ChatHistory, Reminders])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.createTable(reminders);
          }
        },
      );

  // Chat History Methods
  Future<List<ChatHistoryData>> getAllChatHistory() =>
      select(chatHistory).get();

  Future<void> saveChatHistory(ChatHistoryCompanion entry) =>
      into(chatHistory).insert(entry);

  Future<void> clearChatHistory() => delete(chatHistory).go();

  Future<void> deleteHistoryEntry(String historyId) =>
      (delete(chatHistory)..where((h) => h.id.equals(historyId))).go();

  // Messages Methods
  Future<List<Message>> getMessagesForConversation(
      String conversationId) async {
    final results = await (select(messages)
          ..where((m) => m.conversationId.equals(conversationId)))
        .get();

    return results
        .map((msg) => Message(
              id: msg.id,
              content: msg.content,
              role: msg.role,
              timestamp: msg.timestamp,
              conversationId: msg.conversationId,
            ))
        .toList();
  }

  Future<void> saveMessage(Message message, String conversationId) =>
      into(messages).insert(
        MessagesCompanion(
          id: Value(message.id),
          content: Value(message.content),
          role: Value(message.role),
          timestamp: Value(message.timestamp),
          conversationId: Value(conversationId),
        ),
      );

  Future<void> deleteConversation(String conversationId) =>
      (delete(messages)..where((m) => m.conversationId.equals(conversationId)))
          .go();

  // Reminder Methods
  Future<List<Reminder>> getAllReminders() async {
    final results = await select(reminders).get();
    return results.map((data) => Reminder.fromData(data.toJson())).toList();
  }

  Future<void> saveReminder(Reminder reminder) => into(reminders).insert(
        RemindersCompanion(
          id: Value(reminder.id),
          medicationName: Value(reminder.medicationName),
          quantity: Value(reminder.quantity),
          hour: Value(reminder.time.hour),
          minute: Value(reminder.time.minute),
          days: Value(reminder.days.join(',')),
          isActive: Value(reminder.isActive),
        ),
      );

  Future<void> updateReminder(Reminder reminder) =>
      (update(reminders)..where((t) => t.id.equals(reminder.id))).write(
        RemindersCompanion(
          medicationName: Value(reminder.medicationName),
          quantity: Value(reminder.quantity),
          hour: Value(reminder.time.hour),
          minute: Value(reminder.time.minute),
          days: Value(reminder.days.join(',')),
          isActive: Value(reminder.isActive),
        ),
      );

  Future<void> deleteReminder(String id) =>
      (delete(reminders)..where((t) => t.id.equals(id))).go();

  Future<void> toggleReminder(String id, bool isActive) =>
      (update(reminders)..where((t) => t.id.equals(id))).write(
        RemindersCompanion(
          isActive: Value(isActive),
        ),
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'chat.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
