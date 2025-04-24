import 'package:stacked/stacked.dart';
import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../services/user_service.dart'; 

class NewGameViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _userService = locator<UserService>(); 

  String get username => _userService.userName ?? "Bilinmiyor";
  String get successRate => _userService.successRate.toStringAsFixed(1); 

  void onDurationSelected(BuildContext context, Duration duration) {
    debugPrint("Yeni oyun süresi seçildi: $duration");
    _navigationService.replaceWithGameBoardView();

    // TODO: Eşleşme API isteği buraya gelebilir
  }
}
