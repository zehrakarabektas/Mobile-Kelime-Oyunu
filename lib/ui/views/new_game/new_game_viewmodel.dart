import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:http/http.dart' as http;
import 'package:signalr_netcore/signalr_client.dart';
import 'dart:convert';

import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../services/game_service.dart';
import '../../../services/user_service.dart';
import 'package:yazlab2proje2kelimeoyunumobil/ui/dialogs/info_alert/waiting_game_start.dart';

class NewGameViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _userService = locator<UserService>();

  late HubConnection _hubConnection;
  bool dialogClosed = false;

  String get username => _userService.userName ?? "Bilinmiyor";
  String get successRate => _userService.successRate.toStringAsFixed(1);

  Future<void> onDurationSelected(
      BuildContext context, Duration duration) async {
    debugPrint("Yeni oyun süresi seçildi: $duration");
    setBusy(true);

    int gameType = getGameTypeFromDuration(duration);

    await startSignalR();

    final response = await http.post(
      Uri.parse(
          'http://192.168.1.178:7109/api/GameStart/oyun-eslesmesi-bul'), // BURASI: kendi bilgisayar IP'n olacak
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "userID": _userService.userId,
        "userName": _userService.userName,
        "gameType": gameType,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final matched = data['matched'] as bool;

      if (matched) {
        debugPrint(
            "API matched true! Şu anda SignalR 'Matched' eventi bekleniyor...");
        // EKRAN açmıyoruz burada! SignalR Matched eventinde açacağız.
      } else {
        debugPrint("API matched false. Beklemeye geçiyorum...");
        await showWaitingDialog(context, gameType);
      }
    } else {
      debugPrint("API Hatası: ${response.statusCode}");
    }

    setBusy(false);
  }

  Future<void> startSignalR() async {
    final userName = _userService.userName ?? "Unknown";

    _hubConnection = HubConnectionBuilder()
        .withUrl(
          'http://192.168.1.178:7109/gamematchhub?userName=$userName&userId=${_userService.userId}',
        )
        .build();

    _hubConnection.on('Matched', (args) async {
      if (!dialogClosed) {
        debugPrint("SignalR Matched geldi! Modal kapatılıyor.");

        final fullJson = args![0] as Map<String, dynamic>;
        final gameJson = fullJson['game'] as Map<String, dynamic>;

        final _gameService = locator<GameService>();
        _gameService.setFromMap(gameJson);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          final navContext =
              locator<NavigationService>().navigatorKey!.currentContext!;
          Navigator.of(navContext, rootNavigator: true).pop();

          ScaffoldMessenger.of(navContext).showSnackBar(
            const SnackBar(
              content: Text('Rakip bulundu! Oyun başlıyor...'),
              duration: Duration(seconds: 2),
            ),
          );
        });

        Future.delayed(const Duration(seconds: 2), () {
          _navigationService.replaceWithGameBoardView();
        });

        dialogClosed = true;

        if (_hubConnection.state == HubConnectionState.Connected) {
          await _hubConnection.stop();
        }
      }
    });

    unawaited(_hubConnection.start()!.then((_) {
      debugPrint("SignalR bağlantısı kuruldu");
    }).catchError((e) {
      debugPrint("SignalR bağlantı hatası: $e");
    }));
  }

  Future<void> showWaitingDialog(BuildContext context, int gameType) async {
    dialogClosed = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => WaitingGameStart(
        onCancel: () async {
          if (!dialogClosed) {
            await http.post(
              Uri.parse(
                  'http://192.168.1.178:7109/api/GameStart/oyun-eslesmesi-ayril'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                "userID": _userService.userId,
                "gameType": gameType,
              }),
            );
            Navigator.of(context, rootNavigator: true).pop();
            dialogClosed = true;
            if (_hubConnection.state == HubConnectionState.Connected) {
              await _hubConnection.stop();
            }
          }
        },
      ),
    );
  }

  int getGameTypeFromDuration(Duration duration) {
    if (duration.inMinutes == 2) return 1;
    if (duration.inMinutes == 5) return 2;
    if (duration.inHours == 12) return 3;
    if (duration.inHours == 24) return 4;
    return 1;
  }
}
