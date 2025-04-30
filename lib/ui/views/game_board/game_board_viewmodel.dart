import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:stacked/stacked.dart';
import 'package:yazlab2proje2kelimeoyunumobil/app/app.locator.dart';
import 'package:yazlab2proje2kelimeoyunumobil/services/game_service.dart';
import '../../../services/user_service.dart';
import 'package:signalr_netcore/signalr_client.dart';

class Cell {
  int? letterId;
  String letter;
  int score;
  final int bonusCode; 
  final bool hasMine;
  final bool hasReward;
  int row;
  int col;

  Cell({
    this.letterId,
    this.letter = '',
    this.score = 0,
    required this.bonusCode,
    this.hasMine = false,
    this.hasReward = false,
    required this.row,
    required this.col,
  });
}

class GameBoardViewModel extends BaseViewModel {
  final _userService = locator<UserService>();
  final _gameService = locator<GameService>();
  late HubConnection _hubConnect;

  Future<void> initSignalR() async {
    _hubConnect = HubConnectionBuilder()
        .withUrl('http://192.168.1.178:7109/wordgamehub')
        .build();

    _hubConnect.on("DataChanged", (args) async {
      debugPrint("SignalR DataChanged event geldi!");
      await fetchGameData();
      notifyListeners();
    });

    _hubConnect.on("TurnPassed", (args) async {
      debugPrint("SignalR TurnPassed event geldi!");
      await fetchGameData();
      notifyListeners();
    });

    await _hubConnect.start();
  }

  Future<void> fetchGameData() async {
    final gameId = _gameService.gameId;
    try {
      final urlGameInfo =
          Uri.parse('http://192.168.1.178:7109/api/Game/game/$gameId');
      final responseGameInfo = await http.get(urlGameInfo);
      debugPrint("Api gelen oyun bilgisi:${responseGameInfo.body}");
      if (responseGameInfo.statusCode == 200) {
        final gameData = jsonDecode(responseGameInfo.body);

        debugPrint("Decode oyun bilgisi:$gameData");
        _gameService.setGame(
          gameId: gameData['gameId'].toString(),
          gamer1Id: gameData['gamer1Id'],
          gamer2Id: gameData['gamer2Id'],
          gamer1Name: gameData['gamer1Name'],
          gamer2Name: gameData['gamer2Name'],
          turnGamerId: gameData['turnGamerId'],
          gameSeconds: gameData['gameSeconds'] ?? 0,
          gamer1Score: gameData['gamer1Score'] ?? 0,
          gamer2Score: gameData['gamer2Score'] ?? 0,
          gamer1PassCount: gameData['gamer1PassCount'] ?? 0,
          gamer2PassCount: gameData['gamer2PassCount'] ?? 0,
          gameLetterCount: gameData['gameLetterCount'] ?? 0,
          startTime:
              DateTime.tryParse(gameData['startTime'] ?? "") ?? DateTime.now(),
          lastMoveTime: DateTime.tryParse(gameData['lastMoveTime'] ?? "") ??
              DateTime.now(),
          winnerGamerId: gameData['winnerGamerId'],
          isDraw: gameData['isDraw'] ?? false,
        );
      }

      await fetchGamerLetters();
    } catch (e) {
      debugPrint("fetchGameData hatası: $e");
    }
  }

  final int boardSize = 15;
  late List<List<Cell>> board;
  List<int> usedLetterIndexes = [];
  List<Map<String, dynamic>> letterObjects = [];
  List<int?> letterSlot = [];
  List<Offset> placeLetterList = [];

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
        return Cell(
          bonusCode: bonusMatrix[row][col],
          row: row,
          col: col,
        );
      });
    });
  }

  void placeLetter(int row, int col, String letter, int score, int letterId) {
    board[row][col].letter = letter;
    board[row][col].score = score;
    board[row][col].letterId = letterId;

    if (!usedLetterIndexes.contains(letterId)) {
      usedLetterIndexes.add(letterId);
    }
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
        letterObjects = letterData
            .map((e) => {
                  'letterId': e['letterID'],
                  'character': e['character'],
                  'score': e['score'],
                })
            .toList();
        letterSlot = List<int?>.generate(
            letterObjects.length, (index) => letterObjects[index]['letterId']);

        notifyListeners();
      } else {
        debugPrint("Harfler veritabanından çekilemedi: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Harf çekme istisnası: $e");
    }
  }

  Future<void> userPassTurn() async {
    final userId = _userService.userId;
    final gameId = _gameService.gameId;

    final url = Uri.parse('http://192.168.1.178:7109/api/GameButton/pas-gec');

    setBusy(true);

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "gameID": int.parse(gameId!),
          "userID": userId,
        }),
      );
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        debugPrint("Pas geçildi: ${responseData['message']}");
      } else if (response.statusCode == 400) {
        final error = response.body;
        debugPrint("Pas geçilemedi: $error");
      } else {
        debugPrint("Beklenmeyen hata: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Hata oluştu: $e");
    } finally {
      setBusy(false);
    }
  }

  Future<void> userSurrender() async {
    final userId = _userService.userId;
    final gameId = _gameService.gameId;

    final url = Uri.parse('http://192.168.1.178:7109/api/GameButton/teslim-ol');
    setBusy(true);
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "gameID": int.parse(gameId!),
          "userID": userId,
        }),
      );
      if (response.statusCode == 200) {
        debugPrint("Teslim olundu.");
      } else {
        debugPrint("Teslim olunamadı: ${response.body}");
      }
    } catch (e) {
      debugPrint("Hata oluştu: $e");
    } finally {
      setBusy(false);
    }
  }

  String? get userName => _userService.userName;
  String get gamer1Name => _gameService.gamer1Name ?? "Sen";
  String get gamer2Name => _gameService.gamer2Name ?? "Rakip";
  int get gamer1Score => _gameService.gamer1Score;
  int get gamer2Score => _gameService.gamer2Score;
  int? get gamer1Id => _gameService.gamer1Id;
  int? get gamer2Id => _gameService.gamer2Id;
  int? get gameLetterCount => _gameService.gameLetterCount;

  bool get isGamer1 => userName == gamer1Name;
  String get usersName => isGamer1 ? gamer1Name : gamer2Name;
  String get rivalName => isGamer1 ? gamer2Name : gamer1Name;
  int get usersScore => isGamer1 ? gamer1Score : gamer2Score;
  int get rivalScore => isGamer1 ? gamer2Score : gamer1Score;
  int get usersPassCount =>
      isGamer1 ? _gameService.gamer1PassCount : _gameService.gamer2PassCount;
  String get leftTimeString => _gameService.leftTimeString;

  //Timer? _timer;

  /*void startTimer() {
  /  _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      print("🔄 Timer tick - calling notifyListeners()");
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }*/
}
