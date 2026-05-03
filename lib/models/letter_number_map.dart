class LetterNumberMap {
  static const Map<String, int> letterToNumber = {
    'B': 8,
    'C': 6,
    'D': 0,
    'F': 6,
    'G': 6,
    'H': 8,
    'J': 9,
    'K': 4,
    'L': 1,
    'M': 3,
    'N': 2,
    'P': 9,
    'Q': 0,
    'R': 4,
    'S': 5,
    'T': 7,
    'V': 1,
    'W': 3,
    'X': 0,
    'Z': 2,
  };

  // Check if a letter is a consonant in our mapping
  static bool isConsonantInMap(String letter) {
    return letterToNumber.containsKey(letter.toUpperCase());
  }

  static bool isVowel(String letter) {
    final vowels = ['A', 'E', 'I', 'O', 'U'];
    return vowels.contains(letter.toUpperCase());
  }
  
  
  static int? getNumber(String letter) {
    return letterToNumber[letter.toUpperCase()];
  }

  static List<String> getAllConsonants() {
    return letterToNumber.keys.toList();
  }

  static List<String> getLettersForNumber(int number) {
    List<String> letters = [];
    
    letterToNumber.forEach((key, value) {
      if (value == number) {
        letters.add(key);
      }
    });
    
    return letters;
  }

  static String numberToString(int number) {
    return getLettersForNumber(number).join(', ');
  }
}