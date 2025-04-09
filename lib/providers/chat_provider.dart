import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart' as db;
import '../models/message.dart';
import '../services/gemini_service.dart';
import '../utils/constants.dart';
import 'history_provider.dart';
import 'package:uuid/uuid.dart';

// Provider for the GeminiService
final geminiServiceProvider = Provider<GeminiService>((ref) {
  return GeminiService();
});

// Provider for the chat messages
final chatProvider = StateNotifierProvider<ChatNotifier, List<Message>>((ref) {
  return ChatNotifier(ref);
});

class ChatNotifier extends StateNotifier<List<Message>> {
  final Ref ref;
  late final db.AppDatabase _db;

  ChatNotifier(this.ref) : super([]) {
    _db = ref.read(databaseProvider);
  }

  void loadChat(String conversationId) async {
    final messages = await _db.getMessagesForConversation(conversationId);
    state = messages;
  }

  Future<void> sendMessage(String content, String historyId) async {
    if (content.trim().isEmpty) return;

    var uuid = const Uuid();

    // Add user message
    final userMessage = Message(
      id: uuid.v4(),
      content: content,
      role: MessageRole.user,
      timestamp: DateTime.now(),
      conversationId: historyId,
    );

    state = [...state, userMessage];

    // Get response from Gemini
    final geminiService = ref.read(geminiServiceProvider);
    final response = await geminiService.getHealthResponse(content);

    // Add assistant message
    final assistantMessage = Message(
      id: uuid.v4(),
      content: response,
      role: MessageRole.assistant,
      timestamp: DateTime.now(),
      conversationId: historyId,
    );

    state = [...state, assistantMessage];

    // Save messages to database
    await _db.saveMessage(userMessage, historyId);
    await _db.saveMessage(assistantMessage, historyId);

    // Save to history only if this is a new conversation
    if (state.length <= 2) {
      ref
          .read(historyProvider.notifier)
          .saveChat([userMessage, assistantMessage], historyId);
    }
  }

  Future<void> deleteChat(String conversationId) async {
    // Delete messages
    await _db.deleteConversation(conversationId);

    // Delete history entry
    await ref.read(historyProvider.notifier).deleteHistoryEntry(conversationId);

    // Clear current chat state
    state = [];
  }
}
