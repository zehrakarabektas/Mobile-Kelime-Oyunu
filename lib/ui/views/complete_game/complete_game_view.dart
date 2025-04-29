import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'dart:ui';
import 'complete_game_viewmodel.dart';

class CompleteGameView extends StackedView<CompleteGameViewModel> {
  const CompleteGameView({Key? key}) : super(key: key);
  @override
  void onViewModelReady(CompleteGameViewModel viewModel) {
    viewModel.initSignalR();
    viewModel.fetchCompletedGames();
  }

  @override
  Widget builder(
    BuildContext context,
    CompleteGameViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'lib/assets/images/bitenOyunlarArkaPlan.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 500),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 45),
                    itemCount: viewModel.bitenOyunlar.length,
                    itemBuilder: (context, index) {
                      final oyun = viewModel.bitenOyunlar[index];
                      final bool kazanildi = oyun.kendiPuani > oyun.rakipPuani;
                      final bool berabere = oyun.kendiPuani == oyun.rakipPuani;

                      return Padding(
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
                                subtitle: Text(
                                    "Sen: ${oyun.kendiPuani} - Rakip: ${oyun.rakipPuani}"),
                                trailing: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      berabere
                                          ? Icons.handshake_rounded
                                          : kazanildi
                                              ? Icons.check_circle
                                              : Icons.cancel,
                                      color: berabere
                                          ? Colors.amber
                                          : kazanildi
                                              ? const Color.fromARGB(
                                                  255, 45, 115, 47)
                                              : const Color.fromARGB(
                                                  255, 248, 3, 3),
                                      size: 35,
                                    ),
                                    const SizedBox(height: 0),
                                    Text(
                                      berabere
                                          ? "Berabere"
                                          : kazanildi
                                              ? "Kazanıldı"
                                              : "Kaybedildi",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: berabere
                                            ? Colors.amber
                                            : kazanildi
                                                ? const Color.fromARGB(
                                                    255, 45, 115, 47)
                                                : const Color.fromARGB(
                                                    255, 248, 3, 3),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  CompleteGameViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      CompleteGameViewModel();
}
