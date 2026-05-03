import 'package:flutter/material.dart';
import 'practice_screen.dart';
import 'encode_screen.dart';
import '../models/letter_number_map.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showReferenceChart(BuildContext context) {
    // Group letters by number
    final Map<int, List<String>> numberToLetters = {};
    for (int i = 0; i <= 9; i++) {
      numberToLetters[i] = LetterNumberMap.getLettersForNumber(i);
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Major System Reference'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: 10,
            itemBuilder: (context, index) {
              final letters = numberToLetters[index]!.join(', ');
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 32,
                      child: Text(
                        '$index',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      letters,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory App'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo image
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Image.asset(
                'logo.png',
                width: 300,
                height: 300,
              ),
            ),
            // Encode button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EncodeScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Encode Number'),
            ),
            const SizedBox(height: 20),
            // Practice button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PracticeScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Practice Letters to Numbers'),
            ),
            const SizedBox(height: 20),
            // Reference chart button
            OutlinedButton(
              onPressed: () => _showReferenceChart(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Reference Chart'),
            ),
          ],
        ),
      ),
    );
  }
}