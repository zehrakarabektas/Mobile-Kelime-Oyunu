import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

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
  final int boardSize = 15;
  late List<List<Cell>> board;
  List<int> usedLetterIndexes = [];
  List<String> letters = ['A', 'I', 'İ', 'L', 'T', 'R', 'N'];
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
}
