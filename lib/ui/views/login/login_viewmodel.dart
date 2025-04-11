import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';

class LoginViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  String email = '';
  String password = '';
  String message = '';

  void updateEmail(String value) {
    email = value;
  }

  void updatePassword(String value) {
    password = value;
  }

  void login() {
    if (email == 'admin' && password == '1234') {
      message = 'Giriş başarılı!';
      _navigationService.replaceWithGamehomeView();
    } else {
      message = 'Email veya şifre hatalı!';
    }
    notifyListeners();
  }
}
