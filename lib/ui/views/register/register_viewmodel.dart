import 'package:stacked/stacked.dart';

class RegisterViewModel extends BaseViewModel {
  String username = '';
  String email = '';
  String password = '';
  String checkPassword = '';
  String message = '';

  void updateUsername(String value) => username = value;
  void updateEmail(String value) => email = value;
  void updatePassword(String value) => password = value;
  void updateCheckPassword(String value) => checkPassword = value;

  void register() {
    if (username.isEmpty) {
      message = "Lütfen bir kullanıcı adı girin.";
    } else if (!_isValidEmail(email)) {
      message = "Geçerli bir e-posta adresi girin.";
    } else if (!_isValidPassword(password)) {
      message =
          "Şifre en az 8 karakter olmalı, büyük harf, küçük harf ve rakam içermeli.";
    } else {
      message = "Kayıt başarılı ";
    }

    notifyListeners();
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r"^[\w\.-]+@[\w\.-]+\.\w+$");
    return emailRegex.hasMatch(email);
  }

  bool _isValidPassword(String password) {
    final passwordRegex =
        RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}$');
    return passwordRegex.hasMatch(password);
  }
}
