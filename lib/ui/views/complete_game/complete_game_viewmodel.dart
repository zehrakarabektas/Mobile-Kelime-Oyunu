import 'package:stacked/stacked.dart';

class Oyun {
  final String rakipAdi;
  final int kendiPuani;
  final int rakipPuani;

  Oyun({
    required this.rakipAdi,
    required this.kendiPuani,
    required this.rakipPuani,
  });
}

class CompleteGameViewModel extends BaseViewModel {
  final List<Oyun> bitenOyunlar = [
    Oyun(rakipAdi: "Ahmet", kendiPuani: 85, rakipPuani: 70),
    Oyun(rakipAdi: "Zeynep", kendiPuani: 64, rakipPuani: 64),
    Oyun(rakipAdi: "Burak", kendiPuani: 55, rakipPuani: 78),
    Oyun(rakipAdi: "Elif", kendiPuani: 95, rakipPuani: 80),
    Oyun(rakipAdi: "Kemal", kendiPuani: 60, rakipPuani: 90),
  ];

}
