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

// Provider for loading state
final isLoadingProvider = StateProvider<bool>((ref) => false);

// Provider for current conversation ID
final currentConversationIdProvider = StateProvider<String>((ref) => '');

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
    // Set the current conversation ID
    ref.read(currentConversationIdProvider.notifier).state = conversationId;

    // Load messages for this conversation
    final messages = await _db.getMessagesForConversation(conversationId);
    state = messages;
  }

  Future<void> sendMessage(String content, String historyId) async {
    if (content.trim().isEmpty) return;

    var uuid = const Uuid();
    // Use the current conversation ID if it exists, otherwise use the provided historyId
    final conversationId = ref.read(currentConversationIdProvider) != ''
        ? ref.read(currentConversationIdProvider)
        : historyId;

    // If this is a new conversation, set it as current
    if (ref.read(currentConversationIdProvider) == '') {
      ref.read(currentConversationIdProvider.notifier).state = conversationId;
    }

    // Add user message
    final userMessage = Message(
      id: uuid.v4(),
      content: content,
      role: MessageRole.user,
      timestamp: DateTime.now(),
      conversationId: conversationId,
    );

    state = [...state, userMessage];

    // Set loading state to true
    ref.read(isLoadingProvider.notifier).state = true;

    try {
      // Get response from Gemini
      final geminiService = ref.read(geminiServiceProvider);
      final response = await geminiService.getHealthResponse(content);

      // Add assistant message
      final assistantMessage = Message(
        id: uuid.v4(),
        content: response,
        role: MessageRole.assistant,
        timestamp: DateTime.now(),
        conversationId: conversationId,
      );

      state = [...state, assistantMessage];

      // Save messages to database
      await _db.saveMessage(userMessage, conversationId);
      await _db.saveMessage(assistantMessage, conversationId);

      // Save to history only if this is a new conversation
      if (state.length <= 2) {
        ref
            .read(historyProvider.notifier)
            .saveChat([userMessage, assistantMessage], conversationId);
      }
    } finally {
      // Set loading state to false regardless of success or failure
      ref.read(isLoadingProvider.notifier).state = false;
    }
  }

  Future<void> deleteChat(String conversationId) async {
    // Delete messages
    await _db.deleteConversation(conversationId);

    // Delete history entry
    await ref.read(historyProvider.notifier).deleteHistoryEntry(conversationId);

    // Clear current chat state and conversation ID
    state = [];
    ref.read(currentConversationIdProvider.notifier).state = '';
  }
}
