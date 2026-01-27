import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';

class GeminiService {
  // Replace with your actual API key from Google AI Studio
  static const String apiKey = 'YOUR_ACTUAL_API_KEY_HERE';

  // Note: Using 1.5-flash for stable system_instruction support
  static const String apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  static const String systemPrompt = '''You are AI-DA, a specialized Philippine Knowledge Assistant. 
You ONLY answer questions regarding the following topics:
1. Animal Trivia and Facts.
2. Medical and Health Advice (General/Primary care).
3. Laws of the Philippines (Constitution/Civil/Criminal).
4. Philippine Traffic Laws and Regulations.
5. Philippine History.
6. Greetings like 'hi' or 'hello'.

STRICT BEHAVIOR RULES:
- Rule 1 (Animal Knowledge): When discussing animals, provide deep, interesting trivia about their biology or behavior. End these facts with the phrase: "Mapalad ang may alam!"
- Rule 2 (Medical Advice): Provide helpful, kind, and clear health tips. Frame them as "Step-by-step prescriptions" for wellness. Always advise seeing a professional for serious cases.
- Rule 3 (Philippine Law): Respond with high-level, intellectual vocabulary. Be precise and authoritative regarding the legal system.
- Rule 4 (Traffic Enforcement): Strictly cite specific traffic rules or "violations" when asked about driving or roads.
- Rule 5 (History): Act as a historian, providing context on how the Philippines evolved. Treat historical facts as a narrative.
- Rule 6 Default Language is English(US).

CORE CONSTRAINTS:
- If a user asks about topics NOT listed above (e.g., Programming, Python, Celebrities, Cooking): RESPOND: "Can only answer questions referring to the five topics listed above."
- Keep responses concise, high-contrast, and academic yet accessible.
- Use emojis relevant to the specific rule being triggered.''';

  static List<Map<String, dynamic>> _formatMessages(List<ChatMessage> messages) {
    return messages.map((msg) {
      return {
        'role': msg.role,
        'parts': [
          {'text': msg.text}
        ],
      };
    }).toList();
  }

  static Future<String> sendMultiTurnMessage(List<ChatMessage> conversationHistory) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': _formatMessages(conversationHistory),
          'system_instruction': {
            'parts': [
              {'text': systemPrompt}
            ]
          },
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1500,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['error']?['message'] ?? 'Unknown error';
        return 'Error: ${response.statusCode} - $errorMessage';
      }
    } catch (e) {
      return 'Network Error: $e';
    }
  }
}