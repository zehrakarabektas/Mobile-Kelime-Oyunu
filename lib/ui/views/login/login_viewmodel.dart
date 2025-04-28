import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../services/user_service.dart';

class LoginViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _userService = locator<UserService>();
  String email = '';
  String password = '';
  String message = '';

  void updateEmail(String value) => email = value;
  void updatePassword(String value) => password = value;

  void login() async {
    if (email.isEmpty || password.isEmpty) {
      message = "Email ve şifre boş olamaz.";
      notifyListeners();
      return;
    }

    try {
      final url =
          Uri.parse("http://192.168.1.178:7109/api/Authentication/login");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "userName": email,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);

        _userService.setUser(
          id: userData["userID"],
          name: userData["userName"],
          mail: userData["userEmail"],
          success: (userData["successRate"] ?? 0).toDouble(),
        );

        message = "Giriş başarılı!";
        _navigationService.replaceWithGamehomeView();
      } else {
        try {
          final error = json.decode(response.body);
          message = error["message"] ?? error.toString();
        } catch (_) {
          message = response.body;
        }
      }
    } catch (e) {
      message = "Sunucuya bağlanılamadı: $e";
    }

    notifyListeners();
  }
}
