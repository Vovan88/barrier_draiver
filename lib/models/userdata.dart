import 'dart:convert';

class User {
  User({
    required this.login,
    required this.password,
    required this.email,
    required this.telephone,
  });

  String login;
  String password;
  String email;
  String telephone;

  factory User.fromRawJson(String str) => User.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory User.fromJson(Map<String, dynamic> json) => User(
        login: json["login"],
        password: json["password"],
        email: json["email"],
        telephone: json["telephone"],
      );

  Map<String, dynamic> toJson() => {
        "login": login,
        "password": password,
        "email": email,
        "telephone": telephone,
      };
}
