import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/word_service.dart';
import '../models/letter_number_map.dart';

class EncodeScreen extends StatefulWidget {
  const EncodeScreen({super.key});

  @override
  State<EncodeScreen> createState() => _EncodeScreenState();
}

class _EncodeScreenState extends State<EncodeScreen> {
  final TextEditingController _controller = TextEditingController();
  String _numberInput = '';
  // Each segmentation is a list of digit groups; for each group we store word matches
  List<List<MapEntry<String, List<String>>>> _segmentedResults = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeWordService();
  }

  Future<void> _initializeWordService() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      await Provider.of<WordService>(context, listen: false).loadWordList();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading word list: $e'))
        );
      }
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _processInput(String input) {
    if (input.isEmpty) {
      setState(() {
        _numberInput = '';
        _segmentedResults = [];
      });
      return;
    }

    final wordService = Provider.of<WordService>(context, listen: false);
    final segmentations = wordService.findSegmentations(input);

    // For each segmentation, look up word matches for every segment
    List<List<MapEntry<String, List<String>>>> results = [];
    for (var segmentation in segmentations) {
      List<MapEntry<String, List<String>>> row = [];
      for (var segment in segmentation) {
        var matches = wordService.findWordsMatchingPattern(segment);
        row.add(MapEntry(segment, matches));
      }
      results.add(row);
    }

    setState(() {
      _numberInput = input;
      _segmentedResults = results;
    });
  }

  // Create a highlighted word showing which consonants match the encoded digits
  Widget _buildHighlightedWord(String word, String pattern) {
    // Extract consonants and their positions
    List<int> consonantPositions = [];
    List<String> consonantValues = [];
    
    for (int i = 0; i < word.length; i++) {
      String letter = word[i].toUpperCase();
      if (LetterNumberMap.isConsonantInMap(letter)) {
        int? number = LetterNumberMap.getNumber(letter);
        if (number != null) {
          consonantPositions.add(i);
          consonantValues.add(number.toString());
        }
      }
    }
    
    // Determine which consonants should be highlighted (match pattern)
    List<bool> highlight = List.filled(word.length, false);
    
    // Mark consonants that match the pattern
    for (int i = 0; i < consonantValues.length && i < pattern.length; i++) {
      if (i < pattern.length && consonantValues[i] == pattern[i]) {
        highlight[consonantPositions[i]] = true;
      }
    }
    
    // Find the last matching consonant position
    int lastHighlightedPosition = -1;
    for (int i = 0; i < word.length; i++) {
      if (highlight[i]) {
        lastHighlightedPosition = i;
      }
    }
    
    // Build the word display with appropriate highlighting
    List<Widget> letterWidgets = [];
    
    for (int i = 0; i < word.length; i++) {
      String letter = word[i];
      bool isConsonant = LetterNumberMap.isConsonantInMap(letter.toUpperCase());
      bool isHighlighted = highlight[i];
      
      // Determine color:
      // - Blue for highlighted consonants (matching the pattern)
      // - Black for consonants in the pattern that aren't highlighted
      // - Gray for everything else (vowels and trailing consonants)
      Color letterColor;
      if (isHighlighted) {
        letterColor = Colors.blue;
      } else if (isConsonant && i <= lastHighlightedPosition) {
        letterColor = Colors.black;
      } else {
        letterColor = Colors.grey;
      }
      
      letterWidgets.add(
        Text(
          letter,
          style: TextStyle(
            fontSize: 24, 
            fontWeight: isConsonant ? FontWeight.bold : FontWeight.normal,
            color: letterColor,
          ),
        )
      );
    }
    
    return Wrap(children: letterWidgets);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Encode Number'),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Enter Number',
                      hintText: 'e.g. 12345',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: _processInput,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: _numberInput.isEmpty
                      ? const Center(
                          child: Text(
                            'Enter a number to find matching words',
                            style: TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : _segmentedResults.isEmpty
                        ? const Center(
                            child: Text(
                              'No matches found for your input',
                              style: TextStyle(fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : ListView.separated(
                          itemCount: _segmentedResults.length,
                          separatorBuilder: (_, __) => const Divider(height: 24),
                          itemBuilder: (context, index) {
                            final segmentation = _segmentedResults[index];
                            // Build the split label, e.g. "12 | 345"
                            final splitLabel = segmentation
                                .map((e) => e.key)
                                .join(' | ');

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  splitLabel,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ...segmentation.map((entry) {
                                  final pattern = entry.key;
                                  final matches = entry.value;
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16.0, bottom: 8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          pattern,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Wrap(
                                          spacing: 16.0,
                                          runSpacing: 12.0,
                                          children: matches
                                              .map((word) =>
                                                  _buildHighlightedWord(
                                                      word, pattern))
                                              .toList(),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            );
                          },
                        ),
                  ),
                ],
              ),
            ),
    );
  }
}