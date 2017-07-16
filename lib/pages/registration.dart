import 'package:testProject/localization/nssl_strings.dart';
import 'package:testProject/server_communication/return_classes.dart';
import 'package:testProject/server_communication/s_c.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:testProject/manager/file_manager.dart';
import 'package:testProject/models/model_export.dart';
import 'login.dart';

class Registration extends StatefulWidget {
  Registration({Key key}) : super(key: key);

  static const String routeName = '/Registration';

  @override
  RegistrationState createState() => new RegistrationState();
}

class RegistrationState extends State<Registration> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var nameInput = new ForInput();
  var emailInput = new ForInput();
  var pwInput = new ForInput();
  var pw2Input = new ForInput();
  var submit = new ForInput();

  NSSLStrings loc = NSSLStrings.instance;

  void showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
        content: new Text(value), duration: new Duration(seconds: 3)));
  }

  void _handleSubmitted() {
    bool error = false;
    _resetInput();

    String ni = _validateName(nameInput.textEditingController.text);
    String ei = _validateEmail(emailInput.textEditingController.text);
    String pi = _validatePassword(pwInput.textEditingController.text);
    String p2i = _validatePassword2(pw2Input.textEditingController.text);
    if (ni != null) {
      nameInput.decoration = new InputDecoration(
          labelText: nameInput.decoration.labelText,
          helperText: nameInput.decoration.helperText,
          errorText: ni);
      error = true;
    }
    if (ei != null) {
      emailInput.decoration = new InputDecoration(
          labelText: emailInput.decoration.labelText,
          helperText: emailInput.decoration.helperText,
          errorText: ei);
      error = true;
    }
    if (pi != null) {
      pwInput.decoration = new InputDecoration(
          labelText: pwInput.decoration.labelText,
          helperText: pwInput.decoration.helperText,
          errorText: pi);
      error = true;
    }
    if (p2i != null) {
      pw2Input.decoration = new InputDecoration(
          labelText: pw2Input.decoration.labelText,
          helperText: pw2Input.decoration.helperText,
          errorText: p2i);
      error = true;
    }
    if (pwInput.textEditingController.text != pw2Input.textEditingController.text) {
      pw2Input.decoration = new InputDecoration(
          labelText: pw2Input.decoration.labelText,
          helperText: pw2Input.decoration.helperText,
          errorText: loc.passwordsDontMatchError());
      error = true;
    }

    setState(() => {});
    if (error == true) return;
    String name = nameInput.textEditingController.text;
    String email = emailInput.textEditingController.text;
    String password = pwInput.textEditingController.text;


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
        showInSnackBar(loc.registrationSuccessfulMessage());
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
      return loc.usernameEmptyError();
    else if (value.length < 4) return loc.usernameToShortError();
    return null;
  }

  String _validateEmail(String value) {
    if (value.isEmpty) return loc.emailEmptyError();
    RegExp email = new RegExp(
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
    if (!email.hasMatch(value)) return loc.emailIncorrectFormatError();
    return null;
  }

  String _validatePassword(String value) {
    if (pwInput.textEditingController == null ||
        pwInput.textEditingController.text.isEmpty)
      return loc.chooseAPasswordPrompt();
    return null;
  }

  String _validatePassword2(String value) {
    if (pw2Input.textEditingController == null ||
        pwInput.textEditingController.text.isEmpty)
      return loc.reenterPasswordPrompt();
    if (pwInput.textEditingController.text != value)
      return loc.passwordsDontMatchError();
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(title: new Text(loc.registrationTitle())),
        body: new Container(
            padding: const EdgeInsets.all(32.0),
            child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  new TextField(
                      decoration: nameInput.decoration,
                      controller: nameInput.textEditingController,
                      autofocus: true,
                      onSubmitted: (s) {
                        FocusScope
                            .of(context)
                            .requestFocus(emailInput.focusNode);
                      }),
                  new TextField(
                      key: emailInput.key,
                      decoration: emailInput.decoration,
                      controller: emailInput.textEditingController,
                      focusNode: emailInput.focusNode,
                      keyboardType: TextInputType.emailAddress,
                      onSubmitted: (s) {
                        FocusScope.of(context).requestFocus(pwInput.focusNode);
                      }),
                  new Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new Flexible(
                            child: new TextField(
                                key: pwInput.key,
                                decoration: pwInput.decoration,
                                controller: pwInput.textEditingController,
                                focusNode: pwInput.focusNode,
                                obscureText: true,
                                onSubmitted: (s) {
                                  FocusScope
                                      .of(context)
                                      .requestFocus(pw2Input.focusNode);
                                })),
                        new SizedBox(width: 16.0),
                        new Flexible(
                            child: new TextField(
                                key: pw2Input.key,
                                decoration: pw2Input.decoration,
                                controller: pw2Input.textEditingController,
                                focusNode: pw2Input.focusNode,
                                obscureText: true,
                                onSubmitted: (s) {
                                  _handleSubmitted();
                                })),
                      ]),
                  new Container(
                    padding: const EdgeInsets.all(20.0),
                    alignment: const FractionalOffset(0.5, 0.5),
                    child: new RaisedButton(
                      key: submit.key,
                      child: new SizedBox.expand(
                        child: new Center(
                          child: new Text(loc.registerButton()),
                        ),
                      ),
                      onPressed: _handleSubmitted,
                    ),
                  )
                ])));
  }

  _resetInput() {
    nameInput.decoration = new InputDecoration(
        helperText: loc.usernameRegisterHint(), labelText: loc.username());

    emailInput.decoration = new InputDecoration(
        helperText: loc.emailRegisterHint(), labelText: loc.emailTitle());

    pwInput.decoration = new InputDecoration(
        helperText: loc.passwordRegisterHint(), labelText: loc.password());

    pw2Input.decoration = new InputDecoration(
        helperText: loc.retypePasswordHint(),
        labelText: loc.retypePasswordTitle());
  }

  @override
  initState() {
    super.initState();
    _resetInput();
  }
}
