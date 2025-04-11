import 'package:stacked/stacked.dart';
import 'package:flutter/material.dart';

class GamehomeViewModel extends BaseViewModel {
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
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Oyun Süresini Seç",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _durationOption(
                context, "Hızlı Oyun - 2 Dakika", Duration(minutes: 2)),
            _durationOption(
                context, "Hızlı Oyun - 5 Dakika", Duration(minutes: 5)),
            _durationOption(
                context, "Genişletilmiş - 12 Saat", Duration(hours: 12)),
            _durationOption(
                context, "Genişletilmiş - 24 Saat", Duration(hours: 24)),
          ],
        ),
      ),
    );
  }
   void goToSettings() {
    debugPrint("Ayarlar ekranına yönlendiriliyor...");
  }

  void logout() {
    debugPrint("Kullanıcı çıkış yaptı.");
  }
  Widget _durationOption(
      BuildContext context, String label, Duration duration) {
    return ListTile(
      title: Text(label),
      onTap: () {
        Navigator.pop(context);
        // Seçilen süre ile eşleşme işlemi yapılacak
        print("Seçilen Süre: $duration");
        // TODO: eşleşme sistemi buraya entegre edilecek
      },
    );
  }
}
