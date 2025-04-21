import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'active_game_viewmodel.dart';
import 'dart:ui';

class ActiveGameView extends StackedView<ActiveGameViewModel> {
  const ActiveGameView({super.key});

  @override
  Widget builder(
    BuildContext context,
    ActiveGameViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'lib/assets/images/aktifOyunlarArkaPlan.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 480),
                Expanded(
                  child: SingleChildScrollView(
                    reverse: true,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 45),
                      child: Column(
                        children: viewModel.oyunlar.map((oyun) {
                          return GestureDetector(
                            onTap: () => viewModel.oyunaGit(oyun),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: BackdropFilter(
                                  filter:
                                      ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.4),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.white24),
                                    ),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor:
                                            const Color(0xFF2C1655),
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
                                        "Sen: ${oyun.kendiPuani} - Rakip: ${oyun.rakipPuani}",
                                      ),
                                      trailing: Icon(
                                        oyun.siraKimde
                                            ? Icons.play_arrow
                                            : Icons.hourglass_empty,
                                        color: oyun.siraKimde
                                            ? const Color.fromARGB(
                                                255, 45, 115, 47)
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  ActiveGameViewModel viewModelBuilder(BuildContext context) =>
      ActiveGameViewModel();
}
