import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:stacked/stacked.dart';

class GameService with ListenableServiceMixin {
  Timer? _timer;

  String? gameId;
  int? gamer1Id;
  int? gamer2Id;
  String? gamer1Name;
  String? gamer2Name;
  String? gameType;
  String? gameStatus;
  int? turnGamerId;
  int gamer1Score = 0;
  int gamer2Score = 0;
  int gamer1PassCount = 0;
  int gamer2PassCount = 0;
  int gameLetterCount = 86;
  DateTime? startTime;
  DateTime? lastMoveTime;
  int gameSeconds = 0;
  int? winnerGamerId;
  bool isDraw = false;

  void setGame({
    required String gameId,
    required int gamer1Id,
    required int gamer2Id,
    required String gamer1Name,
    required String gamer2Name,
    required int turnGamerId,
    required int gamer1Score,
    required int gamer2Score,
    required int gamer1PassCount,
    required int gamer2PassCount,
    required int gameLetterCount,
    required DateTime startTime,
    required DateTime lastMoveTime,
    required int gameSeconds,
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

  void setGameId(int id) {
    gameId = id.toString();
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
      gamer1Score: game['gamer1Score'] ?? 0,
      gamer2Score: game['gamer2Score'] ?? 0,
      gamer1PassCount: game['gamer1PassCount'] ?? 0,
      gamer2PassCount: game['gamer2PassCount'] ?? 0,
      gameLetterCount: game['gameLetterCount'] ?? 86,
      startTime: DateTime.tryParse(game['startTime'] ?? "") ?? DateTime.now(),
      lastMoveTime: DateTime.tryParse(game['lastMoveTime'] ?? "") ??
          DateTime.tryParse(game['startTime'] ?? "") ??
          DateTime.now(),
      gameSeconds: game['gameSeconds'] ?? 0,
      winnerGamerId: game['winnerGamerId'],
      isDraw: game['isDraw'] ?? false,
    );
  }

  void clear() {
    _timer?.cancel();
    _timer = null;
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

  Duration get leftTime {
    final now = DateTime.now();

    final reference = (lastMoveTime != null && lastMoveTime != startTime)
        ? lastMoveTime!
        : startTime!;

    final elapsed = now.difference(reference);
    final remaining = Duration(seconds: gameSeconds) - elapsed;

    /*print("🕒 now: $now");
    print("📌 reference: $reference");
    print("⏱ elapsed: $elapsed");
    print("🔻 remaining: $remaining");*/

    return remaining.isNegative ? Duration.zero : remaining;
  }

  String get leftTimeString {
    final time = leftTime;
    final hours = time.inHours;
    final minutes = time.inMinutes.remainder(60);
    final seconds = time.inSeconds.remainder(60);

    String formatted;
    if (hours > 0) {
      final hStr = hours.toString().padLeft(2, '0');
      final mStr = minutes.toString().padLeft(2, '0');
      final sStr = seconds.toString().padLeft(2, '0');
      formatted = "$hStr:$mStr:$sStr";
    } else {
      final mStr = minutes.toString().padLeft(2, '0');
      final sStr = seconds.toString().padLeft(2, '0');
      formatted = "$mStr:$sStr";
    }

    //print("🧾 leftTimeString: $formatted");
    return formatted;
  }

  void timeOut(int myUserId) {
    if (turnGamerId == myUserId && winnerGamerId == null) {
      winnerGamerId = (gamer1Id == myUserId) ? gamer2Id : gamer1Id;
      isDraw = false;
      GameOverApi();
      notifyListeners();
    }
  }

  Future<void> GameOverApi() async {
    final url = Uri.parse("http://192.168.1.178:7109/api/Game/oyun-bitir");

    try {
      await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: '''{
          "gameId": "$gameId",
          "winnerGamerId": $winnerGamerId,
          "isDraw": $isDraw
        }''',
      );
    } catch (e) {
      print("Oyun bitirilemedi: $e");
    }
  }
}
