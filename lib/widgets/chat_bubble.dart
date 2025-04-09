import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/message.dart';
import '../utils/theme.dart';

class ChatBubble extends StatelessWidget {
  final Message message;

  const ChatBubble({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;
    final backgroundColor = isUser ? ThemeColors.userBubbleColor : Colors.white;

    final textColor = isUser ? ThemeColors.darkGreen : Colors.black87;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          left: isUser ? 50 : 8,
          right: isUser ? 8 : 50,
          top: 8,
          bottom: 8,
        ),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: !isUser
              ? Border.all(color: ThemeColors.primaryGreen.withOpacity(0.3))
              : null,
        ),
        child: isUser
            ? Text(
                message.content,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              )
            : MarkdownBody(
                data: message.content,
                selectable: true,
                styleSheet: MarkdownStyleSheet(
                  p: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: textColor,
                      ),
                  code: TextStyle(
                    backgroundColor: ThemeColors.lightGreen.withOpacity(0.3),
                    fontFamily: 'monospace',
                    fontSize: 14,
                    color: ThemeColors.darkGreen,
                  ),
                  codeblockDecoration: BoxDecoration(
                    color: ThemeColors.lightGreen.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onTapLink: (text, href, title) async {
                  if (href != null) {
                    final url = Uri.parse(href);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    }
                  }
                },
              ),
      ),
    );
  }
}
