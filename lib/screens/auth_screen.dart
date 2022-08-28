import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/userdata.dart';
import '../services/service.dart';
import 'cropimage_screen.dart';
import 'drive_screen.dart';
import 'package:image_picker/image_picker.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<RegistrationPage> createState() => _DrivePageState();
}

class _DrivePageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String errorMessage = '';
  bool showPassword = false;
  bool showPasswordRepeate = false;
  final String ruCharacters =
      "йцукенгшщзхъфывапролджэёячсмитьбюЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЁЯЧСМИТЬБЮ";
  final String engCharacters =
      "qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM";
  String passwordCheck = '';
  final TextEditingController loginController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController telephoneController = TextEditingController();
  File? _croppedFile;

  final FocusNode focusNodeLogin = FocusNode();

  final FocusNode focusNodePassword = FocusNode();

  final FocusNode focusNodeRePassword = FocusNode();

  final FocusNode focusNodeEmail = FocusNode();

  final FocusNode focusNodeTelephon = FocusNode();
  bool visibleProgress = false;
  bool validateEnable = false;
  Future<void> _saveToken(token) async {
    final SharedPreferences prefs = await _prefs;

    prefs.setString('token', token);
  }

  @override
  void dispose() {
    loginController.dispose();
    passwordController.dispose();
    emailController.dispose();
    telephoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  GestureDetector(
                    onTap: () => _addFromGallery(context: context),
                    child: CircleAvatar(
                      backgroundImage: _croppedFile != null
                          ? FileImage(_croppedFile!)
                          : Image.asset("assets/profile_image.png").image,
                      maxRadius: 70,
                    ),
                  ),
                  Form(
                    autovalidateMode: AutovalidateMode.always,
                    key: _formKey,
                    child: Wrap(spacing: 8, children: [
                      TextFormField(
                        focusNode: focusNodeLogin,
                        controller: loginController,
                        decoration: const InputDecoration(hintText: "логин"),
                        validator: (String? value) {
                          if (focusNodeLogin.hasFocus || validateEnable) {
                            if (value == null || value.isEmpty) {
                              return 'введите логин';
                            }
                            if (!engCharacters.contains(value[0])) {
                              return 'логин должен начинаться с латинской буквы';
                            }

                            if (value.length < 8) {
                              return 'логин должен быть не менее 8 символов';
                            }
                            if (ruCharacters
                                .contains(value[value.length - 1])) {
                              return 'логин должен содержать только латинские символы';
                            }
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        focusNode: focusNodePassword,
                        controller: passwordController,
                        obscureText: !showPassword,
                        decoration: InputDecoration(
                            hintText: "пароль",
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  showPassword = !showPassword;
                                });
                              },
                              icon: Icon(
                                showPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                size: 30.0,
                              ),
                            )),
                        validator: (String? value) {
                          if (focusNodePassword.hasFocus || validateEnable) {
                            if (value == null || value.isEmpty) {
                              return 'введите пароль';
                            }
                            if (value.length < 8) {
                              return 'пароль должен быть не менее 8 символов';
                            }
                            if (ruCharacters
                                .contains(value[value.length - 1])) {
                              'пароль должен содержать только латинские символы';
                            }
                            passwordCheck = value;
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        focusNode: focusNodeRePassword,
                        obscureText: !showPasswordRepeate,
                        decoration: InputDecoration(
                          hintText: "повторите пароль",
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                showPasswordRepeate = !showPasswordRepeate;
                              });
                            },
                            icon: Icon(
                              showPasswordRepeate
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              size: 30.0,
                            ),
                          ),
                        ),
                        validator: (String? value) {
                          if (focusNodeRePassword.hasFocus || validateEnable) {
                            if (value == null || value.isEmpty) {
                              return 'введите пароль';
                            }
                            if (value.length < 8) {
                              return 'пароль должен быть не менее 8 символов';
                            }
                            if (ruCharacters
                                .contains(value[value.length - 1])) {
                              return 'пароль должен содержать только латинские символы';
                            }
                            if (passwordCheck != value) {
                              return 'пароли не совпадают';
                            }
                          }

                          return null;
                        },
                      ),
                      TextFormField(
                          focusNode: focusNodeEmail,
                          controller: emailController,
                          decoration:
                              const InputDecoration(hintText: "ваш e-mail"),
                          validator: (String? value) {
                            if (focusNodeEmail.hasFocus || validateEnable) {
                              if (value == null || value.isEmpty) {
                                return 'введите e-mail';
                              }

                              if (!EmailValidator.validate(value)) {
                                return 'не корректный e-mail';
                              }
                            }
                            return null;
                          }),
                      TextFormField(
                          focusNode: focusNodeTelephon,
                          controller: telephoneController,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration:
                              const InputDecoration(hintText: "телефон"),
                          validator: (String? value) {
                            if (focusNodeTelephon.hasFocus || validateEnable) {
                              return validateMobile(value!);
                            }
                            return null;
                          }),
                      Text(
                        errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: TextButton(
                              style: ButtonStyle(
                                  foregroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.white),
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.green)),
                              onPressed: () {
                                validateEnable = true;
                                if (_formKey.currentState!.validate()) {
                                  setState(() {
                                    visibleProgress = true;
                                    errorMessage = '';
                                  });
                                  if (_croppedFile != null) {}

                                  User user = User(
                                      login: loginController.text,
                                      password: passwordController.text,
                                      email: emailController.text,
                                      telephone: telephoneController.text);

                                  getToken(user).then((value) async {
                                    await _saveToken(value.token);
                                    if (_croppedFile != null) {
                                      await sendAvatar(
                                          _croppedFile!, loginController.text);
                                    }

                                    setState(() {
                                      visibleProgress = false;
                                    });

                                    showModalBottomSheet<void>(
                                        isScrollControlled: true,
                                        context: context,
                                        builder: (BuildContext context) {
                                          return Padding(
                                              padding: EdgeInsets.only(
                                                bottom: MediaQuery.of(context)
                                                    .viewInsets
                                                    .bottom,
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(20.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    const Text(
                                                        "Регистрация успешна"),
                                                    TextButton(
                                                      style: ButtonStyle(
                                                          foregroundColor:
                                                              MaterialStateProperty
                                                                  .all<Color>(
                                                                      Colors
                                                                          .white),
                                                          backgroundColor:
                                                              MaterialStateProperty
                                                                  .all<Color>(
                                                                      Colors
                                                                          .green)),
                                                      onPressed: () {
                                                        Navigator
                                                            .pushReplacement(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder:
                                                                  (context) =>
                                                                      DrivePage(
                                                                        token: value
                                                                            .token,
                                                                        title:
                                                                            "Управление шлагбаумом",
                                                                      )),
                                                        );
                                                      },
                                                      child:
                                                          const Text("Далее"),
                                                    ),
                                                  ],
                                                ),
                                              ));
                                        });
                                  }).catchError((error) {
                                    setState(() {
                                      visibleProgress = false;
                                      errorMessage = error.toString();
                                    });
                                  });
                                }
                              },
                              child: const Text("Отправить")),
                        ),
                      ),
                      Center(
                        child: Visibility(
                            visible: visibleProgress,
                            child: const CircularProgressIndicator()),
                      ),
                    ]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  validateMobile(String value) {
    String pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
    RegExp regExp = RegExp(pattern);
    if (value.isEmpty) {
      return 'Введите номер телефона';
    } else if (!regExp.hasMatch(value)) {
      return 'Введите корректный номер телефона';
    }
    return null;
  }

  void _addFromGallery({required BuildContext context}) {
    ImagePicker()
        .pickImage(
      source: ImageSource.gallery,
    )
        .then((value) async {
      if (value != null) {
        _croppedFile = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return CropImagePage(
                  file: File(value.path),
                );
              },
              fullscreenDialog: true,
            ));
        if (_croppedFile != null) {
          setState(() {});
        }
      }
    });
  }
}
