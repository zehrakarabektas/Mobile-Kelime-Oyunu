import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:yazlab2proje2kelimeoyunumobil/app/app.router.dart';
import '../../../app/app.locator.dart';
import 'package:flutter/material.dart';
import '../../../services/user_service.dart';

class GamehomeViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _userService = locator<UserService>();
  String get username => _userService.userName ?? "Bilinmiyor";
  String get successRate => _userService.successRate.toStringAsFixed(1);
  void goToActiveGames() {
    _navigationService.replaceWithActiveGameView();
  }

  void goToFinishedGames() {
    _navigationService.replaceWithCompleteGameView();
  }

  void selectGameDuration(BuildContext context) {
    _navigationService.replaceWithNewGameView();
  }

  void goToSettings() {
    _navigationService.replaceWithSettingsView();
    debugPrint("Ayarlar ekranına yönlendiriliyor...");
  }

  void logout() {
    debugPrint("Kullanıcı çıkış yaptı.");
  }
}
