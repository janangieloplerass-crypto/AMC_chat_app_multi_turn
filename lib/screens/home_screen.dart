import 'package:flutter/material.dart';
import 'animal_trivia_screen.dart';
import 'medical_advice_screen.dart';
import 'ph_laws_screen.dart';
import 'traffic_laws_screen.dart';
import 'ph_history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isDarkMode = true;

  final List<Map<String, dynamic>> _topicProtocols = [
    {"title": "Animal Trivia and Facts", "screen": const AnimalTriviaScreen()},
    {"title": "Medical and Health Advice", "screen": const MedicalAdviceScreen()},
    {"title": "Laws of the Philippines", "screen": const PhLawsScreen()},
    {"title": "Philippine Traffic Laws", "screen": const TrafficLawsScreen()},
    {"title": "Philippine History", "screen": const PhHistoryScreen()},
  ];

  @override
  Widget build(BuildContext context) {
    final Color bgColor = isDarkMode ? const Color(0xFF0D0D0D) : const Color(0xFFF5F5F5);
    final Color appBarColor = isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFFFFFFF);
    final Color textPrimary = isDarkMode ? Colors.white : Colors.black;
    final Color borderCol = isDarkMode ? const Color(0xFF333333) : const Color(0xFFE0E0E0);

    return Theme(
      data: ThemeData(brightness: isDarkMode ? Brightness.dark : Brightness.light),
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: appBarColor,
          elevation: 0,
          centerTitle: true,
          title: Text('AI-DA // CENTRAL HUB',
              style: TextStyle(color: textPrimary, letterSpacing: 3, fontSize: 12, fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode, size: 18),
              onPressed: () => setState(() => isDarkMode = !isDarkMode),
            ),
          ],
          shape: Border(bottom: BorderSide(color: borderCol, width: 0.5)),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                const Icon(Icons.terminal, size: 60, color: Colors.blueGrey),
                const SizedBox(height: 20),
                Text("S Y S T E M  O N L I N E",
                    style: TextStyle(color: textPrimary, letterSpacing: 4, fontSize: 12)),
                const SizedBox(height: 50),
                const Text("SELECT PROTOCOL TO INITIALIZE:",
                    style: TextStyle(color: Colors.grey, fontSize: 9, letterSpacing: 2)),
                const SizedBox(height: 30),
                ..._topicProtocols.map((protocol) => Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          side: BorderSide(color: borderCol),
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2))
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => protocol['screen']),
                      ),
                      child: Text(protocol['title'].toUpperCase(),
                          style: TextStyle(color: textPrimary, letterSpacing: 2, fontSize: 10)),
                    ),
                  ),
                )).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}