import 'package:flutter/material.dart';
import 'package:nssl/localization/nssl_strings.dart';
import 'package:nssl/models/user.dart';
import 'package:nssl/pages/login.dart';
import 'package:nssl/server_communication/return_classes.dart';
import 'package:nssl/server_communication/s_c.dart';

import '../helper/password_service.dart';

class ChangePasswordPage extends StatefulWidget {
  ChangePasswordPage({Key? key, this.scaffoldKey}) : super(key: key);

  final GlobalKey<ScaffoldState>? scaffoldKey;
  @override
  ChangePasswordPageState createState() => ChangePasswordPageState();
}

class ChangePasswordPageState extends State<ChangePasswordPage> {
  ChangePasswordPageState() : super();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  var _oldPwInput = ForInput();
  var _newPwInput = ForInput();
  var _newPw2Input = ForInput();
  bool _initialized = false;

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value), duration: Duration(seconds: 3)));
  }

  void _handleSubmitted() {
    bool error = false;
    _resetInput();

    if (_validateEmpty(_oldPwInput.textEditingController)) {
      _oldPwInput.decoration = InputDecoration(
          labelText: _oldPwInput.decoration!.labelText,
          helperText: _oldPwInput.decoration!.helperText,
          errorText: NSSLStrings.of(context).passwordEmptyError());
      error = true;
    }
    var errorCode = PasswordService.checkNewPassword(_newPwInput.textEditingController.text);

    if (errorCode != PasswordErrorCode.none) {
      String errorText = "";
      switch (errorCode) {
        case PasswordErrorCode.empty:
          errorText = NSSLStrings.of(context).passwordEmptyError();
          break;
        case PasswordErrorCode.none:
          break;
        case PasswordErrorCode.tooShort:
          errorText = NSSLStrings.of(context).passwordTooShortError();
          break;
        case PasswordErrorCode.missingCharacters:
          errorText = NSSLStrings.of(context).passwordMissingCharactersError();
          break;
      }

      _newPwInput.decoration = InputDecoration(
          labelText: _newPwInput.decoration!.labelText,
          helperText: _newPwInput.decoration!.helperText,
          errorText: errorText);
      error = true;
    }
    if (_validateEmpty(_newPw2Input.textEditingController)) {
      _newPw2Input.decoration = InputDecoration(
          labelText: _newPw2Input.decoration!.labelText,
          helperText: _newPw2Input.decoration!.helperText,
          errorText: NSSLStrings.of(context).passwordEmptyError());
      error = true;
    }
    if (error == true) {
      setState(() {});
      return;
    }
    if (_newPwInput.textEditingController.text != _newPw2Input.textEditingController.text) {
      _newPw2Input.decoration = InputDecoration(
          labelText: _newPw2Input.decoration!.labelText,
          helperText: _newPw2Input.decoration!.helperText,
          errorText: NSSLStrings.of(context).passwordsDontMatchError());
      setState(() {});
      return;
    }
    _changePassword();
  }

  bool _validateEmpty(TextEditingController value) => (value.text.isEmpty);

  _changePassword() async {
    var res = await UserSync.changePassword(
        _oldPwInput.textEditingController.text, _newPwInput.textEditingController.text, User.token, context);
    if (res.statusCode != 200) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(res.reasonPhrase!), duration: Duration(seconds: 3)));
      return;
    }
    var obj = Result.fromJson(res.body);
    if (!obj.success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(obj.error), duration: Duration(seconds: 3)));
      return;
    }
    var dialog = AlertDialog(
        title: Text(NSSLStrings.of(context).successful()),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[Text(NSSLStrings.of(context).passwordSet())],
          ),
        ),
        actions: <Widget>[
          TextButton(child: const Text("OK"), onPressed: () => Navigator.popUntil(context, (r) => r.isFirst)),
        ]);
    showDialog(context: context, builder: (BuildContext context) => dialog);
  }

  _resetInput() {
    _oldPwInput.decoration = InputDecoration(
        helperText: NSSLStrings.of(context).oldPasswordHint(), labelText: NSSLStrings.of(context).oldPassword());
    _newPwInput.decoration = InputDecoration(
        helperText: NSSLStrings.of(context).newPasswordHint(), labelText: NSSLStrings.of(context).newPassword());
    _newPw2Input.decoration = InputDecoration(
        helperText: NSSLStrings.of(context).new2PasswordHint(), labelText: NSSLStrings.of(context).new2Password());
    _initialized = true;
  }

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) _resetInput();
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text(NSSLStrings.of(context).changePasswordPD())),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          Flexible(
            child: TextField(
              key: _oldPwInput.key,
              decoration: _oldPwInput.decoration,
              focusNode: _oldPwInput.focusNode,
              obscureText: true,
              controller: _oldPwInput.textEditingController,
              onSubmitted: (val) {
                FocusScope.of(context).requestFocus(_newPwInput.focusNode);
              },
            ),
          ),
          Flexible(
            child: TextField(
              key: _newPwInput.key,
              decoration: _newPwInput.decoration,
              focusNode: _newPwInput.focusNode,
              obscureText: true,
              controller: _newPwInput.textEditingController,
              onSubmitted: (val) {
                FocusScope.of(context).requestFocus(_newPw2Input.focusNode);
              },
            ),
          ),
          Flexible(
            child: TextField(
              key: _newPw2Input.key,
              decoration: _newPw2Input.decoration,
              focusNode: _newPw2Input.focusNode,
              obscureText: true,
              controller: _newPw2Input.textEditingController,
              onSubmitted: (val) {
                _handleSubmitted();
              },
            ),
          ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.only(top: 32.0),
              child: ElevatedButton(
//                child: Center(
                child: Text(
                  NSSLStrings.of(context).changePasswordButton(),
                ),
//                ),
                onPressed: _handleSubmitted,
              ),
              /*
              TextButton(
                onPressed: () {
                      Navigator.pushNamed(context, "/forgot_password");
                },
                child: Text(NSSLStrings.of(context).forgotPassword()),
              )*/

              //padding: EdgeInsets.only(
              //    top: MediaQuery.of(context).size.height / 5),
            ),
          ),
//          Flexible(
//            child: Container(
//
//                padding: const EdgeInsets.only(top: 16.0)),
//          ),
        ]),
      ),
    );
  }
}
