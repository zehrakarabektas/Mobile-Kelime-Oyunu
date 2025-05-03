import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:yazlab2proje2kelimeoyunumobil/app/app.router.dart';
import 'package:yazlab2proje2kelimeoyunumobil/app/app.locator.dart';
import 'package:yazlab2proje2kelimeoyunumobil/services/game_service.dart';
import '../../../services/user_service.dart';
import '../../../services/word_service.dart';
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

  bool isWord = false;
  bool isClosed = false;
  bool isLast = false;

  Cell({
    this.letterId,
    this.letter = '',
    this.score = 0,
    required this.bonusCode,
    this.hasMine = false,
    this.hasReward = false,
    this.isWord = false,
    this.isClosed = false,
    this.isLast = false,
    required this.row,
    required this.col,
  });
}

class UserPlayLetter {
  final int row;
  final int col;
  final String letter;
  final int score;
  final int letterId;

  UserPlayLetter({
    required this.row,
    required this.col,
    required this.letter,
    required this.score,
    required this.letterId,
  });
}

class GameBoardViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  //final _letterListService = LetterListService();
  final _userService = locator<UserService>();
  final _gameService = locator<GameService>();
  late HubConnection _hubConnect;

  Future<void> initSignalR() async {
    _hubConnect = HubConnectionBuilder()
        .withUrl('http://192.168.1.178:7109/wordgamehub')
        .withAutomaticReconnect()
        .build();

    _hubConnect.on("DataChanged", (args) async {
      debugPrint("SignalR DataChanged event geldi!");
      await fetchGameData();
      if (turnUserId == userId && _gameService.winnerGamerId == null) {
        startTimer();
      }
      notifyListeners();
    });

    _hubConnect.on("TurnPassed", (arguments) async {
      if (arguments == null || arguments.isEmpty) return;

      final data = arguments[0] as Map<String, dynamic>;
      final message = data['message'] ?? "Sıra değişti.";
      print(message);
      notifyListeners();
    });
    _hubConnect.on("GameSurrendered", (args) {
      if (args != null && args.isNotEmpty && args[0] is Map<String, dynamic>) {
        final data = args[0] as Map<String, dynamic>;
        final winnerId = data['winnerGamerId'] as int;

        handleGameSurrendered(winnerId);
      }
    });

    await _hubConnect.start();
  }

  Future<void> fetchGameData() async {
    final gameId = _gameService.gameId;
    try {
      final urlGameInfo = Uri.parse(
          'http://192.168.1.178:7109/api/Game/game/$gameId?ts=${DateTime.now().millisecondsSinceEpoch}');
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
          gameCell: gameData['gameCell'] ?? [],
          startTime:
              DateTime.tryParse(gameData['startTime'] ?? "") ?? DateTime.now(),
          lastMoveTime: DateTime.tryParse(gameData['lastMoveTime'] ?? "") ??
              DateTime.now(),
          serverNow:
              DateTime.tryParse(gameData['serverNow'] ?? "") ?? DateTime.now(),
          winnerGamerId: gameData['winnerGamerId'],
          isDraw: gameData['isDraw'] ?? false,
        );
      }
      initializeBoard();
      gamesLettersToBoard();
      await fetchGamerLetters();
      await fetchUserRewards();
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
  List<UserPlayLetter> placedLetters = [];

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
    if (board[row][col].isClosed) {
      debugPrint("❌ Bu hücre kilitli, harf yerleştirilemez.");
      return;
    }

    placedLetters.removeWhere((p) => p.row == row && p.col == col);

    board[row][col].letter = letter;
    board[row][col].score = score;
    board[row][col].letterId = letterId;

    if (!usedLetterIndexes.contains(letterId)) {
      usedLetterIndexes.add(letterId);
    }

    final offset = Offset(col.toDouble(), row.toDouble());
    if (!placeLetterList.contains(offset)) {
      placeLetterList.add(offset);
    }

    placedLetters.add(UserPlayLetter(
      row: row,
      col: col,
      letter: letter,
      score: score,
      letterId: letterId,
    ));
    updatePlacedLetterColors();
    /*final word = getUserCreateWord();
    final isValid = isPlacedWordValid();
    debugPrint("🧩 Yeni kelime: $word");
    debugPrint("✅ Geçerli mi: $isValid");*/

    for (var l in placedLetters) {
      debugPrint(
          "📍 Harf: ${l.letter} (${l.row}, ${l.col}) → Puan: ${l.score}, ID: ${l.letterId}");
    }

    notifyListeners();
  }

  void removeLetter(int row, int col) {
    final removedId = board[row][col].letterId;

    board[row][col].letter = '';
    board[row][col].score = 0;
    board[row][col].letterId = null;

    placedLetters.removeWhere((e) => e.row == row && e.col == col);
    placeLetterList
        .removeWhere((e) => e.dx == col.toDouble() && e.dy == row.toDouble());

    if (removedId != null) {
      usedLetterIndexes.remove(removedId);
    }

    debugPrint("❌ Harf silindi ($row, $col)");
    debugPrint("📍 Kalan harfler:");
    for (var l in placedLetters) {
      debugPrint("➡️ ${l.letter} at (${l.row}, ${l.col}) → ID: ${l.letterId}");
    }
    updatePlacedLetterColors();
    /*final word = getUserCreateWord();
    final isValid = isPlacedWordValid();
    debugPrint("🧩 Yeni kelime: $word");
    debugPrint("✅ Geçerli mi: $isValid");*/

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
    placedLetters.clear();
    placeLetterList.clear();
    usedLetterIndexes.clear();
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

  Future<void> fetchUserRewards() async {
    final gameId = _gameService.gameId;
    try {
      final rewards = await _gameService.getActiveRewards(gameId!, userId!);
      aktifOdulSay = {
        'ekstraHamle': rewards['EkstraHamleJokeri'] ?? 0,
        'bolgeYasagi': rewards['BolgeYasagi'] ?? 0,
        'harfYasagi': rewards['HarfYasagi'] ?? 0,
      };
      notifyListeners();
    } catch (e) {
      debugPrint("Ödüller alınamadı: $e");
    }
  }

  Future<void> userPassTurn() async {
    if (isSendWordGamer) {
      debugPrint("Kelime gönderilirken pas geçilemez.");
      return;
    }
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
    if (isSendWordGamer) {
      debugPrint("Kelime gönderilirken teslim geçilemez.");
      return;
    }
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

  void goToGameHome() {
    _navigationService.replaceWithGamehomeView();
  }

  int? get userId => _userService.userId;
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
  int? get turnUserId => _gameService.turnGamerId;
  Map<String, int> aktifOdulSay = {
    'ekstraHamle': 0,
    'bolgeYasagi': 0,
    'harfYasagi': 0,
  };

  Timer? _timer;

  void startTimer() {
    _timer?.cancel();
    debugPrint("🟢 Timer BAŞLATILIYOR: ${DateTime.now().toIso8601String()}");

    if (_gameService.leftTime.inSeconds <= 0) {
      return;
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_gameService.serverNow != null) {
        _gameService.serverNow =
            _gameService.serverNow!.add(const Duration(seconds: 1));
      }

      notifyListeners();

      if (_gameService.leftTime.inSeconds <= 0 &&
          isSendWordGamer != true &&
          turnUserId == userId) {
        _timer?.cancel();
        print("⏰ Süre doldu, timer durdu.");
        unawaited(finishGameTime());
        return;
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  final _wordService = WordService();
  bool isSendWordTrue = false;

  String getUserCreateWord() =>
      _wordService.getUserFullWord(placedLetters, board);
  bool isPlacedWordValid() =>
      _wordService.WordListedeVarMi(getUserCreateWord());
  int gamerBonusScore() =>
      _wordService.gamerBonusScore(placedLetters, bonusMatrix);
  int gamerFullWordScore() => _wordService.fullWordScore(
        placedLetters: placedLetters,
        board: board,
        bonusMatrix: bonusMatrix,
        letterPoints: letterPoints,
      );

  bool isFirstGamerMove() => _wordService.isFirstWord(_gameService.gameCell);
  bool isCorrectPlaced() =>
      _wordService.isCorrectPlaced(placeLetterList, board);

  void updatePlacedLetterColors() {
    for (var row in board) {
      for (var cell in row) {
        if (!cell.isClosed) {
          cell.isWord = false;
          cell.isLast = false;
        }
      }
    }

    final isMiddleOk =
        _wordService.isMiddleCell(_gameService.gameCell, placeLetterList);
    final isCorrect = isCorrectPlaced();
    final fullWord = _wordService.getUserFullWord(placedLetters, board);
    final isValid = _wordService.WordListedeVarMi(fullWord);
    final birlesik = _wordService.WorddeBoslukVarMi(placedLetters, board);
    final isFirstMove = isFirstGamerMove();

    print("🔍 Kelime: $fullWord");
    print("📌 isValid (sözlükte var mı): $isValid");
    print("📌 isCorrect (bağlantılı mı): $isCorrect");
    print("📌 isMiddleOk (yıldızda mı): $isMiddleOk");
    print("📌 Birleşik mi harfler: $birlesik");
    print("📌 isFirstMove: $isFirstMove");
    print("✅ Koyulan harflerin skoru: ${gamerBonusScore()}");
    print("✅ Toplam kelime skoru: ${gamerFullWordScore()}");

    final isAccepted = (isFirstMove && isValid && isMiddleOk && birlesik) ||
        (!isFirstMove && isValid && isCorrect && birlesik);

    isSendWordTrue = isAccepted;
    print("✅ Kabul Edildi mi: $isAccepted");

    if (isAccepted) {
      for (int i = 0; i < placedLetters.length; i++) {
        var l = placedLetters[i];
        board[l.row][l.col].isWord = true;
        board[l.row][l.col].isLast = false;

        if (i == placedLetters.length - 1) {
          board[l.row][l.col].isLast = true;
        }
      }
    }

    notifyListeners();
  }

  bool isSendWordGamer = false;
  Future<void> sendWordButton() async {
    if (!isSendWordTrue) {
      debugPrint("❌ Kelime kabul edilmediği için gönderilmiyor.");
      return;
    }

    if (isSendWordGamer) return;
    isSendWordGamer = true;
    notifyListeners();

    final userId = _userService.userId!;
    final gameId = int.parse(_gameService.gameId!);

    final wordScore = placedLetters.fold(0, (sum, l) => sum + l.score);
    final bonusScore = gamerFullWordScore();

    final payload = {
      "gameId": gameId,
      "userId": userId,
      "wordScore": wordScore,
      "bonusWordScore": bonusScore,
      "letters": placedLetters
          .map((l) => {
                "row": l.row,
                "col": l.col,
                "letterId": l.letterId,
              })
          .toList(),
    };

    try {
      final success = await _wordService.sendWord(payload);

      if (success) {
        debugPrint("✅ Kelime başarıyla gönderildi!");
        for (var l in placedLetters) {
          board[l.row][l.col].isClosed = true;
        }
        placedLetters.clear();
        placeLetterList.clear();
      } else {
        debugPrint("Kelime gönderme başarısız (response false)");
      }
    } catch (e) {
      debugPrint("Kelime gönderme hatası: $e");
    } finally {
      isSendWordGamer = false;
      notifyListeners();
    }
  }

  Future<void> finishGameTime() async {
    final userId = _userService.userId;
    final gameId = _gameService.gameId;

    if (userId == null || gameId == null || turnUserId != userId) return;
    final url = Uri.parse("http://192.168.1.178:7109/api/Game/oyun-bitir");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(
            {"gameId": int.parse(gameId), "finishType": "zamanasimi"}),
      );

      if (response.statusCode == 200) {
        debugPrint("🛑 Oyun zaman aşımı ile bitti: ${response.body}");
        gameOver = true;
        gameOverMessage = "Süre doldu. Oyun sona erdi.";
        notifyListeners();
      } else {
        debugPrint(
            "Oyun bitirme başarısız: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      debugPrint("Oyun bitirme hatası: $e");
    }
  }

  String? gameOverMessage;
  bool gameOver = false;

  void handleGameSurrendered(int winnerId) {
    _gameService.gameStatus = "Bitti";
    _gameService.winnerGamerId = winnerId;
    gameOver = true;

    final isWinner = _userService.userId == winnerId;
    gameOverMessage = isWinner
        ? "Rakibin teslim oldu. Oyunu kazandın!"
        : "Teslim oldun. Oyun sona erdi.";

    _timer?.cancel();
    _timer = null;

    notifyListeners();
  }

  void gamesLettersToBoard() {
    final cells = _gameService.gameCell;
    for (var cell in cells) {
      final row = cell['row'];
      final col = cell['col'];
      final letter = cell['placedLetter'];

      board[row][col].letter = letter;
      board[row][col].score = getLetterPoint(letter);
      board[row][col].isClosed = true;
      board[row][col].isWord = false;
    }
  }
}
