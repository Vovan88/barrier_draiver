import 'dart:async';

import 'package:barrier_drive/main.dart';

import 'package:barrier_drive/screens/qr_reader_screen.dart';
import 'package:barrier_drive/services/service.dart';
import 'package:barrier_drive/widgets.dart/status_widget.dart';
import 'package:barrier_drive/widgets.dart/user_widget.dart';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/answer.dart';

class DrivePage extends StatefulWidget {
  const DrivePage({Key? key, required this.title, required this.token})
      : super(key: key);

  final String title;
  final String token;
  @override
  State<DrivePage> createState() => _DrivePageState();
}

class _DrivePageState extends State<DrivePage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
              onPressed: () {
                _logoff(widget.token).then((value) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return const MyApp();
                        },
                        fullscreenDialog: true,
                      ));
                }).catchError((error) {});
              },
              icon: const Icon(Icons.logout))
        ],
      ),
      body: Column(
        children: [
          Flexible(
            flex: 1,
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Flexible(
                      child: UserWidget(
                    token: widget.token,
                  )),
                  Flexible(
                    child: Column(
                      children: [
                        Flexible(
                          child: QrImage(
                            data: Token(token: widget.token).toRawJson(),
                            version: QrVersions.auto,
                          ),
                        ),
                        TextButton(
                          style: ButtonStyle(
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  Colors.white),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.green)),
                          onPressed: () {
                            Navigator.of(context)
                                .pushReplacement(MaterialPageRoute(
                              builder: (context) => const QRViewReader(),
                            ));
                          },
                          child: const Text("Авторизация по QR"),
                        ),
                      ],
                    ),
                  )
                ]),
          ),
          Flexible(
            flex: 3,
            child: Center(
              child: StatusWidget(
                token: widget.token,
              ),
            ),
          ),
        ],
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<void> _logoff(token) async {
    await _removeToken();

    await logoff(token);
  }

  Future<void> _removeToken() async {
    final SharedPreferences prefs = await _prefs;

    prefs.remove('token');
  }
}
