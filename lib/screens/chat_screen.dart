import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input.dart';
import '../utils/theme.dart';
import '../providers/history_provider.dart'; // Import history provider
import '../widgets/history_item.dart'; // Import history item
import '../models/message.dart';
import 'package:uuid/uuid.dart';

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(chatProvider);
    final history = ref.watch(historyProvider); // Watch history provider

    return Scaffold(
      appBar: AppBar(
        title: const Text('Healthcare Assistant'),
        backgroundColor: ThemeColors.primaryGreen,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              var uuid = const Uuid();
              final newHistoryId = uuid.v4();
              ref.read(chatProvider.notifier).loadChat(newHistoryId);
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: history
              .map((historyItem) => HistoryItem(historyItem: historyItem))
              .toList(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return AnimatedOpacity(
                  opacity: message.role == MessageRole.assistant ? 1.0 : 1.0,
                  duration: const Duration(milliseconds: 500),
                  child: ChatBubble(message: message),
                );
              },
            ),
          ),
          ChatInput(
            onSend: (text, historyId) {
              ref.read(chatProvider.notifier).sendMessage(text, historyId);
            },
          ),
        ],
      ),
    );
  }
}
