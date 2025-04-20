import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'complete_game_viewmodel.dart';

class CompleteGameView extends StackedView<CompleteGameViewModel> {
  const CompleteGameView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    CompleteGameViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Container(
        padding: const EdgeInsets.only(left: 25.0, right: 25.0),
        child: const Center(child: Text("CompleteGameView")),
      ),
    );
  }

  @override
  CompleteGameViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      CompleteGameViewModel();
}
