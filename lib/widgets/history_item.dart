import 'package:flutter/material.dart';
import '../models/message.dart';

class HistoryItem extends StatelessWidget {
  final List<Message> chat;
  
  const HistoryItem({super.key, required this.chat});
  
  @override
  Widget build(BuildContext context) {
    // Display the first message of the chat as the title
    final firstMessage = chat.isNotEmpty ? chat.first.content : 'No messages';
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          firstMessage,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
