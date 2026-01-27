import 'package:flutter/material.dart';
import '../models/chat_message.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // User: Solid High Contrast (White text)
    // AI: Transparent Outline (Text flips based on Theme)
    final Color userBoxColor = isDark ? Color(0xFF2C2C2C) : Color(0xFF000000);
    final Color aiTextColor = isDark ? Colors.white : Colors.black;
    final Color aiBorderColor = isDark ? Color(0xFF3D3D3D) : Color(0xFFD1D1D1);

    return Align(
      alignment: message.isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: message.isUserMessage ? userBoxColor : Colors.transparent,
          border: message.isUserMessage ? null : Border.all(color: aiBorderColor),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(2),
            topRight: Radius.circular(2),
            bottomLeft: message.isUserMessage ? Radius.circular(12) : Radius.circular(2),
            bottomRight: message.isUserMessage ? Radius.circular(2) : Radius.circular(12),
          ),
        ),
        child: Column(
          crossAxisAlignment: message.isUserMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(message.isUserMessage ? "USER" : "AI-DA // SYSTEM",
                style: TextStyle(color: Colors.grey, fontSize: 8, letterSpacing: 2)),
            SizedBox(height: 4),
            Text(
              message.text,
              style: TextStyle(
                color: message.isUserMessage ? Colors.white : aiTextColor,
                fontFamily: 'Courier',
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}