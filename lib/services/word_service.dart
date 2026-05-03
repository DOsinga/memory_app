import 'dart:isolate';

import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/letter_number_map.dart';

// Maximum words to keep per pattern (top by frequency)
const int _maxWordsPerPattern = 10;

// Class to hold word with its frequency
class WordEntry {
  final String word;
  final int frequency;

  WordEntry(this.word, this.frequency);
}

// Result of background CSV processing (must be top-level for isolate)
class _ProcessedData {
  final Map<String, List<WordEntry>> patternToWords;

  _ProcessedData(this.patternToWords);
}

// Top-level function for isolate — parses CSV and builds the pattern index
_ProcessedData _processWordData(String rawCsv) {
  final wordRows = const CsvToListConverter().convert(rawCsv, eol: "\n");

  // Skip header row
  if (wordRows.isNotEmpty) {
    wordRows.removeAt(0);
  }

  final Map<String, List<WordEntry>> patternToWords = {};

  for (var row in wordRows) {
    if (row.length < 2) continue;
    String word = row[0].toString();
    int frequency = int.tryParse(row[1].toString()) ?? 0;

    String pattern = _getConsonantPattern(word);
    if (pattern.isEmpty) continue;

    if (!patternToWords.containsKey(pattern)) {
      patternToWords[pattern] = [];
    }
    patternToWords[pattern]!.add(WordEntry(word, frequency));
  }

  // Sort each word list by frequency and trim to top N
  patternToWords.forEach((pattern, words) {
    words.sort((a, b) => b.frequency.compareTo(a.frequency));
    if (words.length > _maxWordsPerPattern) {
      patternToWords[pattern] = words.sublist(0, _maxWordsPerPattern);
    }
  });

  return _ProcessedData(patternToWords);
}

// Standalone pattern extraction for use in the isolate
String _getConsonantPattern(String word) {
  String normalizedWord = word.toUpperCase();
  StringBuffer pattern = StringBuffer();

  for (int i = 0; i < normalizedWord.length; i++) {
    String letter = normalizedWord[i];
    if (LetterNumberMap.isConsonantInMap(letter)) {
      int? number = LetterNumberMap.getNumber(letter);
      if (number != null) {
        pattern.write(number.toString());
      }
    }
  }

  return pattern.toString();
}

class WordService extends ChangeNotifier {
  Map<String, List<WordEntry>> _patternToWords = {};

  bool _isLoaded = false;

  Future<void> loadWordList() async {
    if (_isLoaded) return;

    debugPrint('Loading word list from assets...');
    final rawData = await rootBundle.loadString('assets/unigram_freq.csv');

    // Parse and index on a background isolate
    final processed = await Isolate.run(() => _processWordData(rawData));

    _patternToWords = processed.patternToWords;

    _isLoaded = true;
    notifyListeners();

    debugPrint('Word processing complete. ${_patternToWords.length} unique patterns indexed.');
  }
  
  // Find words whose consonant pattern exactly matches the given digit string
  List<String> findWordsMatchingPattern(String pattern) {
    if (pattern.isEmpty || !_isLoaded) return [];

    final words = _patternToWords[pattern];
    if (words == null || words.isEmpty) return [];

    return words.take(5).map((e) => e.word).toList();
  }
  
  /// Given a digit string, find all valid ways to segment it into parts
  /// where each part has at least one matching word.
  /// Returns a list of segmentations, each being a list of digit-group strings.
  /// Results are sorted shortest-first (fewest segments = more memorable).
  List<List<String>> findSegmentations(String digits, {int maxResults = 10, int minSegmentLen = 2, int maxSegmentLen = 7}) {
    List<List<String>> results = [];
    _segmentHelper(digits, 0, [], results, maxResults, minSegmentLen, maxSegmentLen);
    // Sort by number of segments (fewer = better)
    results.sort((a, b) => a.length.compareTo(b.length));
    return results;
  }

  void _segmentHelper(String digits, int start, List<String> current,
      List<List<String>> results, int maxResults, int minSegmentLen, int maxSegmentLen) {
    if (results.length >= maxResults) return;
    if (start == digits.length) {
      results.add(List.from(current));
      return;
    }

    int remaining = digits.length - start;
    int maxLen = remaining < maxSegmentLen ? remaining : maxSegmentLen;

    for (int len = minSegmentLen; len <= maxLen; len++) {
      if (results.length >= maxResults) return;
      String segment = digits.substring(start, start + len);
      List<String> matches = findWordsMatchingPattern(segment);
      if (matches.isNotEmpty) {
        current.add(segment);
        _segmentHelper(digits, start + len, current, results, maxResults, minSegmentLen, maxSegmentLen);
        current.removeLast();
      }
    }
  }

  String getConsonantPattern(String word) => _getConsonantPattern(word);
}