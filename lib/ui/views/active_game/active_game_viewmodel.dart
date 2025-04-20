import 'package:stacked/stacked.dart';

class ActiveGameViewModel extends BaseViewModel {
  final List<OyunModel> oyunlar = [
    OyunModel("Nazlı", 45, 38, true),
    OyunModel("Zela", 32, 50, false),
    OyunModel("Büşra", 20, 20, true),
    OyunModel("Ceylo", 45, 38, true),
    OyunModel("Melike", 32, 50, false),
    OyunModel("Zehra", 20, 20, true),
    OyunModel("Zuhal", 45, 38, true),
    OyunModel("Betül", 32, 50, false),
    OyunModel("Zeynep", 20, 20, true),
  ];

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

  OyunModel(this.rakipAdi, this.kendiPuani, this.rakipPuani, this.siraKimde);
}
