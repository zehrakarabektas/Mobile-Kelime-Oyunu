import 'package:stacked/stacked.dart';
import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';

class NewGameViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  String username = "Zehra"; // aynı GamehomeView gibi
  String successRate = "85"; // UI'da % ifadesi için string bekleniyor

  void onDurationSelected(BuildContext context, Duration duration) {
    debugPrint("Yeni oyun süresi seçildi: $duration");
    _navigationService.replaceWithGameBoardView();
    // TODO: eşleşme başlat / oyun ekranına yönlendir
    // örn: Navigator.pushNamed(context, '/gameboard', arguments: duration);
  }
}
