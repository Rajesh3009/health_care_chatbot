import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/message.dart';

class ChatBubble extends StatelessWidget {
  final Message message;

  const ChatBubble({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;
    final backgroundColor = isUser
        ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
        : Theme.of(context).colorScheme.secondary.withOpacity(0.1);

    final textColor = isUser
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.secondary;

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
        ),
        child: isUser
            ? Text(
                message.content,
                style: TextStyle(color: textColor),
              )
            : MarkdownBody(
                data: message.content,
                selectable: true,
                styleSheet: MarkdownStyleSheet(
                  p: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: textColor,
                      ),
                  code: TextStyle(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    fontFamily: 'monospace',
                    fontSize: 14,
                    color: textColor,
                  ),
                  codeblockDecoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
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
