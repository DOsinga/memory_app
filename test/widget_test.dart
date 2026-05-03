import 'package:flutter_test/flutter_test.dart';
import 'package:memory_app/models/letter_number_map.dart';
import 'package:memory_app/services/word_service.dart';

void main() {
  group('LetterNumberMap', () {
    test('maps consonants to correct numbers', () {
      expect(LetterNumberMap.getNumber('B'), 8);
      expect(LetterNumberMap.getNumber('S'), 5);
      expect(LetterNumberMap.getNumber('T'), 7);
      expect(LetterNumberMap.getNumber('M'), 3);
    });

    test('is case-insensitive', () {
      expect(LetterNumberMap.getNumber('b'), 8);
      expect(LetterNumberMap.getNumber('s'), 5);
    });

    test('returns null for vowels', () {
      expect(LetterNumberMap.getNumber('A'), isNull);
      expect(LetterNumberMap.getNumber('E'), isNull);
    });

    test('identifies consonants in map', () {
      expect(LetterNumberMap.isConsonantInMap('B'), isTrue);
      expect(LetterNumberMap.isConsonantInMap('A'), isFalse);
    });

    test('gets letters for a given number', () {
      final letters = LetterNumberMap.getLettersForNumber(8);
      expect(letters, containsAll(['B', 'H']));
    });
  });

  group('WordService.getConsonantPattern', () {
    final service = WordService();

    test('extracts consonant pattern from a word', () {
      // "museums" -> M(3) S(5) M(3) S(5)
      expect(service.getConsonantPattern('museums'), '3535');
    });

    test('ignores vowels', () {
      // "ate" -> T(7)
      expect(service.getConsonantPattern('ate'), '7');
    });

    test('handles all-vowel words', () {
      expect(service.getConsonantPattern('aeiou'), '');
    });

    test('is case-insensitive', () {
      expect(service.getConsonantPattern('Museum'), service.getConsonantPattern('museum'));
    });
  });
}
