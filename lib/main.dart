import 'package:flutter/material.dart';

import 'screens/auth_screen.dart';
import 'screens/drive_screen.dart';
import 'services/service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Управление шлагбаумом',
        theme: ThemeData(
          primarySwatch: Colors.grey,
        ),
        home: FutureBuilder<String>(
            future: checkAuth(),
            builder: (context, AsyncSnapshot<String> snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data != "") {
                  return DrivePage(
                      token: snapshot.data!, title: "Управление шлагбаумом");
                } else {
                  return const RegistrationPage(title: "Регистрация");
                }
              }

              return const Center(child: CircularProgressIndicator());
            }));
  }
}
