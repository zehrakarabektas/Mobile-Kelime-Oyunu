import 'package:stacked/stacked.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../app/app.locator.dart';
import '../../../services/user_service.dart';
import 'package:signalr_netcore/signalr_client.dart';

class Oyun {
  final String rakipAdi;
  final int kendiPuani;
  final int rakipPuani;
  final DateTime tarih;
  final bool isWinnerGamer;
  final bool isDraw;

  Oyun(
      {required this.rakipAdi,
      required this.kendiPuani,
      required this.rakipPuani,
      required this.tarih,
      required this.isWinnerGamer,
      required this.isDraw});
  factory Oyun.fromJson(Map<String, dynamic> json) {
    return Oyun(
      rakipAdi: json["rivalName"],
      kendiPuani: json["yourScore"],
      rakipPuani: json["rivalScore"],
      tarih: DateTime.parse(json["gameDate"]),
      isWinnerGamer: json["isWinnerGamer"] ?? false,
      isDraw: json["isDraw"] ?? false,
    );
  }
}

class CompleteGameViewModel extends BaseViewModel {
  final _userService = locator<UserService>();
  List<Oyun> bitenOyunlar = [];
  late HubConnection _hubConnect;

  Future<void> initSignalR() async {
    _hubConnect = HubConnectionBuilder()
        .withUrl('http://192.168.1.178:7109/wordgamehub')
        .build();

    _hubConnect.on("DataChanged", (args) {
      fetchCompletedGames();
    });
    await _hubConnect.start();
  }

  Future<void> fetchCompletedGames() async {
    final userId = _userService.userId;
    final url = Uri.parse(
        "http://192.168.1.178:7109/api/GameList/completed-games/$userId");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        bitenOyunlar = List<Oyun>.from(data.map((json) => Oyun.fromJson(json)));
      } else {
        print("Hata: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("API hatası: $e");
    }
    notifyListeners();
  }
}
