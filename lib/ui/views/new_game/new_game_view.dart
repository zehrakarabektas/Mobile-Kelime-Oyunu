import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:yazlab2proje2kelimeoyunumobil/ui/shared/baseLayout.dart';
import '../../../app/app.router.dart';
import 'new_game_viewmodel.dart';
import '../gamehome/gamehome_view.dart';

class NewGameView extends StackedView<NewGameViewModel> {
  const NewGameView({super.key});

  @override
  Widget builder(
      BuildContext context, NewGameViewModel viewModel, Widget? child) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.gamehomeView,
          (route) => false,
        );
        return false;
      },
      child: BaseLayout(
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
                      iconPath: "lib/assets/images/ikidakikaicon.png",
                      backgroundColor: const Color(0xFFB6F2B6),
                      onTap: () => viewModel.onDurationSelected(
                          context, const Duration(minutes: 2)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: VisualIconButton(
                      iconPath: "lib/assets/images/besdakikaicon.png",
                      backgroundColor: const Color(0xFFB6DFFF),
                      onTap: () => viewModel.onDurationSelected(
                          context, const Duration(minutes: 5)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: VisualIconButton(
                      iconPath: "lib/assets/images/onikisaaticon.png",
                      backgroundColor: const Color(0xFFFFD9B6),
                      onTap: () => viewModel.onDurationSelected(
                          context, const Duration(hours: 12)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: VisualIconButton(
                      iconPath: "lib/assets/images/yirmidortsaaticon.png",
                      backgroundColor: const Color(0xFFD6D6D6),
                      onTap: () => viewModel.onDurationSelected(
                          context, const Duration(hours: 24)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  NewGameViewModel viewModelBuilder(BuildContext context) => NewGameViewModel();
}
