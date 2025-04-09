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
import '../widgets/typing_indicator.dart';
import 'theme_screen.dart';

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(chatProvider);
    final history = ref.watch(historyProvider); // Watch history provider
    final isLoading = ref.watch(isLoadingProvider);
    final textController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Healthcare Assistant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.color_lens),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ThemeScreen()),
              );
            },
          ),
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
              itemCount: messages.length + (isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == messages.length && isLoading) {
                  return const Align(
                    alignment: Alignment.centerLeft,
                    child: TypingIndicator(),
                  );
                }

                final message = messages[index];
                return AnimatedOpacity(
                  opacity: message.role == MessageRole.assistant ? 1.0 : 1.0,
                  duration: const Duration(milliseconds: 500),
                  child: ChatBubble(message: message),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textController,
                    enabled: !isLoading, // Disable input while loading
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (text) {
                      if (text.trim().isNotEmpty) {
                        final uuid = const Uuid();
                        ref
                            .read(chatProvider.notifier)
                            .sendMessage(text, uuid.v4());
                        textController.clear();
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: isLoading
                      ? null
                      : () {
                          if (textController.text.trim().isNotEmpty) {
                            final uuid = const Uuid();
                            ref
                                .read(chatProvider.notifier)
                                .sendMessage(textController.text, uuid.v4());
                            textController.clear();
                          }
                        },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
