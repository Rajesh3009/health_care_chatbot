import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart';
import '../models/message.dart';
import 'database_provider.dart';

// Provider for chat history
final historyProvider =
    StateNotifierProvider<HistoryNotifier, List<ChatHistoryData>>((ref) {
  return HistoryNotifier(ref);
});

class HistoryNotifier extends StateNotifier<List<ChatHistoryData>> {
  final Ref ref;
  late final AppDatabase _db;

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
      ChatHistoryCompanion.insert(
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
