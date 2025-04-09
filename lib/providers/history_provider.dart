import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart' as db;
import '../models/message.dart';

// Provider for the database
final databaseProvider = Provider<db.AppDatabase>((ref) {
  return db.AppDatabase();
});

// Provider for chat history
final historyProvider =
    StateNotifierProvider<HistoryNotifier, List<db.ChatHistoryData>>((ref) {
  return HistoryNotifier(ref);
});

class HistoryNotifier extends StateNotifier<List<db.ChatHistoryData>> {
  final Ref ref;
  late final db.AppDatabase _db;

  HistoryNotifier(this.ref) : super([]) {
    _db = ref.read(databaseProvider);
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await _db.getAllChatHistory();
    state = history;
  }

  Future<void> saveChat(List<Message> chat, String historyId) async {
    if (chat.isEmpty) return;

    final firstMessage = chat.first;

    // Save to database
    await _db.saveChatHistory(
      db.ChatHistoryCompanion.insert(
        id: historyId,
        firstMessage: firstMessage.content,
      ),
    );

    // Update state
    final newHistory = await _db.getAllChatHistory();
    state = newHistory;
  }

  Future<void> clearHistory() async {
    await _db.clearChatHistory();
    state = [];
  }

  Future<void> deleteHistoryEntry(String historyId) async {
    // Delete from database
    await _db.deleteHistoryEntry(historyId);

    // Update state by removing the entry
    state = state.where((entry) => entry.id != historyId).toList();
  }
}
