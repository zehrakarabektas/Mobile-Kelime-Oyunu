import 'package:flutter/services.dart' show rootBundle;

class LetterListService{
  static final LetterListService _instance=LetterListService._internal();
  factory LetterListService()=> _instance;

  Set<String> _words={};
  LetterListService._internal();

  Future<void> loadWords() async{
    final dataWord=await rootBundle.loadString('lib/assets/turkce_kelime_listesi.txt');
    _words=dataWord.split('\n').map((e)=>e.trim().toLowerCase()).toSet();
    print("Kelimeler textten çekildi.Kelime sayisi :${_words.length}");

  }
  bool isWord(String word){
    return _words.contains(word.toLowerCase());
  }
}
