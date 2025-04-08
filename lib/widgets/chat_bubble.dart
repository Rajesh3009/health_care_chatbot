import 'package:flutter/material.dart';
import '../models/message.dart';
import '../utils/theme.dart';

class ChatBubble extends StatelessWidget {
  final Message message;
  
  const ChatBubble({Key? key, required this.message}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      alignment: message.role == MessageRole.user
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: message.role == MessageRole.user
              ? ThemeColors.userBubbleColor
              : ThemeColors.assistantBubbleColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message.content,
          style: TextStyle(
            color: message.role == MessageRole.user
                ? Colors.black
                : Colors.white,
          ),
        ),
      ),
    );
  }
}
