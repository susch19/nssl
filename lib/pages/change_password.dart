import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:testProject/localization/nssl_strings.dart';
import 'package:testProject/models/user.dart';
import 'package:testProject/pages/login.dart';
import 'package:testProject/server_communication/return_classes.dart';
import 'package:testProject/server_communication/s_c.dart';

class ChangePasswordPage extends StatefulWidget {
  ChangePasswordPage({Key key, this.scaffoldKey}) : super(key: key);

  final GlobalKey<ScaffoldState> scaffoldKey;
  @override
  ChangePasswordPageState createState() => new ChangePasswordPageState();
}

class ChangePasswordPageState extends State<ChangePasswordPage> {
  ChangePasswordPageState() : super();
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var oldPwInput = new ForInput();
  var newPwInput = new ForInput();
  var newPw2Input = new ForInput();

  void showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
        content: new Text(value), duration: new Duration(seconds: 3)));
  }

  void _handleSubmitted() {
    bool error = false;
    _resetInput();

    if (_validateEmpty(oldPwInput.textEditingController)) {
      oldPwInput.decoration = new InputDecoration(
          labelText: oldPwInput.decoration.labelText,
          helperText: oldPwInput.decoration.helperText,
          errorText: NSSLStrings.of(context).passwordEmptyError());
      error = true;
    }
    if (_validateEmpty(newPwInput.textEditingController)) {
      newPwInput.decoration = new InputDecoration(
          labelText: newPwInput.decoration.labelText,
          helperText: newPwInput.decoration.helperText,
          errorText: NSSLStrings.of(context).passwordEmptyError());
      error = true;
    }
    if (_validateEmpty(newPw2Input.textEditingController)) {
      newPw2Input.decoration = new InputDecoration(
          labelText: newPw2Input.decoration.labelText,
          helperText: newPw2Input.decoration.helperText,
          errorText: NSSLStrings.of(context).passwordEmptyError());
      error = true;
    }
    setState(() => {});
    if (error == true) return;
    if (newPwInput.textEditingController.text !=
        newPw2Input.textEditingController.text) {
      newPw2Input.decoration = new InputDecoration(
          labelText: newPw2Input.decoration.labelText,
          helperText: newPw2Input.decoration.helperText,
          errorText: NSSLStrings.of(context).passwordsDontMatchError());
      setState(() => {});
      return;
    }
    _changePassword();
  }

  bool _validateEmpty(TextEditingController value) =>
      (value == null || value.text.isEmpty);

  _changePassword() async {
    var res = await UserSync.changePassword(
        oldPwInput.textEditingController.text,
        newPwInput.textEditingController.text,
        User.token,
        context);
    if (res.statusCode != 200) {
      _scaffoldKey.currentState.showSnackBar(new SnackBar(
          content: new Text(res.reasonPhrase),
          duration: new Duration(seconds: 3)));
      return;
    }
    var obj = Result.fromJson(res.body);
    if (!obj.success) {
      _scaffoldKey.currentState.showSnackBar(new SnackBar(
          content: new Text(obj.error), duration: new Duration(seconds: 3)));
      return;
    }
    var dialog = new AlertDialog(
        title: new Text(NSSLStrings.of(context).successful()),
        content: new SingleChildScrollView(
          child: new ListBody(
            children: <Widget>[new Text(NSSLStrings.of(context).passwordSet())],
          ),
        ),
        actions: <Widget>[
          new FlatButton(
              child: const Text("OK"),
              onPressed: () => Navigator.popUntil(context, (r) => r.isFirst)),
        ]);
    showDialog(context: context, builder: (BuildContext context) => dialog);
  }

  _resetInput() {
    oldPwInput.decoration = new InputDecoration(
        helperText: NSSLStrings.of(context).oldPasswordHint(),
        labelText: NSSLStrings.of(context).oldPassword());
    newPwInput.decoration = new InputDecoration(
        helperText: NSSLStrings.of(context).newPasswordHint(),
        labelText: NSSLStrings.of(context).newPassword());
    newPw2Input.decoration = new InputDecoration(
        helperText: NSSLStrings.of(context).new2PasswordHint(),
        labelText: NSSLStrings.of(context).new2Password());
  }

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _resetInput();
    return new Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomPadding: false,
      appBar: new AppBar(
          title: new Text(NSSLStrings.of(context).changePasswordPD())),
      body: new Container(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child:
            new Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          new Flexible(
            child: new TextField(
              key: oldPwInput.key,
              decoration: oldPwInput.decoration,
              focusNode: oldPwInput.focusNode,
              obscureText: true,
              controller: oldPwInput.textEditingController,
              onSubmitted: (val) {
                FocusScope.of(context).requestFocus(newPwInput.focusNode);
              },
            ),
          ),
          new Flexible(
            child: new TextField(
              key: newPwInput.key,
              decoration: newPwInput.decoration,
              focusNode: newPwInput.focusNode,
              obscureText: true,
              controller: newPwInput.textEditingController,
              onSubmitted: (val) {
                FocusScope.of(context).requestFocus(newPw2Input.focusNode);
              },
            ),
          ),
          new Flexible(
            child: new TextField(
              key: newPw2Input.key,
              decoration: newPw2Input.decoration,
              focusNode: newPw2Input.focusNode,
              obscureText: true,
              controller: newPw2Input.textEditingController,
              onSubmitted: (val) {
                _handleSubmitted();
              },
            ),
          ),
          new Flexible(
            child: new Container(
              padding: const EdgeInsets.only(top: 32.0),
              child: new RaisedButton(
//                child: new Center(
                  child: new Text(
                    NSSLStrings.of(context).changePasswordButton(),
                  ),
//                ),
                onPressed: _handleSubmitted,
            ),
              /*
              new FlatButton(
                onPressed: () {
                      Navigator.pushNamed(context, "/forgot_password");
                },
                child: new Text(NSSLStrings.of(context).forgotPassword()),
              )*/

              //padding: new EdgeInsets.only(
              //    top: MediaQuery.of(context).size.height / 5),
            ),
          ),
//          new Flexible(
//            child: new Container(
//
//                padding: const EdgeInsets.only(top: 16.0)),
//          ),
        ]),
      ),
    );
  }
}
