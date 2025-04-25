import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/message.dart';
import '../utils/theme.dart';

class ChatBubble extends StatefulWidget {
  final Message message;

  const ChatBubble({super.key, required this.message});

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  final FlutterTts flutterTts = FlutterTts();
  bool isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage('en-US');
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.4);
    await flutterTts.setQueueMode(1);
  }

  Future<void> _speak(String text) async {
    if (!isSpeaking) {
      setState(() => isSpeaking = true);

      // Split text into smaller chunks (approximately 100 characters each)
      List<String> chunks = [];
      int chunkSize = 100;
      for (int i = 0; i < text.length; i += chunkSize) {
        int end = (i + chunkSize < text.length) ? i + chunkSize : text.length;
        chunks.add(text.substring(i, end));
      }

      // Speak each chunk
      for (String chunk in chunks) {
        if (chunk.trim().isNotEmpty) {
          await flutterTts.speak(chunk);
          // Wait for a short pause between chunks
          await Future.delayed(const Duration(milliseconds: 300));
        }
      }

      // Wait for the last chunk to finish
      await Future.delayed(const Duration(seconds: 1));
      setState(() => isSpeaking = false);
    } else {
      await flutterTts.stop();
      setState(() => isSpeaking = false);
    }
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUser = widget.message.role == MessageRole.user;
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
              ? Border.all(color: ThemeColors.primaryGreen.withAlpha(77))
              : null,
        ),
        child: isUser
            ? Text(
                widget.message.content,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(
                          isSpeaking ? Icons.stop : Icons.volume_up,
                          color: ThemeColors.primaryGreen,
                          size: 20,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => _speak(widget.message.content),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  MarkdownBody(
                    data: widget.message.content,
                    selectable: true,
                    styleSheet: MarkdownStyleSheet(
                      p: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: textColor,
                          ),
                      code: TextStyle(
                        backgroundColor: ThemeColors.lightGreen.withAlpha(77),
                        fontFamily: 'monospace',
                        fontSize: 14,
                        color: ThemeColors.darkGreen,
                      ),
                      codeblockDecoration: BoxDecoration(
                        color: ThemeColors.lightGreen.withAlpha(77),
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
                ],
              ),
      ),
    );
  }
}
