import 'package:flutter/services.dart' show rootBundle;

class LetterListService {
  static final LetterListService _instance = LetterListService._internal();
  factory LetterListService() => _instance;

  Set<String> _words = {};
  LetterListService._internal();

  Future<void> loadWords() async {
    final dataWord =
        await rootBundle.loadString('lib/assets/turkce_kelime_listesi.txt');

    _words = dataWord
        .split(RegExp(r'\r?\n'))
        .map((e) => turkceToLower(e.replaceAll('\uFEFF', '').trim()))
        .where((e) => e.isNotEmpty)
        .toSet();

    print("---Kelimeler yüklendi. Toplam: ${_words.length}");
  }

  bool isWord(String word) {
    final kelime = turkceToLower(word);
    return _words.contains(kelime);
  }

  String turkceToLower(String input) {
    return input
        .replaceAll('I', 'ı')
        .replaceAll('İ', 'i')
        .replaceAll('Ç', 'ç')
        .replaceAll('Ğ', 'ğ')
        .replaceAll('Ö', 'ö')
        .replaceAll('Ş', 'ş')
        .replaceAll('Ü', 'ü')
        .toLowerCase();
  }
}
