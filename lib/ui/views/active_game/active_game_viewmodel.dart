import 'package:stacked/stacked.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:http/http.dart' as http;
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

  void oyunaGit(OyunModel oyun) {
    // Örnek: navigationService ile oyuna yönlendirme
    // navigationService.navigateTo('/oyun', arguments: oyun);
    print("Oyuna geçiliyor: ${oyun.rakipAdi}");
  }
}

class OyunModel {
  final String rakipAdi;
  final int kendiPuani;
  final int rakipPuani;
  final bool siraKimde;
  final String oyunTuru;

  OyunModel(
      {required this.rakipAdi,
      required this.kendiPuani,
      required this.rakipPuani,
      required this.siraKimde,
      required this.oyunTuru});

  factory OyunModel.fromJson(Map<String, dynamic> json) {
    return OyunModel(
        rakipAdi: json["rivalName"],
        kendiPuani: json["yourScore"],
        rakipPuani: json["rivalScore"],
        siraKimde: json["isYourTurn"],
        oyunTuru: json["gameType"]);
  }
}
