import 'package:flutter/material.dart';

class InputBar extends StatefulWidget {
  final Function(String) onSendMessage;

  const InputBar({Key? key, required this.onSendMessage}) : super(key: key);

  @override
  _InputBarState createState() => _InputBarState();
}

class _InputBarState extends State<InputBar> {
  final TextEditingController _controller = TextEditingController();

  void _submit() {
    if (_controller.text.trim().isNotEmpty) {
      widget.onSendMessage(_controller.text.trim());
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if the current theme is Dark or Light
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // HIGH CONTRAST PALETTE: Text color is always the strict opposite of the background
    final Color bgColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF);
    final Color inputFieldBg = isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5);

    // Text is White in Dark mode, Black in Light mode (Pure Opposites)
    final Color contrastTextColor = isDark ? const Color(0xFFFFFFFF) : const Color(0xFF000000);
    final Color subTextColor = isDark ? const Color(0xFF757575) : const Color(0xFF9E9E9E);
    final Color borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // THE INPUT BOX
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: inputFieldBg,
                border: Border.all(color: borderColor, width: 1),
                borderRadius: BorderRadius.circular(2), // Sharp futuristic corners
              ),
              child: TextField(
                controller: _controller,
                // Text color is now strictly opposite to the UI background
                style: TextStyle(
                  color: contrastTextColor,
                  fontSize: 14,
                  fontFamily: 'Courier', // Monospace for futuristic feel
                  letterSpacing: 0.5,
                ),
                cursorColor: contrastTextColor,
                decoration: InputDecoration(
                  hintText: "TYPE COMMAND...",
                  hintStyle: TextStyle(
                    color: subTextColor,
                    fontSize: 11,
                    letterSpacing: 2,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _submit(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // THE SEND BOX (FIXED)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _submit,
              child: Container(
                height: 50, // Matches the height of the input field
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  // Inverts for the button: Black background in light mode, White/Light in dark mode
                  color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFF000000),
                  border: Border.all(color: contrastTextColor, width: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Center(
                  child: Text(
                    "SEND",
                    style: TextStyle(
                      // Text on button is also inverted for maximum visibility
                      color: isDark ? const Color(0xFFFFFFFF) : const Color(0xFFFFFFFF),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}