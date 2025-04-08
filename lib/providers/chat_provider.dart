import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message.dart';
import '../services/gemini_service.dart';
import '../utils/constants.dart';
import 'history_provider.dart';

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
  
  ChatNotifier(this.ref) : super([
    // Add initial welcome message
    Message(
      content: AppConstants.welcomeMessage,
      role: MessageRole.assistant,
    ),
  ]);
  
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;
    
    // Add user message
    final userMessage = Message(
      content: content,
      role: MessageRole.user,
    );
    
    state = [...state, userMessage];
    
    // Get response from Gemini
    final geminiService = ref.read(geminiServiceProvider);
    final response = await geminiService.getHealthResponse(content);
    
    // Add assistant message
    final assistantMessage = Message(
      content: response,
      role: MessageRole.assistant,
    );
    
    state = [...state, assistantMessage];
    
    // Save to history
    ref.read(historyProvider.notifier).saveChat([userMessage, assistantMessage]);
  }
  
  void clearChat() {
    state = [
      // Reset to just the welcome message
      Message(
        content: AppConstants.welcomeMessage,
        role: MessageRole.assistant,
      ),
    ];
  }
}
