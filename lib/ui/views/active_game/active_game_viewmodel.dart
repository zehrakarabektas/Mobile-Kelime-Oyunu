import 'package:stacked/stacked.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:http/http.dart' as http;
import 'package:stacked_services/stacked_services.dart';
import 'package:yazlab2proje2kelimeoyunumobil/app/app.router.dart';
import 'package:yazlab2proje2kelimeoyunumobil/services/game_service.dart';
import 'dart:convert';
import '../../../app/app.locator.dart';
import '../../../services/user_service.dart';

class ActiveGameViewModel extends BaseViewModel {
  final _userService = locator<UserService>();
  final List<OyunModel> aktifOyunlar = [];
  late HubConnection _hubConnect;

  Future<void> initSignalR() async {
    print("SignalR bağlantısı başlatılıyor...");

    _hubConnect = HubConnectionBuilder()
        .withUrl('http://192.168.1.178:7109/wordgamehub')
        .build();

    _hubConnect.on("DataChanged", (args) {
      print("📡 SignalR mesajı geldi!");
      fetchActiveGames();
    });

    await _hubConnect.start();
    print("SignalR bağlantısı BAŞLADI!");
  }

  Future<void> fetchActiveGames() async {
    setBusy(true);
    final userId = _userService.userId;
    final url = Uri.parse(
        "http://192.168.1.178:7109/api/GameList/active-games/$userId");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        aktifOyunlar.clear(); // önce eski verileri temizle
        aktifOyunlar.addAll(
          List<OyunModel>.from(data.map((json) => OyunModel.fromJson(json))),
        );
      } else {
        print("Hata: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("API hatası: $e");
    }

    setBusy(false);
    notifyListeners();
  }

  Future<void> oyunaGit(OyunModel oyun) async {
    final _gameService = locator<GameService>();
    final _navigationService = locator<NavigationService>();

    final urlGameInfo =
        Uri.parse('http://192.168.1.178:7109/api/Game/game/${oyun.gameId}');

    try {
      final responseGameInfo = await http.get(urlGameInfo);
      if (responseGameInfo.statusCode == 200) {
        final gameData = jsonDecode(responseGameInfo.body);

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
          gameLetterCount: gameData['gameLetterCount'] ?? 86,
          startTime:
              DateTime.tryParse(gameData['startTime'] ?? "") ?? DateTime.now(),
          lastMoveTime: DateTime.tryParse(gameData['lastMoveTime'] ?? "") ??
              DateTime.now(),
          winnerGamerId: gameData['winnerGamerId'],
          isDraw: gameData['isDraw'] ?? false,
        );

        print("✅ Oyun verileri başarıyla çekildi ve set edildi.");

        _navigationService.replaceWithGameBoardView();
      } else {
        print("❌ Game API hatası: ${responseGameInfo.statusCode}");
      }
    } catch (e) {
      print("❌ Game API çekme hatası: $e");
    }
  }
}

class OyunModel {
  final int gameId;
  final String rakipAdi;
  final int kendiPuani;
  final int rakipPuani;
  final bool siraKimde;
  final String oyunTuru;

  OyunModel(
      {required this.gameId,
      required this.rakipAdi,
      required this.kendiPuani,
      required this.rakipPuani,
      required this.siraKimde,
      required this.oyunTuru});

  factory OyunModel.fromJson(Map<String, dynamic> json) {
    return OyunModel(
        gameId: json["gameID"],
        rakipAdi: json["rivalName"],
        kendiPuani: json["yourScore"],
        rakipPuani: json["rivalScore"],
        siraKimde: json["isYourTurn"],
        oyunTuru: json["gameType"]);
  }
}
