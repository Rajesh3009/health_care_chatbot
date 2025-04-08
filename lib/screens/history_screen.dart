import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/history_provider.dart';
import '../widgets/history_item.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatHistory = ref.watch(historyProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.historyTitle),
        backgroundColor: ThemeColors.primaryGreen,
      ),
      body: chatHistory.isEmpty
          ? const Center(
              child: Text(AppConstants.noHistoryMessage),
            )
          : ListView.builder(
              itemCount: chatHistory.length,
              itemBuilder: (context, index) {
                final chat = chatHistory[index];
                return HistoryItem(chat: chat);
              },
            ),
    );
  }
}
