import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_provider.dart';
import '../database/database.dart';

class HistoryItem extends ConsumerWidget {
  final ChatHistoryData historyItem;
  final VoidCallback? onTap;

  const HistoryItem({
    super.key,
    required this.historyItem,
    this.onTap,
  });

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year.toString().substring(2)}';
  }

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
        subtitle: Text(
          _formatDate(historyItem.timestamp),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(179),
              ),
        ),
        onTap: () {
          ref.read(chatProvider.notifier).loadChat(historyItem.id);
          onTap?.call();
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
