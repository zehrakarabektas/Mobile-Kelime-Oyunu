import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'active_game_viewmodel.dart';
import 'dart:ui';
import 'package:yazlab2proje2kelimeoyunumobil/app/app.router.dart'; 

class ActiveGameView extends StackedView<ActiveGameViewModel> {
  const ActiveGameView({super.key});

  @override
  onViewModelReady(ActiveGameViewModel viewModel) {
    viewModel.initSignalR();
    viewModel.fetchActiveGames();
  }

  @override
  Widget builder(
    BuildContext context,
    ActiveGameViewModel viewModel,
    Widget? child,
  ) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.gamehomeView,
          (Route<dynamic> route) => false,
        );
        return false;
      },
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'lib/assets/images/aktifOyunlarArkaPlan.png',
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 540,
              left: 0,
              right: 0,
              bottom: 0,
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 45, vertical: 10),
                child: Column(
                  children: viewModel.aktifOyunlar.map((oyun) {
                    return GestureDetector(
                      onTap: () => viewModel.oyunaGit(oyun),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: const Color(0xFF2C1655),
                                  child: Text(
                                    oyun.rakipAdi[0],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  oyun.rakipAdi,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        "Sen: ${oyun.kendiPuani} - Rakip: ${oyun.rakipPuani}"),
                                    Text(
                                      "${oyun.oyunTuru.oyunKategorisi} • ${oyun.oyunTuru.okunabilirSure}",
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.black),
                                    ),
                                  ],
                                ),
                                trailing: Icon(
                                  oyun.siraKimde
                                      ? Icons.play_arrow
                                      : Icons.hourglass_empty,
                                  color: oyun.siraKimde
                                      ? const Color.fromARGB(255, 45, 115, 47)
                                      : const Color.fromARGB(255, 248, 3, 3),
                                  size: 45,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  ActiveGameViewModel viewModelBuilder(BuildContext context) =>
      ActiveGameViewModel();
}

extension OyunTuruExtension on String {
  String get okunabilirSure {
    switch (this) {
      case "TwoMinutes":
        return "2 Dakika";
      case "FiveMinutes":
        return "5 Dakika";
      case "TwelveHours":
        return "12 Saat";
      case "TwentyFourHours":
        return "24 Saat";
      default:
        return "Bilinmiyor";
    }
  }

  String get oyunKategorisi {
    switch (this) {
      case "TwoMinutes":
      case "FiveMinutes":
        return "Hızlı Oyun";
      case "TwelveHours":
      case "TwentyFourHours":
        return "Genişletilmiş Oyun";
      default:
        return "Bilinmiyor";
    }
  }
}
