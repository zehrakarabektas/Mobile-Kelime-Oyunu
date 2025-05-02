import 'dart:convert';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:yazlab2proje2kelimeoyunumobil/services/letter_list_service.dart';
import '../ui/views/game_board/game_board_viewmodel.dart';

class WordService {
  final _letterListService = LetterListService();
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

  String getFullWordFromBoard(
      List<UserPlayLetter> placedLetters, List<List<Cell>> board) {
    if (placedLetters.isEmpty) return "";

    bool isRow = placedLetters.every((e) => e.row == placedLetters[0].row);
    bool isCol = placedLetters.every((e) => e.col == placedLetters[0].col);
    if (!isRow && !isCol) return "";

    int fixed = isRow ? placedLetters[0].row : placedLetters[0].col;
    int start = placedLetters
        .map((e) => isRow ? e.col : e.row)
        .reduce((a, b) => a < b ? a : b);
    int end = placedLetters
        .map((e) => isRow ? e.col : e.row)
        .reduce((a, b) => a > b ? a : b);

    // Genişlet tahtadan: soldan/üstten başla, sağa/aşağı git
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

    String word = "";
    for (int i = start; i <= end; i++) {
      final cell = isRow ? board[fixed][i] : board[i][fixed];
      if (cell.letter.isEmpty) return "";
      word += cell.letter;
    }

    return word;
  }

  bool isContiguousWord(
      List<UserPlayLetter> placedLetters, List<List<Cell>> board) {
    if (placedLetters.isEmpty) return false;

    bool isRow = placedLetters.every((e) => e.row == placedLetters[0].row);
    bool isCol = placedLetters.every((e) => e.col == placedLetters[0].col);

    if (!isRow && !isCol) return false;

    int fixed = isRow ? placedLetters[0].row : placedLetters[0].col;
    List<int> indexes =
        placedLetters.map((e) => isRow ? e.col : e.row).toList();
    indexes.sort();

    int start = indexes.first;
    int end = indexes.last;

    for (int i = start; i <= end; i++) {
      final cell = isRow ? board[fixed][i] : board[i][fixed];
      if (cell.letter.isEmpty) {
        return false;
      }
    }

    return true;
  }

  String getGamerCreateWord(List<UserPlayLetter> placedLetters) {
    if (placedLetters.isEmpty) {
      return '';
    }
    bool isX = placedLetters.every((x) => x.row == placedLetters[0].row);
    bool isY = placedLetters.every((y) => y.col == placedLetters[0].col);

    bool isZ = true;
    final rowDiff = placedLetters[0].row - placedLetters[0].col;
    for (var e in placedLetters) {
      if (e.row - e.col != rowDiff) {
        isZ = false;
        break;
      }
    }
    if (!isX && !isY && !isZ) {
      return '';
    }
    List<UserPlayLetter> sorted = [...placedLetters];
    if (isX) {
      sorted.sort((a, b) => a.col.compareTo(b.col));
    } else if (isY) {
      sorted.sort((a, b) => a.row.compareTo(b.row));
    } else if (isZ) {
      sorted.sort((a, b) => a.col.compareTo(b.col));
    }

    return sorted.map((e) => e.letter).join();
  }

  bool isPlacedWordValid(String word) {
    return word.length >= 2 && _letterListService.isWord(word);
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
        const Offset(0, 1)
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
}
