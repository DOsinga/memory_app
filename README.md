# Memory App

A Flutter app for practicing the **Major System** — a mnemonic technique that lets you convert numbers into memorable words by mapping each digit to a set of consonant sounds.

## The Major System

The idea is simple: each digit 0-9 maps to specific consonants. Vowels don't count. So any number can be turned into a word (or a few words), which is far easier to remember than a string of digits.

| Digit | Consonants |
|-------|------------|
| 0     | D, Q, X    |
| 1     | L, V       |
| 2     | N, Z       |
| 3     | M, W       |
| 4     | R, K       |
| 5     | S          |
| 6     | C, F, G    |
| 7     | T          |
| 8     | B, H       |
| 9     | J, P       |

For example, **3535** encodes as **"museums"** (M=3, S=5, M=3, S=5 — the vowels "u", "e", "u" are ignored).

## Features

- **Practice mode** — Quiz yourself on consonant-to-number mappings until they're automatic
- **Encode mode** — Type a number and get word suggestions. The app automatically finds all ways to split the number into segments and shows matching words for each, ranked by frequency. Fewer words = easier to remember, so those appear first.
- **Reference chart** — Quick-access table of all digit-consonant mappings

The encode mode uses a word frequency database of 333K English words, so the suggestions you get are real, common words rather than obscure ones.

## Building

```bash
flutter pub get
flutter run
```

Targets Android, iOS, web, macOS, Linux, and Windows.
