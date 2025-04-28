class UserService {
  int? userId;
  String? userName;
  String? email;
  double successRate = 0;

  bool get isLoggedIn => userId != null;

  void setUser({
    required int id,
    required String name,
    required String mail,
    double? success,
  }) {
    userId = id;
    userName = name;
    email = mail;
    successRate = success ?? 0;
  }

  void clearUser() {
    userId = null;
    userName = null;
    email = null;
    successRate = 0;
  }
}
