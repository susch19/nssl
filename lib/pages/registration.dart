//Some comment
import 'package:testProject/server_communication/return_classes.dart';
import 'package:testProject/server_communication/s_c.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:testProject/manager/file_manager.dart';
import 'package:testProject/models/model_export.dart';

class Registration extends StatefulWidget {
  Registration({Key key}) : super(key: key);

  static const String routeName = '/Registration';

  @override
  RegistrationState createState() => new RegistrationState();
}

class PersonData {
  String name = '';
  String email = '';
  String password = '';
}

class ForInput {
  TextEditingController textEditingController;
  String errorText = '';
  GlobalKey key = new GlobalKey();
}

class RegistrationState extends State<Registration> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  PersonData person = new PersonData();
  var nameInput = new ForInput();
  var emailInput = new ForInput();
  var pwInput = new ForInput();
  var pw2Input = new ForInput();
  var submit = new ForInput();

  void showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
        content: new Text(value), duration: new Duration(seconds: 3)));
  }

  void _handleSubmitted() {
    if (nameInput.textEditingController == null ||
        nameInput.textEditingController.text.isEmpty) {
      showInSnackBar("username has to be filled in");
      return;
    }
    if (emailInput.textEditingController == null ||
        emailInput.textEditingController.text.isEmpty) {
      showInSnackBar("email has to be filled in");
      return;
    }
    if (pwInput.textEditingController == null ||
        pw2Input.textEditingController == null ||
        pwInput.textEditingController != pw2Input.textEditingController ||
        pwInput.textEditingController.text.isEmpty) {
      showInSnackBar("passwords doesn't match or are empty");
      return;
    }
    if (_validateName(nameInput.textEditingController.text) != null) {
      showInSnackBar("There is something wrong with your username");
      return;
    } else if (_validateEmail(emailInput.textEditingController.text) != null) {
      showInSnackBar("There is something wrong with your email");
      return;
    } else if (_validatePassword(pwInput.textEditingController.text) != null) {
      showInSnackBar("There is something wrong with your password");
      return;
    } else if (_validatePassword2(pw2Input.textEditingController.text) !=
        null) {
      showInSnackBar("There is something wrong with your password validation");
      return;
    }

    String name = nameInput.textEditingController.text;
    String email = emailInput.textEditingController.text;
    String password = pwInput.textEditingController.text;

    print(JSON
        .encode(new LoginArgs(username: name, eMail: email, pwHash: password)));

    UserSync.create(name, email, password).then((res) {
      if (!HelperMethods.reactToRespone(res,
          scaffoldState: _scaffoldKey.currentState))
        return;
      else {
        var response = LoginResult.fromJson(res.body);
        if (!response.success) {
          showInSnackBar(response.error);
          return;
        }
        showInSnackBar("Registration successfull.");
        Navigator.pop(_scaffoldKey.currentContext);

        FileManager.write("token.txt", response.token);
        FileManager.write("User.txt", response.username);
        User.token = response.token;
        User.username = response.username;
      }
    });
  }

  String _validateName(String value) {
    if (value.isEmpty)
      return 'Name is required.';
    else if (value.length < 4)
      return 'Your username has to be at least 4 characters long';
    return null;
  }

  String _validateEmail(String value) {
    if (value.isEmpty) return 'EMail is required.';
    RegExp email = new RegExp(
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
    if (!email.hasMatch(value))
      return 'The email seems to be in the incorrect format.';
    return null;
  }

  String _validatePassword(String value) {
    if (pwInput.textEditingController == null ||
        pwInput.textEditingController.text.isEmpty)
      return 'Please choose a password.';
    return null;
  }

  String _validatePassword2(String value) {
    if (pw2Input.textEditingController == null ||
        pwInput.textEditingController.text.isEmpty)
      return 'Please reenter your password.';
    if (pwInput.textEditingController.text != value)
      return 'Passwords don\'t match';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(title: new Text('Registration')),
        body:
            new Container(
                padding: const EdgeInsets.all(32.0),
                child: new Column(children: [
                  new TextField(
                      decoration: new InputDecoration(
                        hintText: 'The name to login and to be found by others',
                        labelText: 'username',
                        errorText: nameInput.errorText,
                      ),
                      onChanged: (input) => setState(() {
                            nameInput.errorText = _validateName(input);
                          }),
                      controller: nameInput.textEditingController,
                      autofocus: true,
                      onSubmitted: (s) {
                        person.name = s;
                        //Focus.moveTo(emailInput.key);
                      }
                      ),

                  new TextField(
                      key: emailInput.key,
                      decoration: new InputDecoration(
                        hintText:
                            'The email to login and to be found by others',
                        labelText: 'Email',
                        errorText: emailInput.errorText,
                      ),
                      onChanged: (input) => setState(() {
                            emailInput.errorText = _validateEmail(input);
                            emailInput.textEditingController.text = input;
                          }),
                      controller: emailInput.textEditingController,
                      keyboardType: TextInputType.text,
                      onSubmitted: (s) {
                        person.email = s;
                        //Focus.moveTo(pwInput.key);
                      }),

                  new Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new Flexible(
                            child: new TextField(
                                key: pwInput.key,
                                decoration: new InputDecoration(
                                  hintText:
                                      'The password to secure your account',
                                  labelText: 'New Password',
                                  errorText: pwInput.errorText,
                                ),
                                onChanged: (input) => setState(() {
                                      pwInput.errorText =
                                          _validatePassword(input);
                                      pwInput.textEditingController.text =
                                          input;
                                      pw2Input.errorText = _validatePassword2(
                                          pw2Input.textEditingController.text);
                                    }),
                                controller: pwInput.textEditingController,
                                onSubmitted: (s) {
                                  person.password = s;
                                  //Focus.moveTo(pw2Input.key);
                                })),
                        new SizedBox(width: 16.0),
                        new Flexible(
                            child: new TextField(
                                key: pw2Input.key,
                                decoration: new InputDecoration(
                                  hintText:
                                      'Re-type your password, in case of a typo',
                                  labelText: 'Re-type Password',
                                  errorText: pw2Input.errorText,
                                ),
                                controller: pw2Input.textEditingController,
                                onChanged: (input) => setState(() {
                                      pw2Input.errorText =
                                          _validatePassword2(input);
                                      pw2Input.textEditingController.text =
                                          input;
                                    }),
                                onSubmitted: (s) {
                                  person.password = s;
                                  //Focus.moveTo(submit.key);
                                })),
                      ]),
                  new Container(
                    padding: const EdgeInsets.all(20.0),
                    alignment: const FractionalOffset(0.5, 0.5),
                    child: new RaisedButton(
                      key: submit.key,
                      child: new Text('REGISTER'),
                      onPressed: _handleSubmitted,
                    ),
                  )
                ])));
  }
}
