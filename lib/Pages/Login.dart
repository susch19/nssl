//Some comment
import 'package:testProject/ServerCommunication/SC.dart';
import 'package:testProject/Manager/FileManager.dart';
import 'package:testProject/Models/Models.dart';
import 'package:flutter/material.dart';

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

    if (pwInput.textEditingController == null ||
        pwInput.textEditingController.text.isEmpty) {
      showInSnackBar("password can't be left empty");
      return;
    }
    if (_validateName(nameInput.textEditingController.text) != null) {
      showInSnackBar("There is something wrong with your username");
      return;
    } else if (_validatePassword(pwInput.textEditingController.text) != null) {
      showInSnackBar("There is something wrong with your password");
      return;
    }

    String name = nameInput.textEditingController.text;
    String password = pwInput.textEditingController.text;

    if (_validateEmail(nameInput.textEditingController.text) == null) {
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

  void _handleLoggedIn(LoginResult res) {
    if (!res.success) {
      showInSnackBar(res.error);
      return;
    }
    showInSnackBar("Login successfull.");
    FileManager.write("token.txt", res.token);
    FileManager.write("User.txt", res.username);
    User.token = res.token;
    User.username = res.username;
    Navigator.pop(context);
  }

  String _validateName(String value) {
    if (value.isEmpty) return 'Name or Email is required.';
    if (value.length < 4)
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

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(title: const Text("Login")),
        body: new Column(children: [
          new Center(
              child: new Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: new Column(children: [
                    new TextField(
                        decoration: new InputDecoration(
                          hintText: 'The name or email can be used to login',
                          labelText: 'Username or Email',
                          errorText: nameInput.errorText,
                        ),
                        onChanged: (input) =>
                            nameInput.errorText = _validateName(input),
                        controller: nameInput.textEditingController,
                        autofocus: true,
                        onSubmitted: (val) {
                          //Focus.moveTo(pwInput.key);
                        }),
                    new TextField(
                        key: pwInput.key,
                        decoration: new InputDecoration(
                          hintText: 'The password you choose for the username',
                          labelText: 'Password',
                          errorText: pwInput.errorText,
                        ),
                        obscureText: true,
                        // onChanged: (input) => setState(() {
                        //      pwInput.errorText = _validatePassword(input);
                        //   }),
                        controller: pwInput.textEditingController,
                        onSubmitted: (val) {
                          //Focus.moveTo(submit.key);
                        }),
                    new Container(
                        child: new RaisedButton(
                          key: submit.key,
                          child: new SizedBox.expand(
                              child: new Center(child: const Text('Login'))),
                          onPressed: _handleSubmitted,
                        ),
                        padding: const EdgeInsets.only(top: 16.0)),
                    new Container(
                        child: new FlatButton(
                          onPressed: () {
                            Navigator.popAndPushNamed(context, "/registration");

                          },
                          child: const Text(
                              "Don't have an account? Create one now."),
                        ),
                        padding: const EdgeInsets.only(top: 72.0))
                  ])))
        ], mainAxisAlignment: MainAxisAlignment.center));
  }
}
