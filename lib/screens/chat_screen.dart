import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_bubble.dart';
import '../providers/history_provider.dart';
import '../widgets/history_item.dart';
import '../models/message.dart';
import 'package:uuid/uuid.dart';
import '../widgets/typing_indicator.dart';
import 'theme_screen.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _textController = TextEditingController();

  void _sendMessage() {
    if (_textController.text.trim().isNotEmpty) {
      final uuid = const Uuid();
      ref.read(chatProvider.notifier).sendMessage(_textController.text, uuid.v4());
      _textController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatProvider);
    final history = ref.watch(historyProvider);
    final isLoading = ref.watch(isLoadingProvider);

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
      drawer: SafeArea(
        child: Drawer(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "History",
                  style: TextStyle(
                    fontSize: 24,
                  ),
                ),
              ),
              Divider(),
              Expanded(
                child: ListView(
                  children: history
                      .map((historyItem) => HistoryItem(
                            historyItem: historyItem,
                            onTap: () => Navigator.pop(context),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
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
                    controller: _textController,
                    enabled: !isLoading,
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: isLoading ? null : _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
