import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:google_fonts/google_fonts.dart';
import 'gamehome_viewmodel.dart';

class GamehomeView extends StackedView<GamehomeViewModel> {
  const GamehomeView({Key? key}) : super(key: key);

  @override
  Widget builder(
      BuildContext context, GamehomeViewModel viewModel, Widget? child) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'lib/assets/images/anaSayfaTasarimi.png',
              fit: BoxFit.cover,
            ),
          ),
          Container(color: Colors.black.withOpacity(0.3)),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.person,
                                size: 36, color: Colors.black),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  viewModel.username,
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  "Başarı: %${viewModel.successRate}",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Butonlar
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Satır 1
                        Row(
                          children: [
                            Expanded(
                              child: VisualIconButton(
                                iconPath: "lib/assets/images/yeniOyun.png",
                                backgroundColor: const Color(0xFFB6F2B6),
                                onTap: () =>
                                    viewModel.selectGameDuration(context),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: VisualIconButton(
                                iconPath: "lib/assets/images/aktifOyunlar.png",
                                backgroundColor: const Color(0xFFB6DFFF),
                                onTap: viewModel.goToActiveGames,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Satır 2
                        Row(
                          children: [
                            Expanded(
                              child: VisualIconButton(
                                iconPath: "lib/assets/images/bitenOyunlar.png",
                                backgroundColor: const Color(0xFFFFD9B6),
                                onTap: viewModel.goToFinishedGames,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: VisualIconButton(
                                iconPath: "lib/assets/images/ayarlar.png",
                                backgroundColor: const Color(0xFFD6D6D6),
                                onTap: viewModel.goToSettings,
                              ),
                            ),
                          ],
                        ),
                      ],
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
  GamehomeViewModel viewModelBuilder(BuildContext context) =>
      GamehomeViewModel();
}

class VisualIconButton extends StatelessWidget {
  final String iconPath;
  final Color backgroundColor;
  final VoidCallback onTap;

  const VisualIconButton({
    Key? key,
    required this.iconPath,
    required this.backgroundColor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          child: Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: backgroundColor.withOpacity(0.7), 
              borderRadius: BorderRadius.circular(24),
            ),
            child: Image.asset(
              iconPath,
              width: 140,
              height: 140,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
