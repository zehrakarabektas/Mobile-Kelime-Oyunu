import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../services/user_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SettingsViewModel extends BaseViewModel {
  final _userService = locator<UserService>();
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  

  bool isEditingName = false;
  bool isEditingEmail = false;

  SettingsViewModel() {
    nameController.text = _userService.userName ?? '';
    emailController.text = _userService.email ?? '';
  }
  String get successRate => _userService.successRate.toStringAsFixed(1);


  void toggleNameEdit() {
    isEditingName = !isEditingName;
    notifyListeners();
  }

  void toggleEmailEdit() {
    isEditingEmail = !isEditingEmail;
    notifyListeners();
  }
  void logout() {
    _userService.clearUser();
    _navigationService.clearStackAndShow(Routes.loginView);
  }

  Future<void> showChangePasswordDialog() async {
    final result = await _dialogService.showCustomDialog(
      title: "Şifre Değiştir",
      description: "Yeni şifre bilgilerinizi giriniz.",
      mainButtonTitle: "Değiştir",
      secondaryButtonTitle: "İptal",
      customData: {
        "fields": [
          {"hint": "Eski Şifre", "isPassword": true},
          {"hint": "Yeni Şifre", "isPassword": true},
          {"hint": "Yeni Şifre Tekrar", "isPassword": true},
        ]
      },
    );

    if (result != null && result.confirmed) {
      final fields = result.data as List<String>;
      if (fields.length == 3) {
        await changePassword(fields[0], fields[1], fields[2]);
      }
    }
  }

  Future<void> changePassword(
      String oldPassword, String newPassword, String confirmPassword) async {
    if (newPassword != confirmPassword) {
      await _dialogService.showDialog(
        title: "Hata",
        description: "Yeni şifreler eşleşmiyor!",
      );
      return;
    }

    try {
      final userId = _userService.userId;
      final url =
          Uri.parse("http://192.168.1.178:7109/api/User/change-password");

      final response = await http.post(url,
          headers: {"Content-Type": "application/json"},
          body: json.encode({
            "userId": userId,
            "oldPassword": oldPassword,
            "newPassword": newPassword,
          }));

      if (response.statusCode == 200) {
        await _dialogService.showDialog(
          title: "Başarılı",
          description: "Şifreniz başarıyla değiştirildi.",
        );
      } else {
        await _dialogService.showDialog(
          title: "Hata",
          description: "Şifre değiştirme başarısız: ${response.body}",
        );
      }
    } catch (e) {
      await _dialogService.showDialog(
        title: "Sunucu Hatası",
        description: "Şifre değiştirilirken bir hata oluştu: $e",
      );
    }
  }

  Future<void> saveProfile() async {
    final updatedName = nameController.text;
    final updatedEmail = emailController.text;

    // API'ye gönderme örneği (uyarlayabilirsin)
    try {
      final response = await http.post(
        Uri.parse("http://192.168.1.178:7109/api/User/update-profile"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "userId": _userService.userId,
          "name": updatedName,
          "email": updatedEmail,
        }),
      );

      if (response.statusCode == 200) {
        _userService.userName = updatedName;
        _userService.email = updatedEmail;
        notifyListeners();
        await _dialogService.showDialog(
          title: "Güncellendi",
          description: "Profil bilgileriniz kaydedildi.",
        );
      } else {
        await _dialogService.showDialog(
          title: "Hata",
          description: "Profil güncellenemedi: ${response.body}",
        );
      }
    } catch (e) {
      await _dialogService.showDialog(
        title: "Sunucu Hatası",
        description: "Profil güncellenirken hata oluştu: $e",
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }
}
