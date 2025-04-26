import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
//import 'package:google_fonts/google_fonts.dart';
import 'gamehome_viewmodel.dart';
import 'package:yazlab2proje2kelimeoyunumobil/ui/shared/baseLayout.dart';

class GamehomeView extends StackedView<GamehomeViewModel> {
  const GamehomeView({Key? key}) : super(key: key);

  @override
  Widget builder(
      BuildContext context, GamehomeViewModel viewModel, Widget? child) {
    return BaseLayout(
      username: viewModel.username,
      successRate: viewModel.successRate,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Expanded(
                  child: VisualIconButton(
                    iconPath: "lib/assets/images/yeniOyun.png",
                    backgroundColor: const Color(0xFFB6F2B6),
                    onTap: () => viewModel.selectGameDuration(context),
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
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 140),
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: backgroundColor.withOpacity(0.85),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Image.asset(
          iconPath,
          width: 140,
          height: 140,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
