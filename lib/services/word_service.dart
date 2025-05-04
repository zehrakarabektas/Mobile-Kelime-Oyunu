import 'dart:convert';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:yazlab2proje2kelimeoyunumobil/services/letter_list_service.dart';
import '../ui/views/game_board/game_board_viewmodel.dart';

class WordService {
  Future<bool> sendWord(Map<String, dynamic> payload) async {
    final url = Uri.parse("http://192.168.1.178:7109/api/Game/kelime-gonder");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      return true;
    }
    if (response.statusCode != 200) {
      throw Exception(
          "Kelime gönderilemedi: ${response.statusCode} - ${response.reasonPhrase} - ${response.body}");
    } else {
      throw Exception("Kelime gönderilemedi: ${response.body}");
    }
  }

  String getUserFullWord(
      List<UserPlayLetter> placedLetters, List<List<Cell>> board) {
    if (placedLetters.isEmpty) return "";

    if (placedLetters.length == 1) {
      final int row = placedLetters[0].row;
      final int col = placedLetters[0].col;

      int sol = col, sag = col;
      while (sol > 0 && board[row][sol - 1].letter.isNotEmpty) {
        sol--;
      }
      while (sag < 14 && board[row][sag + 1].letter.isNotEmpty) {
        sag++;
      }
      if (sag - sol >= 1) {
        return List.generate(sag - sol + 1, (i) => board[row][sol + i].letter)
            .join();
      }

      int yukari = row, asagi = row;
      while (yukari > 0 && board[yukari - 1][col].letter.isNotEmpty) {
        yukari--;
      }
      while (asagi < 14 && board[asagi + 1][col].letter.isNotEmpty) {
        asagi++;
      }

      if (asagi - yukari >= 1) {
        return List.generate(
            asagi - yukari + 1, (i) => board[yukari + i][col].letter).join();
      }

      int caprazRow = row;
      int caprazCol = col;

      while (caprazRow > 0 &&
          caprazCol > 0 &&
          board[caprazRow - 1][caprazCol - 1].letter.isNotEmpty) {
        caprazRow--;
        caprazCol--;
      }

      List<String> diagLetters = [];
      int length = 0;

      while (caprazRow <= 14 &&
          caprazCol <= 14 &&
          board[caprazRow][caprazCol].letter.isNotEmpty) {
        diagLetters.add(board[caprazRow][caprazCol].letter);
        caprazRow++;
        caprazCol++;
        length++;
      }

      if (length > 1) {
        return diagLetters.join();
      }

      return placedLetters[0].letter;
    }
    bool x = placedLetters.every((e) => e.row == placedLetters[0].row);
    bool y = placedLetters.every((e) => e.col == placedLetters[0].col);
    bool z = placedLetters.every((e) =>
        (e.row - e.col) == (placedLetters[0].row - placedLetters[0].col));

    if (!x && !y && !z) return "";

    List<String> wordLetters = [];

    if (x) {
      int row = placedLetters[0].row;
      int basIndex =
          placedLetters.map((e) => e.col).reduce((a, b) => a < b ? a : b);
      int sonIndex =
          placedLetters.map((e) => e.col).reduce((a, b) => a > b ? a : b);

      while (basIndex > 0 && board[row][basIndex - 1].letter.isNotEmpty)
        basIndex--;
      while (sonIndex < 14 && board[row][sonIndex + 1].letter.isNotEmpty)
        sonIndex++;

      for (int c = basIndex; c <= sonIndex; c++) {
        wordLetters.add(board[row][c].letter);
      }
    } else if (y) {
      int col = placedLetters[0].col;
      int basIndex =
          placedLetters.map((e) => e.row).reduce((a, b) => a < b ? a : b);
      int sonIndex =
          placedLetters.map((e) => e.row).reduce((a, b) => a > b ? a : b);

      while (basIndex > 0 && board[basIndex - 1][col].letter.isNotEmpty)
        basIndex--;
      while (sonIndex < 14 && board[sonIndex + 1][col].letter.isNotEmpty)
        sonIndex++;

      for (int r = basIndex; r <= sonIndex; r++) {
        wordLetters.add(board[r][col].letter);
      }
    } else if (z) {
      int basSatir = placedLetters[0].row;
      int basSutun = placedLetters[0].col;

      while (basSatir > 0 &&
          basSutun > 0 &&
          board[basSatir - 1][basSutun - 1].letter.isNotEmpty) {
        basSatir--;
        basSutun--;
      }

      while (basSatir <= 13 &&
          basSutun <= 13 &&
          board[basSatir][basSutun].letter.isNotEmpty) {
        wordLetters.add(board[basSatir][basSutun].letter);
        basSatir++;
        basSutun++;
      }
    }

    return wordLetters.join();
  }

  bool WorddeBoslukVarMi(
      List<UserPlayLetter> placedLetters, List<List<Cell>> board) {
    if (placedLetters.isEmpty) return false;

    bool x = placedLetters.every((e) => e.row == placedLetters[0].row);
    bool y = placedLetters.every((e) => e.col == placedLetters[0].col);
    bool z = placedLetters.every((e) =>
        (e.row - e.col) == (placedLetters[0].row - placedLetters[0].col));

    if (!x && !y && !z) return false;

    List<int> indexes = placedLetters.map((e) => x ? e.col : e.row).toList();
    indexes.sort();

    if (x) {
      int row = placedLetters[0].row;
      List<int> cols = placedLetters.map((e) => e.col).toList()..sort();
      for (int i = cols.first; i <= cols.last; i++) {
        if (board[row][i].letter.isEmpty) return false;
      }
    } else if (y) {
      int col = placedLetters[0].col;
      List<int> rows = placedLetters.map((e) => e.row).toList()..sort();
      for (int i = rows.first; i <= rows.last; i++) {
        if (board[i][col].letter.isEmpty) return false;
      }
    } else if (z) {
      List<int> rows = placedLetters.map((e) => e.row).toList()..sort();
      int startRow = rows.first;
      int endRow = rows.last;
      int startCol = startRow - (placedLetters[0].row - placedLetters[0].col);

      for (int i = 0; i <= (endRow - startRow); i++) {
        if (board[startRow + i][startCol + i].letter.isEmpty) return false;
      }
    }
    return true;
  }

  bool WordListedeVarMi(String word) {
    word.toLowerCase();
    return word.length >= 1 && LetterListService().isWord(word);
  }

  int fullWordScore({
    required List<UserPlayLetter> placedLetters,
    required List<List<Cell>> board,
    required Map<String, int> letterPoints,
  }) {
    final word = getUserFullWord(placedLetters, board);
    if (word.isEmpty) return 0;

    return word
        .split('')
        .map((c) => letterPoints[c.toUpperCase()] ?? 0)
        .reduce((a, b) => a + b);
  }

  int fullWordBonusScore({
    required List<UserPlayLetter> placedLetters,
    required List<List<Cell>> board,
    required List<List<int>> bonusMatrix,
    required Map<String, int> letterPoints,
  }) {
    if (placedLetters.isEmpty) return 0;

    final word = getUserFullWord(placedLetters, board);
    if (word.isEmpty) return 0;

    bool isRow = placedLetters.every((e) => e.row == placedLetters[0].row);
    bool isCol = placedLetters.every((e) => e.col == placedLetters[0].col);
    bool isDiag = placedLetters.every((e) =>
        (e.row - e.col) == (placedLetters[0].row - placedLetters[0].col));

    if (!isRow && !isCol && !isDiag) return 0;

    int totalScore = 0;
    int wordMultiplier = 1;

    if (isRow) {
      int row = placedLetters[0].row;

      int startCol =
          placedLetters.map((e) => e.col).reduce((a, b) => a < b ? a : b);
      int endCol =
          placedLetters.map((e) => e.col).reduce((a, b) => a > b ? a : b);

      while (startCol > 0 && board[row][startCol - 1].letter.isNotEmpty)
        startCol--;
      while (endCol < 14 && board[row][endCol + 1].letter.isNotEmpty) endCol++;

      for (int col = startCol; col <= endCol; col++) {
        final cell = board[row][col];
        final isNew = placedLetters.any((p) => p.row == row && p.col == col);
        final letter = cell.letter;
        int score = letterPoints[letter.toUpperCase()] ?? 0;

        if (isNew) {
          final bonus = bonusMatrix[row][col];
          if (bonus == 2) score *= 2;
          if (bonus == 3) score *= 3;
          if (bonus == 4) wordMultiplier *= 2;
          if (bonus == 5) wordMultiplier *= 3;
        }

        totalScore += score;
      }
    } else if (isCol) {
      int col = placedLetters[0].col;

      int startRow =
          placedLetters.map((e) => e.row).reduce((a, b) => a < b ? a : b);
      int endRow =
          placedLetters.map((e) => e.row).reduce((a, b) => a > b ? a : b);

      while (startRow > 0 && board[startRow - 1][col].letter.isNotEmpty)
        startRow--;
      while (endRow < 14 && board[endRow + 1][col].letter.isNotEmpty) endRow++;

      for (int row = startRow; row <= endRow; row++) {
        final cell = board[row][col];
        final isNew = placedLetters.any((p) => p.row == row && p.col == col);
        final letter = cell.letter;
        int score = letterPoints[letter.toUpperCase()] ?? 0;

        if (isNew) {
          final bonus = bonusMatrix[row][col];
          if (bonus == 2) score *= 2;
          if (bonus == 3) score *= 3;
          if (bonus == 4) wordMultiplier *= 2;
          if (bonus == 5) wordMultiplier *= 3;
        }

        totalScore += score;
      }
    } else if (isDiag) {
      int minRow =
          placedLetters.map((e) => e.row).reduce((a, b) => a < b ? a : b);
      int minCol =
          placedLetters.map((e) => e.col).reduce((a, b) => a < b ? a : b);
      int maxRow =
          placedLetters.map((e) => e.row).reduce((a, b) => a > b ? a : b);
      int maxCol =
          placedLetters.map((e) => e.col).reduce((a, b) => a > b ? a : b);

      while (minRow > 0 &&
          minCol > 0 &&
          board[minRow - 1][minCol - 1].letter.isNotEmpty) {
        minRow--;
        minCol--;
      }

      while (maxRow < 14 &&
          maxCol < 14 &&
          board[maxRow + 1][maxCol + 1].letter.isNotEmpty) {
        maxRow++;
        maxCol++;
      }

      for (int i = 0; i <= maxRow - minRow; i++) {
        int row = minRow + i;
        int col = minCol + i;
        final cell = board[row][col];
        final isNew = placedLetters.any((p) => p.row == row && p.col == col);
        final letter = cell.letter;
        int score = letterPoints[letter.toUpperCase()] ?? 0;

        if (isNew) {
          final bonus = bonusMatrix[row][col];
          if (bonus == 2) score *= 2;
          if (bonus == 3) score *= 3;
          if (bonus == 4) wordMultiplier *= 2;
          if (bonus == 5) wordMultiplier *= 3;
        }

        totalScore += score;
      }
    }

    return totalScore * wordMultiplier;
  }

  bool isFirstWord(List<dynamic> gameCell) => gameCell.isEmpty;

  bool isMiddleCell(List<dynamic> gameCell, List<Offset> placedLetterCell) {
    if (isFirstWord(gameCell)) {
      return placedLetterCell.any((x) => x.dx == 7 && x.dy == 7);
    }
    return true;
  }

  bool isCorrectPlaced(
      List<Offset> placeLetterCell, List<List<Cell>> gameBoard) {
    for (var cell in placeLetterCell) {
      int row = cell.dy.toInt();
      int col = cell.dx.toInt();

      final ways = [
        const Offset(0, -1),
        const Offset(-1, 0),
        const Offset(1, 0),
        const Offset(0, 1),
        const Offset(1, 1),
      ];

      for (var w in ways) {
        int cellRow = row + w.dy.toInt();
        int cellCol = col + w.dx.toInt();

        if (cellRow < 0 ||
            cellRow >= gameBoard.length ||
            cellCol >= gameBoard[0].length ||
            cellCol < 0) {
          continue;
        }

        final neighbor = gameBoard[cellRow][cellCol];
        if (neighbor.letter.isNotEmpty &&
            !placeLetterCell
                .contains(Offset(cellCol.toDouble(), cellRow.toDouble()))) {
          return true;
        }
      }
    }
    return false;
  }

  Future<bool> updateJokerLetter(Map<String, dynamic> data) async {
    debugPrint(jsonEncode(data));
    final response = await http.post(
      Uri.parse('http://192.168.1.178:7109/api/Game/jokerHarfi-guncelle'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    debugPrint("Status Code: ${response.statusCode}");

    return response.statusCode == 200;
  }

  List<Map<String, dynamic>> getNeighWords(
    List<UserPlayLetter> placedLetters,
    List<List<Cell>> board,
    String mainWord,
    Map<String, int> letterPoints,
  ) {
    Set<String> addedWords = {};
    List<Map<String, dynamic>> neighborWords = [];

    for (var placed in placedLetters) {
      int row = placed.row;
      int col = placed.col;

      int sol = col, sag = col;
      while (sol > 0 && board[row][sol - 1].letter.isNotEmpty) {
        sol--;
      }
      while (sag < 14 && board[row][sag + 1].letter.isNotEmpty) {
        sag++;
      }

      if (sag - sol >= 1) {
        String word = "";
        int score = 0;
        for (int i = sol; i <= sag; i++) {
          final ch = (row == placed.row && i == placed.col)
              ? placed.letter
              : board[row][i].letter;
          word += ch;
          score += letterPoints[ch.toUpperCase()] ?? 0;
        }
        if (word.length > 1 && word != mainWord && !addedWords.contains(word)) {
          addedWords.add(word);
          neighborWords.add({"word": word, "score": score});
        }
      }

      int yukari = row, asagi = row;
      while (yukari > 0 && board[yukari - 1][col].letter.isNotEmpty) {
        yukari--;
      }
      while (asagi < 14 && board[asagi + 1][col].letter.isNotEmpty) {
        asagi++;
      }

      if (asagi - yukari >= 1) {
        String word = "";
        int score = 0;
        for (int i = yukari; i <= asagi; i++) {
          final ch = (i == placed.row) ? placed.letter : board[i][col].letter;
          word += ch;
          score += letterPoints[ch.toUpperCase()] ?? 0;
        }
        if (word.length > 1 && word != mainWord && !addedWords.contains(word)) {
          addedWords.add(word);
          neighborWords.add({"word": word, "score": score});
        }
      }
    }

    return neighborWords;
  }
}
