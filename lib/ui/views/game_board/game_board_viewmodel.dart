import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:stacked/stacked.dart';
import 'package:yazlab2proje2kelimeoyunumobil/app/app.locator.dart';
import 'package:yazlab2proje2kelimeoyunumobil/services/game_service.dart';
import '../../../services/user_service.dart';

class Cell {
  String letter;
  final int bonusCode; // 0 = yok, 1 = H2, 2 = H3, 3 = K2, 4 = K3, 5 = ★
  final bool hasMine;
  final bool hasReward;

  Cell({
    this.letter = '',
    required this.bonusCode,
    this.hasMine = false,
    this.hasReward = false,
  });
}

class GameBoardViewModel extends BaseViewModel {
  final _userService = locator<UserService>();
  final _gameService = locator<GameService>();

  final int boardSize = 15;
  late List<List<Cell>> board;
  List<int> usedLetterIndexes = [];
  List<Map<String, dynamic>> letterObjects = [];
  List<String> letters = [];

  final Map<String, int> letterPoints = {
    'A': 1,
    'B': 3,
    'C': 4,
    'Ç': 4,
    'D': 3,
    'E': 1,
    'F': 7,
    'G': 5,
    'Ğ': 8,
    'H': 5,
    'I': 2,
    'İ': 1,
    'J': 10,
    'K': 1,
    'L': 1,
    'M': 2,
    'N': 1,
    'O': 2,
    'Ö': 7,
    'P': 5,
    'R': 1,
    'S': 2,
    'Ş': 4,
    'T': 1,
    'U': 2,
    'Ü': 3,
    'V': 7,
    'Y': 3,
    'Z': 4,
    'JOKER': 0
  };

  final List<List<int>> bonusMatrix = [
    [0, 0, 5, 0, 0, 2, 0, 0, 0, 2, 0, 0, 5, 0, 0],
    [0, 3, 0, 0, 0, 0, 2, 0, 2, 0, 0, 0, 0, 3, 0],
    [5, 0, 0, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 5],
    [0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 4, 0, 0, 0],
    [0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0],
    [2, 0, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 0, 2],
    [0, 2, 0, 0, 0, 0, 2, 0, 2, 0, 0, 0, 0, 2, 0],
    [0, 0, 4, 0, 0, 0, 0, 1, 0, 0, 0, 0, 4, 0, 0],
    [0, 2, 0, 0, 0, 0, 2, 0, 2, 0, 0, 0, 0, 2, 0],
    [2, 0, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 0, 2],
    [0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0],
    [0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 4, 0, 0, 0],
    [5, 0, 0, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 5],
    [0, 3, 0, 0, 0, 0, 2, 0, 2, 0, 0, 0, 0, 3, 0],
    [0, 0, 5, 0, 0, 2, 0, 0, 0, 2, 0, 0, 5, 0, 0],
  ];

  void initializeBoard() {
    board = List.generate(boardSize, (row) {
      return List.generate(boardSize, (col) {
        return Cell(bonusCode: bonusMatrix[row][col]);
      });
    });
  }

  void placeLetter(int row, int col, String letter) {
    board[row][col].letter = letter;
    notifyListeners();
  }

  String intToBonusText(int code) {
    switch (code) {
      case 1:
        return '★';
      case 2:
        return 'H²';
      case 3:
        return 'H³';
      case 4:
        return 'K²';
      case 5:
        return 'K³';
      default:
        return '';
    }
  }

  Color intToBonusColor(int code) {
    switch (code) {
      case 1:
        return const Color(0xFFFFECB3);
      case 2:
        return const Color(0xFFD6EAF8);
      case 3:
        return const Color(0xFFFADADD);
      case 4:
        return const Color(0xFFD5F5E3);
      case 5:
        return const Color(0xFFD7CCC8);
      default:
        return const Color.fromARGB(255, 255, 255, 255);
    }
  }

  int getLetterPoint(String letter) {
    return letterPoints[letter.toUpperCase()] ?? 0;
  }

  void resetUsedLetters() {
    usedLetterIndexes.clear();
    notifyListeners();
  }

  Future<void> fetchGamerLetters() async {
    final gameId = _gameService.gameId;
    final userId = _userService.userId;

    try {
      final url = Uri.parse(
          'http://192.168.1.178:7109/api/Game/oyuncu-harfleri-getir?gameID=$gameId&userID=$userId');
      final response = await http.get(url);
      debugPrint("Api cevap -> ${response.body}");

      if (response.statusCode == 200) {
        final letterData = jsonDecode(response.body) as List<dynamic>;
        letters = letterData.map((e) => e['character'] as String).toList();
        letterObjects = letterData
            .map((e) => {
                  'letterId': e['letterID'],
                  'character': e['character'],
                  'score': e['score'],
                })
            .toList();

        debugPrint("Gelen harfler-> ${letters.join(", ")}");

        notifyListeners();
      } else {
        debugPrint("Harfler veritabanından çekilemedi: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Harf çekme istisnası: $e");
    }
  }

  String? get userName => _userService.userName;
  String get gamer1Name => _gameService.gamer1Name ?? "Sen";
  String get gamer2Name => _gameService.gamer2Name ?? "Rakip";
  int get gamer1Score => _gameService.gamer1Score;
  int get gamer2Score => _gameService.gamer2Score;
  int? get gamer1Id => _gameService.gamer1Id;
  int? get gamer2Id => _gameService.gamer2Id;

  bool get isGamer1 => userName == gamer1Name;
  String get usersName => isGamer1 ? gamer1Name : gamer2Name;
  String get rivalName => isGamer1 ? gamer2Name : gamer1Name;
  int get usersScore => isGamer1 ? gamer1Score : gamer2Score;
  int get rivalScore => isGamer1 ? gamer2Score : gamer1Score;
}
