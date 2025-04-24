import 'package:stacked/stacked.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterViewModel extends BaseViewModel {
  String username = '';
  String email = '';
  String password = '';
  String message = '';

  void updateUsername(String value) => username = value;
  void updateEmail(String value) => email = value;
  void updatePassword(String value) => password = value;

  void register() async {
    if (username.isEmpty) {
      message = "Lütfen bir kullanıcı adı girin.";
    } else if (!_isValidEmail(email)) {
      message = "Geçerli bir e-posta adresi girin.";
    } else if (!_isValidPassword(password)) {
      message =
          "Şifre en az 8 karakter olmalı, büyük harf, küçük harf ve rakam içermeli.";
    } else {
      try {
        final url =
            Uri.parse("http://192.168.1.178:7109/api/Authentication/register");
        final response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: json.encode({
            "userName": username,
            "userEmail": email,
            "password": password,
          }),
        );

        if (response.statusCode == 200) {
          message = "Kayıt başarılı!";
        } else {
          try {
            final responseData = json.decode(response.body);
            message = "Hata: ${responseData.toString()}";
          } catch (e) {
            message = response.body;
          }
        }
      } catch (e) {
        message = "Sunucuya bağlanılamadı: $e";
      }
    }

    notifyListeners();
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r"^[\w\.-]+@[\w\.-]+\.\w+$");
    return emailRegex.hasMatch(email);
  }

  bool _isValidPassword(String password) {
    final passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$');
    return passwordRegex.hasMatch(password);
  }
}
