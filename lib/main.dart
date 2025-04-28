import 'package:flutter/material.dart';
import 'package:yazlab2proje2kelimeoyunumobil/app/app.bottomsheets.dart';
import 'package:yazlab2proje2kelimeoyunumobil/app/app.dialogs.dart';
import 'package:yazlab2proje2kelimeoyunumobil/app/app.locator.dart';
import 'package:yazlab2proje2kelimeoyunumobil/app/app.router.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:yazlab2proje2kelimeoyunumobil/services/letter_list_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();
  setupDialogUi();
  setupBottomSheetUi();
  await LetterListService().loadWords(); 
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: Routes.startupView,
      onGenerateRoute: StackedRouter().onGenerateRoute,
      navigatorKey: StackedService.navigatorKey,
      navigatorObservers: [StackedService.routeObserver],
    );
  }
}
