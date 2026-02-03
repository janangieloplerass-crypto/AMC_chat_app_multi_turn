import 'dart:async';
import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../widgets/message_bubble.dart';
import '../widgets/input_bar.dart';
import '../services/gemini_service.dart';

class BaseTopicScreen extends StatefulWidget {
  final String topic;
  const BaseTopicScreen({super.key, required this.topic});

  @override
  State<BaseTopicScreen> createState() => _BaseTopicScreenState();
}

class _BaseTopicScreenState extends State<BaseTopicScreen> {
  final List<ChatMessage> messages = [];
  final ScrollController scrollController = ScrollController();
  bool _isLoading = false;
  bool _isCancelled = false;
  bool _showSwitchNotification = false;
  Timer? _inactivityTimer;

  @override
  void initState() {
    super.initState();
    // No timer at start so notification doesn't cover the welcome message
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    scrollController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(const Duration(seconds: 1), () {
      if (mounted && !_isLoading && messages.isNotEmpty) {
        setState(() => _showSwitchNotification = true);
      }
    });
  }

  void addMessage(String text, String role) {
    setState(() => messages.add(ChatMessage(text: text, role: role, timestamp: DateTime.now())));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
            0.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut
        );
      }
    });
  }

  Future<void> handleSend(String text) async {
    if (text.trim().isEmpty) return;

    _inactivityTimer?.cancel();
    setState(() {
      _showSwitchNotification = false;
      _isLoading = true;
      _isCancelled = false;
    });

    addMessage(text, "user");

    try {
      // Logic for strict topic enforcement
      final String constraint = "PROTOCOL: You are locked into '${widget.topic}'. If user asks anything else, say 'Protocol request denied.'";

      // Call service with messages
      final aiResponse = await GeminiService.sendMultiTurnMessage([
        ChatMessage(text: constraint, role: "user", timestamp: DateTime.now()),
        ...messages
      ]);

      if (_isCancelled) {
        addMessage("the user stopped me from responding.", "model");
      } else {
        addMessage(aiResponse, "model");
      }
    } catch (e) {
      if (!_isCancelled) addMessage('❌ Error: $e', "model");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        _startTimer();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color textColor = Colors.blueGrey;
    final Color appBarColor = const Color(0xFF1A1A1A);
    final Color bgColor = const Color(0xFF0D0D0D);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
            widget.topic.toUpperCase(),
            style: const TextStyle(fontSize: 10, letterSpacing: 2, color: Colors.white, fontWeight: FontWeight.bold)
        ),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.white),
            onPressed: () => Navigator.pop(context)
        ),
        shape: const Border(bottom: BorderSide(color: Color(0xFF333333), width: 0.5)),
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.terminal, size: 40, color: Colors.blueGrey),
                  const SizedBox(height: 16),
                  Text(
                    "WELCOME TO '${widget.topic.toUpperCase()}' USER.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 10,
                      letterSpacing: 2,
                      fontFamily: 'Courier',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "SYSTEM READY // PROTOCOL ACTIVE",
                    style: TextStyle(color: Colors.grey, fontSize: 8, letterSpacing: 1),
                  ),
                ],
              ),
            )
                : ListView.builder(
              controller: scrollController,
              reverse: true,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[messages.length - 1 - index];
                return MessageBubble(message: msg);
              },
            ),
          ),

          // 1-second inactivity notification bar
          if (_showSwitchNotification && !_isLoading && messages.isNotEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: appBarColor,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.blueGrey.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.info_outline, size: 12, color: Colors.blueGrey),
                  const SizedBox(width: 8),
                  Text(
                    "ONLY QUESTIONS ABOUT ${widget.topic.toUpperCase()} ARE ALLOWED",
                    style: const TextStyle(color: Colors.blueGrey, fontSize: 8, letterSpacing: 1),
                  ),
                ],
              ),
            ),

          if (_isLoading)
            const LinearProgressIndicator(color: Colors.blueGrey, backgroundColor: Colors.transparent, minHeight: 1),

          Container(
            color: appBarColor,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 12,
              top: 12, left: 16, right: 16,
            ),
            child: InputBar(
              onSendMessage: handleSend,
              isLoading: _isLoading,
              onStop: () => setState(() => _isCancelled = true),
            ),
          ),
        ],
      ),
    );
  }
}