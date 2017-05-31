//Some comment

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:testProject/localization/nssl_strings.dart';
import 'package:testProject/main.dart';
import 'package:testProject/manager/file_manager.dart';
import 'package:testProject/models/user.dart';
import 'package:testProject/server_communication/helper_methods.dart';
import 'package:testProject/server_communication/return_classes.dart';
import 'package:testProject/server_communication/user_sync.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.scaffoldKey}) : super(key: key);

  final GlobalKey<ScaffoldState> scaffoldKey;
  @override
  LoginPageState createState() => new LoginPageState();
}

class PersonData {
  String name = '';
  String email = '';
  String password = '';
}

class ForInput {
  TextEditingController textEditingController = new TextEditingController();
  String errorText = '';
  GlobalKey key = new GlobalKey();
}

class LoginPageState extends State<LoginPage> {
  LoginPageState() : super();
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var nameInput = new ForInput();
  var pwInput = new ForInput();
  var submit = new ForInput();

  NSSLStrings loc = NSSLStrings.instance;

  void showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
        content: new Text(value), duration: new Duration(seconds: 3)));
  }

  void _handleSubmitted() {
    if (nameInput.textEditingController == null ||
        nameInput.textEditingController.text.isEmpty) {
      showInSnackBar(loc.usernameEmptyError());
      return;
    }

    if (pwInput.textEditingController == null ||
        pwInput.textEditingController.text.isEmpty) {
      showInSnackBar(loc.passwordEmptyError());
      return;
    }
    if (_validateName(nameInput.textEditingController.text) != null) {
      showInSnackBar(loc.unknownUsernameError());
      return;
    } else if (_validatePassword(pwInput.textEditingController.text) != null) {
      showInSnackBar(loc.unknownPasswordError());
      return;
    }

    String name = nameInput.textEditingController.text;
    String password = pwInput.textEditingController.text;

    if (_validateEmail(nameInput.textEditingController.text) != null) {
      UserSync.login(name, password).then((res) {
        if (!HelperMethods.reactToRespone(res,
            scaffoldState: _scaffoldKey?.currentState))
          return;
        else
          _handleLoggedIn(LoginResult.fromJson(res.body));
      });
    } else {
      UserSync.loginEmail(name, password).then((res) {
        if (!HelperMethods.reactToRespone(res,
            scaffoldState: _scaffoldKey?.currentState))
          return;
        else
          _handleLoggedIn(LoginResult.fromJson(res.body));
      });
    }
  }

  Future _handleLoggedIn(LoginResult res) async{
    if (!res.success) {
      showInSnackBar(res.error);
      return;
    }
    showInSnackBar(loc.loginSuccessfulMessage());
    await FileManager.write("token.txt", res.token);
    if (FileManager.fileExists("User.txt"))
      await FileManager.deleteFile("User.txt");
    await FileManager.createFile("User.txt");
    await FileManager.writeln("User.txt", res.username);
    await FileManager.writeln("User.txt", res.eMail, append: true);
    bool firstBoot = User.username == null;
    User.token = res.token;
    User.username = res.username;
    User.eMail = res.eMail;
    firstBoot ? runApp(new NSSL()) : Navigator.pop(context);
  }

  String _validateName(String value) {
    if (value.isEmpty) return loc.nameEmailRequiredError();
    if (value.length < 4)
      return loc.usernameToShortError();
    return null;
  }

  String _validateEmail(String value) {
    if (value.isEmpty) return loc.emailRequiredError();
    RegExp email = new RegExp(
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
    if (!email.hasMatch(value))
      return loc.emailIncorrectFormatError();
    return null;
  }

  String _validatePassword(String value) {
    if (pwInput.textEditingController == null ||
        pwInput.textEditingController.text.isEmpty)
      return loc.chooseAPasswordPrompt();
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(title: new Text(loc.login())),
      body: new Container(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child:
            new Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          new TextField(
              decoration: new InputDecoration(
                hintText: loc.usernameOrEmailForLoginHint(),
                labelText: loc.usernameOrEmailTitle(),
                errorText: nameInput.errorText,
              ),
              onChanged: (input) => nameInput.errorText = _validateName(input),
              controller: nameInput.textEditingController,
              autofocus: true,
              onSubmitted: (val) {
                //Focus.moveTo(pwInput.key);
              }),
          new TextField(
              key: pwInput.key,
              decoration: new InputDecoration(
                hintText: loc.choosenPasswordHint(),
                labelText: loc.password(),
                errorText: pwInput.errorText,
              ),
              obscureText: true,
              controller: pwInput.textEditingController,
              onSubmitted: (val) {
                //Focus.moveTo(submit.key);
              }),
          new Container(
              child: new RaisedButton(
                key: submit.key,
                child: new SizedBox.expand(
                    child: new Center(child: new Text(loc.loginButton()))),
                onPressed: _handleSubmitted,
              ),
              padding: const EdgeInsets.only(top: 16.0)),
          new Container(
            child: new FlatButton(
              onPressed: () {
                User.username == null
                    ? Navigator.pushNamed(context, "/registration")
                    : Navigator.popAndPushNamed(context, "/registration");
              },
              child: new Text(loc.registerTextOnLogin()),
            ),
            padding: const EdgeInsets.only(top: 72.0),
          )
        ]),
      ),
    );
  }
}
