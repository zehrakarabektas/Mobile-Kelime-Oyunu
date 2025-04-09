import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'startup_viewmodel.dart';
import '../../shared/button.dart';

class StartupView extends StackedView<StartupViewModel> {
  const StartupView({super.key});

  @override
  Widget builder(
      BuildContext context, StartupViewModel viewModel, Widget? child) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'lib/assets/images/anaSayfaTasarimi.png',
              fit: BoxFit.fitHeight,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedButton(
                    text: 'Giriş Yap',
                    onTap: viewModel.navigateToLogin,
                    backgroundColor: const Color.fromARGB(255, 98, 82, 169),
                    borderColor: const Color.fromARGB(255, 24, 17, 42),
                    textColor: Colors.white,
                  ),
                  AnimatedButton(
                    text: 'Kayıt Ol',
                    onTap: viewModel.navigateToRegister,
                    backgroundColor: const Color.fromARGB(255, 231, 206, 155),
                    borderColor: const Color.fromARGB(255, 33, 22, 8),
                    textColor: const Color(0xFF4B2A00),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  StartupViewModel viewModelBuilder(BuildContext context) => StartupViewModel();
}
