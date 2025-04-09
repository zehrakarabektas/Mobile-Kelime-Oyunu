import 'package:stacked/stacked.dart';

class LoginViewModel extends BaseViewModel {
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
    } else {
      message = 'Email veya şifre hatalı!';
    }
    notifyListeners();
  }
}
