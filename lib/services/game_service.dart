import 'package:stacked/stacked.dart';

class GameService with ListenableServiceMixin {
  String? gameId;
  int? gamer1Id;
  int? gamer2Id;
  String? gamer1Name;
  String? gamer2Name;
  String? gameType;
  String? gameStatus;
  int? turnGamerId;
  int gameSeconds = 0;
  int gamer1Score = 0;
  int gamer2Score = 0;
  int gamer1PassCount = 0;
  int gamer2PassCount = 0;
  int gameLetterCount = 86;
  DateTime? startTime;
  DateTime? lastMoveTime;
  int? winnerGamerId;
  bool isDraw = false;

  void setGame({
    required String gameId,
    required int gamer1Id,
    required int gamer2Id,
    required String gamer1Name,
    required String gamer2Name,
    required int turnGamerId,
    required int gameSeconds,
    required int gamer1Score,
    required int gamer2Score,
    required int gamer1PassCount,
    required int gamer2PassCount,
    required int gameLetterCount,
    required DateTime startTime,
    required DateTime lastMoveTime,
    int? winnerGamerId,
    bool isDraw = false,
  }) {
    this.gameId = gameId;
    this.gamer1Id = gamer1Id;
    this.gamer2Id = gamer2Id;
    this.gamer1Name = gamer1Name;
    this.gamer2Name = gamer2Name;
    this.turnGamerId = turnGamerId;
    this.gameSeconds = gameSeconds;
    this.gamer1Score = gamer1Score;
    this.gamer2Score = gamer2Score;
    this.gamer1PassCount = gamer1PassCount;
    this.gamer2PassCount = gamer2PassCount;
    this.gameLetterCount = gameLetterCount;
    this.startTime = startTime;
    this.lastMoveTime = lastMoveTime;
    this.winnerGamerId = winnerGamerId;
    this.isDraw = isDraw;

    notifyListeners();
  }

  void setFromMap(Map<String, dynamic> game) {
    setGame(
      gameId: game['gameId'].toString(),
      gamer1Id: game['gamer1Id'],
      gamer2Id: game['gamer2Id'],
      gamer1Name: game['gamer1Name'],
      gamer2Name: game['gamer2Name'],
      turnGamerId: game['turnGamerId'],
      gameSeconds: game['gameSeconds'] ?? 0,
      gamer1Score: game['gamer1Score'] ?? 0,
      gamer2Score: game['gamer2Score'] ?? 0,
      gamer1PassCount: game['gamer1PassCount'] ?? 0,
      gamer2PassCount: game['gamer2PassCount'] ?? 0,
      gameLetterCount: game['gameLetterCount'] ?? 86,
      startTime: DateTime.tryParse(game['startTime'] ?? "") ?? DateTime.now(),
      lastMoveTime:
          DateTime.tryParse(game['lastMoveTime'] ?? "") ?? DateTime.now(),
      winnerGamerId: game['winnerGamerId'],
      isDraw: game['isDraw'] ?? false,
    );
  }

  void clear() {
    gameId = null;
    gamer1Id = null;
    gamer2Id = null;
    gamer1Name = null;
    gamer2Name = null;
    gameType = null;
    gameStatus = null;
    turnGamerId = null;
    gameSeconds = 0;
    gamer1Score = 0;
    gamer2Score = 0;
    gameLetterCount = 100;
    gamer1PassCount = 2;
    gamer2PassCount = 2;
    startTime = null;
    lastMoveTime = null;
    winnerGamerId = null;
    isDraw = false;

    notifyListeners();
  }

  bool isTurnGame(int myUserId) {
    return turnGamerId == myUserId;
  }

  String getRivalName(int myUserId) {
    if (gamer1Id == myUserId) {
      return gamer2Name ?? "Rakip";
    } else {
      return gamer1Name ?? "Rakip";
    }
  }
}
