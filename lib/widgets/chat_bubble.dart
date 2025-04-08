import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';
import '../models/message.dart';
import '../utils/theme.dart';

class ChatBubble extends StatelessWidget {
  final Message message;

  const ChatBubble({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextStyle defaultTextStyle = TextStyle(
      color: message.role == MessageRole.user ? Colors.black : Colors.black,
    );

    List<TextSpan> textSpans = [];
    String text = message.content;
    RegExp urlRegex = RegExp(r"(https?://\S+)");
    Iterable<Match> matches = urlRegex.allMatches(text);

    int currentIndex = 0;
    for (Match match in matches) {
      if (match.start > currentIndex) {
        textSpans.add(TextSpan(
          text: text.substring(currentIndex, match.start),
          style: defaultTextStyle,
        ));
      }

      String url = match.group(0)!;
      textSpans.add(TextSpan(
        text: url,
        style: defaultTextStyle.copyWith(
          color: Colors.blue,
          decoration: TextDecoration.underline,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            launchUrl(Uri.parse(url));
          },
      ));
      currentIndex = match.end;
    }

    if (currentIndex < text.length) {
      textSpans.add(TextSpan(
        text: text.substring(currentIndex, text.length),
        style: defaultTextStyle,
      ));
    }

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
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: RichText(
          text: TextSpan(
            children: textSpans,
          ),
        ),
      ),
    );
  }
}
