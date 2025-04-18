import 'package:stacked/stacked.dart';
import 'package:flutter/material.dart';

class NewGameViewModel extends BaseViewModel {
  String username = "Zehra"; // aynı GamehomeView gibi
  String successRate = "85"; // UI'da % ifadesi için string bekleniyor

  void onDurationSelected(BuildContext context, Duration duration) {
    debugPrint("Yeni oyun süresi seçildi: $duration");
    // TODO: eşleşme başlat / oyun ekranına yönlendir
    // örn: Navigator.pushNamed(context, '/gameboard', arguments: duration);
  }
}
