import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:yazlab2proje2kelimeoyunumobil/app/app.router.dart';
import '../../../app/app.locator.dart';
import 'package:flutter/material.dart';

class GamehomeViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  String username = "Zehra";
  int playedGames = 0;
  int wonGames = 0;

  String get successRate {
    if (playedGames == 0) return "0";
    return ((wonGames / playedGames) * 100).toStringAsFixed(1);
  }

  void goToActiveGames() {
    // yönlendirme yapılacak (örnek)
    // _navigationService.navigateToActiveGamesView();
  }

  void goToFinishedGames() {
    // yönlendirme yapılacak (örnek)
    // _navigationService.navigateToFinishedGamesView();
  }

  void selectGameDuration(BuildContext context) {
    _navigationService.replaceWithNewGameView();
  }

  void goToSettings() {
    debugPrint("Ayarlar ekranına yönlendiriliyor...");
  }

  void logout() {
    debugPrint("Kullanıcı çıkış yaptı.");
  }
}
