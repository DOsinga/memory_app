import 'dart:math';
import 'package:flutter/material.dart';
import '../models/letter_number_map.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  String _currentLetter = '';
  String _feedback = '';
  bool _isCorrect = false;
  final TextEditingController _controller = TextEditingController();
  final Random _random = Random();
  int _score = 0;
  int _total = 0;

  @override
  void initState() {
    super.initState();
    _generateNewLetter();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _generateNewLetter() {
    final consonants = LetterNumberMap.getAllConsonants();
    setState(() {
      _currentLetter = consonants[_random.nextInt(consonants.length)];
      _feedback = '';
      _controller.clear();
    });
  }

  void _processAnswer(String answer) {
    if (answer.isEmpty) return;
    
    final correctAnswer = LetterNumberMap.getNumber(_currentLetter);
    final isCorrect = answer == correctAnswer.toString();
    
    setState(() {
      _total++;
      if (isCorrect) {
        _score++;
        _feedback = 'Correct!';
        _isCorrect = true;
      } else {
        _feedback = 'Answer was: $correctAnswer';
        _isCorrect = false;
      }
    });
    
    // Wait a moment before showing the next letter
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _generateNewLetter();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Practice Letters to Numbers'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Score: $_score / $_total',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              'What number corresponds to the letter:',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Text(
              _currentLetter,
              style: const TextStyle(
                fontSize: 80, 
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24),
              maxLength: 1,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Enter the number',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  _processAnswer(value);
                }
              },
            ),
            const SizedBox(height: 20),
            if (_feedback.isNotEmpty)
              Text(
                _feedback,
                style: TextStyle(
                  fontSize: 18,
                  color: _isCorrect ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}