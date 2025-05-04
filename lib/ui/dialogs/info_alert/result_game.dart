import 'package:flutter/material.dart';
import 'dart:ui';

class MayinEtki {
  final String etki;
  final int adet;

  MayinEtki({required this.etki, required this.adet});
}

class GameResultModel {
  final int kendiPuani;
  final int rakipPuani;
  final int kalanHarf;
  final int isWinnerGamer; // Winner'ı belirlemek için int ID
  final bool isDraw;
  final List<MayinEtki> mayinlar;

  GameResultModel({
    required this.kendiPuani,
    required this.rakipPuani,
    required this.kalanHarf,
    required this.isWinnerGamer,
    required this.isDraw,
    required this.mayinlar,
  });

  static GameResultModel fromJson(Map<String, dynamic> data, int userId) {
    List<MayinEtki> etkiler = [];
    if (data["triggerMine"] != null) {
      for (var item in data["triggerMine"]) {
        final parts = item.split(" kere ");
        if (parts.length == 2) {
          final duzgunAd = cevirAd(parts[1]);
          etkiler.add(MayinEtki(
            etki: duzgunAd,
            adet: int.tryParse(parts[0]) ?? 1,
          ));
          
        }
      }
    }

    return GameResultModel(
      kendiPuani: data["userScore"],
      rakipPuani: data["rivalScore"],
      kalanHarf: data["lastLetterCount"],
      isWinnerGamer: data["winUser"] == userId ? 1 : 0,
      isDraw: data["winUser"] == null,
      mayinlar: etkiler,
    );
  }
}

String cevirAd(String name) {
  switch (name) {
    case "PuanBolunmesi":
      return "Puan Bölünmesi";
    case "PuanTransferi":
      return "Puan Transferi";
    case "HarfKaybi":
      return "Harf Kaybı";
    case "EkstraHamleEngeli":
      return "Ekstra Hamle Engeli";
    case "KelimeIptali":
      return "Kelime İptali";
    default:
      return name;
  }
}

class GameResultDialog extends StatelessWidget {
  final GameResultModel oyun;

  const GameResultDialog({super.key, required this.oyun});

  @override
  Widget build(BuildContext context) {
    final bool kazanildi = oyun.isWinnerGamer == 1;
    final bool berabere = oyun.isDraw;

    final imagePath = berabere
        ? "lib/assets/images/beraberesonuc.png"
        : kazanildi
            ? "lib/assets/images/kazanansonuc.png"
            : "lib/assets/images/kaybedensonuc.png";

    return Dialog(
      backgroundColor: Colors.white.withOpacity(0.0),
      insetPadding: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    imagePath,
                    height: 180,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    berabere
                        ? "Berabere!"
                        : kazanildi
                            ? "Tebrikler, kazandın!"
                            : "Üzgünüm, kaybettin...",
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Divider(),
                  InfoRow(title: "Senin Puanın", value: "${oyun.kendiPuani}"),
                  InfoRow(title: "Rakip Puanı", value: "${oyun.rakipPuani}"),
                  InfoRow(
                      title: "Kalan Harf Sayısı", value: "${oyun.kalanHarf}"),
                  const SizedBox(height: 8),
                  Text("Mayın Etkileri:",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  ...oyun.mayinlar
                      .map((m) => Text("- ${m.etki} (${m.adet} kere)")),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Tamam"),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String title;
  final String value;
  const InfoRow({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
