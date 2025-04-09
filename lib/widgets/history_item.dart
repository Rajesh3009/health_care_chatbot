import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_provider.dart';
import '../database/database.dart';

class HistoryItem extends ConsumerWidget {
  final ChatHistoryData historyItem;

  const HistoryItem({Key? key, required this.historyItem}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(
          historyItem.firstMessage,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: () {
          ref.read(chatProvider.notifier).loadChat(historyItem.id);
        },
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            ref.read(chatProvider.notifier).deleteChat(historyItem.id);
          },
        ),
      ),
    );
  }
}
