import 'package:yazlab2proje2kelimeoyunumobil/ui/bottom_sheets/notice/notice_sheet.dart';
import 'package:yazlab2proje2kelimeoyunumobil/ui/dialogs/info_alert/info_alert_dialog.dart';
import 'package:yazlab2proje2kelimeoyunumobil/ui/views/home/home_view.dart';
import 'package:yazlab2proje2kelimeoyunumobil/ui/views/startup/startup_view.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:yazlab2proje2kelimeoyunumobil/ui/views/login/login_view.dart';
import 'package:yazlab2proje2kelimeoyunumobil/ui/views/register/register_view.dart';
import 'package:yazlab2proje2kelimeoyunumobil/ui/views/gamehome/gamehome_view.dart';
import 'package:yazlab2proje2kelimeoyunumobil/ui/views/new_game/new_game_view.dart';
import 'package:yazlab2proje2kelimeoyunumobil/ui/views/game_board/game_board_view.dart';
import 'package:yazlab2proje2kelimeoyunumobil/ui/views/active_game/active_game_view.dart';
import 'package:yazlab2proje2kelimeoyunumobil/ui/views/complete_game/complete_game_view.dart';
// @stacked-import

@StackedApp(
  routes: [
    MaterialRoute(page: HomeView),
    MaterialRoute(page: StartupView),
    MaterialRoute(page: LoginView),
    MaterialRoute(page: RegisterView),
    MaterialRoute(page: GamehomeView),
    MaterialRoute(page: NewGameView),
    MaterialRoute(page: GameBoardView),
    MaterialRoute(page: ActiveGameView),
    MaterialRoute(page: CompleteGameView),
// @stacked-route
  ],
  dependencies: [
    LazySingleton(classType: BottomSheetService),
    LazySingleton(classType: DialogService),
    LazySingleton(classType: NavigationService),
    // @stacked-service
  ],
  bottomsheets: [
    StackedBottomsheet(classType: NoticeSheet),
    // @stacked-bottom-sheet
  ],
  dialogs: [
    StackedDialog(classType: InfoAlertDialog),
    // @stacked-dialog
  ],
)
class App {}
