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
    required List<List<int>> bonusMatrix,
    required Map<String, int> letterPoints,
  }) {
    if (placedLetters.isEmpty) return 0;

    bool isRow = placedLetters.every((e) => e.row == placedLetters[0].row);
    bool isCol = placedLetters.every((e) => e.col == placedLetters[0].col);
    if (!isRow && !isCol) return 0;

    int fixed = isRow ? placedLetters[0].row : placedLetters[0].col;
    int start = placedLetters
        .map((e) => isRow ? e.col : e.row)
        .reduce((a, b) => a < b ? a : b);
    int end = placedLetters
        .map((e) => isRow ? e.col : e.row)
        .reduce((a, b) => a > b ? a : b);

    while (start > 0 &&
        (isRow
            ? board[fixed][start - 1].letter.isNotEmpty
            : board[start - 1][fixed].letter.isNotEmpty)) {
      start--;
    }

    while (end < 14 &&
        (isRow
            ? board[fixed][end + 1].letter.isNotEmpty
            : board[end + 1][fixed].letter.isNotEmpty)) {
      end++;
    }

    int totalScore = 0;
    int wordMultiplier = 1;

    for (int i = start; i <= end; i++) {
      final cell = isRow ? board[fixed][i] : board[i][fixed];

      UserPlayLetter? placed;
      for (var p in placedLetters) {
        if (p.row == cell.row && p.col == cell.col) {
          placed = p;
          break;
        }
      }

      final letter = placed?.letter ?? cell.letter;
      final score = placed?.score ?? (letterPoints[letter.toUpperCase()] ?? 0);

      final bonus = bonusMatrix[cell.row][cell.col];
      int letterScore = score;

      if (placed != null) {
        if (bonus == 2) letterScore *= 2;
        if (bonus == 3) letterScore *= 3;
        if (bonus == 4) wordMultiplier *= 2;
        if (bonus == 5) wordMultiplier *= 3;
      }

      totalScore += letterScore;
    }

    return totalScore * wordMultiplier;
  }

  int gamerBonusScore(
      List<UserPlayLetter> placedLetters, List<List<int>> bonusMatrix) {
    int bonusScore = 0;
    int wordMux = 1;

    for (var letter in placedLetters) {
      final int row = letter.row;
      final int col = letter.col;
      final int bonus = bonusMatrix[row][col];

      int letterScore = letter.score;

      if (bonus == 2) {
        letterScore *= 2;
      } else if (bonus == 3) {
        letterScore *= 3;
      } else if (bonus == 4) {
        wordMux *= 2;
      } else if (bonus == 5) {
        wordMux *= 3;
      }
      bonusScore += letterScore;
    }
    return bonusScore * wordMux;
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
