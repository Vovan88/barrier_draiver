import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:barrier_drive/models/userdata.dart';
import 'package:http/http.dart' as http;

import 'package:http_parser/http_parser.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/answer.dart';

String address = "http://62.33.74.81:24024";

Future<Token> getToken(User user) async {
  var uri = Uri.parse("$address/userdata");

  try {
    Map<String, String> headers = <String, String>{};
    headers["content-type"] = 'application/json; charset=UTF-8';

    var response =
        await http.post(uri, headers: headers, body: user.toRawJson());
    if (response.statusCode == 200) {
      if (response.body == "loginexist") {
        return Future.error("Пользователь с таким логином уже существует");
      }

      return Token.fromJson(jsonDecode(response.body));
    } else {
      return Future.error("Ошибка сервера");
    }
  } on TimeoutException {
    return Future.error("Сервер не ответил вовремя");
  } on SocketException {
    return Future.error("Сервер не ответил вовремя");
  }
}

Future<Status> getStatus(token) async {
  var uri = Uri.parse("$address/getstatus");

  try {
    Map<String, String> headers = <String, String>{};
    headers["content-type"] = 'application/json; charset=UTF-8';
    headers["token"] = token;
    var response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      return Status.fromJson(jsonDecode(response.body));
    } else {
      return Future.error("Ошибка сервера");
    }
  } on TimeoutException {
    return Future.error("Сервер не ответил вовремя");
  } on SocketException {
    return Future.error("Сервер не ответил вовремя");
  }
}

Future<Status> setStatus(token) async {
  var uri = Uri.parse("$address/setstatus");

  try {
    Map<String, String> headers = <String, String>{};
    headers["content-type"] = 'application/json; charset=UTF-8';
    headers["token"] = token;
    var response = await http.put(
      uri,
      headers: headers,
    );
    if (response.statusCode == 200) {
      return Status.fromJson(jsonDecode(response.body));
    } else {
      return Future.error("Ошибка сервера");
    }
  } on TimeoutException {
    return Future.error("Сервер не ответил вовремя");
  } on SocketException {
    return Future.error("Сервер не ответил вовремя");
  }
}

Future<User> getUser(token) async {
  var uri = Uri.parse("$address/getuser");

  try {
    Map<String, String> headers = <String, String>{};
    headers["content-type"] = 'application/json; charset=UTF-8';
    headers["token"] = token;
    var response = await http.post(uri, headers: headers);
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      return Future.error("Ошибка сервера");
    }
  } on TimeoutException {
    return Future.error("Сервер не ответил вовремя");
  } on SocketException {
    return Future.error("Нет интернета");
  }
}

Future<void> logoff(token) async {
  var uri = Uri.parse("$address/logoff");

  try {
    Map<String, String> headers = <String, String>{};
    headers["content-type"] = 'application/json; charset=UTF-8';
    headers["token"] = token;
    var response = await http.post(uri, headers: headers);
    if (response.statusCode != 200) {
      return Future.error("Ошибка сервера");
    }
  } on TimeoutException {
    return Future.error("Сервер не ответил вовремя");
  } on SocketException {
    return Future.error("Нет интернета");
  }
}

Future<void> sendAvatar(File file, login) async {
  var uri = Uri.parse("$address/avatar");
  var request = http.MultipartRequest("POST", uri);
  request.fields['login'] = login;
  request.headers.addAll({"Content-Type": "multipart/form-data;"});
  try {
    request.files.add(await http.MultipartFile.fromPath(
      'file',
      file.path,
      contentType: MediaType('image', 'jpeg'),
    ));
    final response = await request.send();
    if (response.statusCode != 200) {
      return Future.error("Ошибка сервера: ${response.statusCode}");
    }
  } on TimeoutException {
    return Future.error("Сервер не ответил вовремя");
  } on SocketException catch (e) {
    return Future.error("Ошибка сервера: ${e.message}");
  }
}

Future<String> checkAuth() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString("token") ?? "";
}
