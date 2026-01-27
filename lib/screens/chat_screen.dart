import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../widgets/message_bubble.dart';
import '../widgets/input_bar.dart';
import '../services/gemini_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> messages = [];
  final ScrollController scrollController = ScrollController();
  bool isDarkMode = true;
  bool _isLoading = false;

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void addMessage(String text, String role) {
    setState(() {
      messages.add(ChatMessage(
        text: text,
        role: role,
        timestamp: DateTime.now(),
      ));
    });
    scrollToBottom();
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          0.0, // Because reverse is true, 0.0 is the bottom
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> handleSend(String text) async {
    if (text.trim().isEmpty) return;

    addMessage(text, "user");
    setState(() => _isLoading = true);

    try {
      final aiResponse = await GeminiService.sendMultiTurnMessage(messages);
      addMessage(aiResponse, "model");
    } catch (e) {
      addMessage('❌ Error: $e', "model");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Futuristic Monotonal Palette
    final Color bgColor = isDarkMode ? const Color(0xFF121212) : const Color(0xFFF5F5F5);
    final Color appBarColor = isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF);
    final Color textPrimary = isDarkMode ? Colors.white : Colors.black;
    final Color accentColor = isDarkMode ? const Color(0xFF2C2C2C) : const Color(0xFFE0E0E0);

    return Theme(
      data: ThemeData(
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: appBarColor,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'AI-DA // FLUTTER EXPERT',
            style: TextStyle(
              color: textPrimary,
              letterSpacing: 2,
              fontSize: 12,
              fontWeight: FontWeight.w300,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                color: textPrimary,
                size: 18,
              ),
              onPressed: () => setState(() => isDarkMode = !isDarkMode),
            ),
          ],
          shape: Border(bottom: BorderSide(color: accentColor, width: 0.5)),
        ),
        body: Column(
          children: [
            Expanded(
              child: messages.isEmpty
                  ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.terminal, size: 40, color: accentColor),
                    const SizedBox(height: 16),
                    Text(
                      'S Y S T E M  O N L I N E',
                      style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 2),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                controller: scrollController,
                reverse: true, // Newest messages at bottom
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[messages.length - 1 - index];
                  return MessageBubble(message: msg);
                },
              ),
            ),

            if (_isLoading)
              LinearProgressIndicator(
                backgroundColor: bgColor,
                color: textPrimary,
                minHeight: 1,
              ),

            Container(
              color: appBarColor,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 12,
                top: 12, left: 16, right: 16,
              ),
              child: InputBar(onSendMessage: handleSend),
            ),
          ],
        ),
      ),
    );
  }
}