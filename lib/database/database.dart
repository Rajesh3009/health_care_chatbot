import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../models/message.dart';

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

@DriftDatabase(tables: [Messages, ChatHistory])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

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
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'chat.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
