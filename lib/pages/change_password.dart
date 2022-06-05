import 'package:flutter/material.dart';
import 'package:nssl/localization/nssl_strings.dart';
import 'package:nssl/models/user.dart';
import 'package:nssl/pages/login.dart';
import 'package:nssl/server_communication/return_classes.dart';
import 'package:nssl/server_communication/s_c.dart';

class ChangePasswordPage extends StatefulWidget {
  ChangePasswordPage({Key? key, this.scaffoldKey}) : super(key: key);

  final GlobalKey<ScaffoldState>? scaffoldKey;
  @override
  ChangePasswordPageState createState() => ChangePasswordPageState();
}

class ChangePasswordPageState extends State<ChangePasswordPage> {
  ChangePasswordPageState() : super();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  var oldPwInput = ForInput();
  var newPwInput = ForInput();
  var newPw2Input = ForInput();

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value), duration: Duration(seconds: 3)));
  }

  void _handleSubmitted() {
    bool error = false;
    _resetInput();

    if (_validateEmpty(oldPwInput.textEditingController)) {
      oldPwInput.decoration = InputDecoration(
          labelText: oldPwInput.decoration!.labelText,
          helperText: oldPwInput.decoration!.helperText,
          errorText: NSSLStrings.of(context).passwordEmptyError());
      error = true;
    }
    if (_validateEmpty(newPwInput.textEditingController)) {
      newPwInput.decoration = InputDecoration(
          labelText: newPwInput.decoration!.labelText,
          helperText: newPwInput.decoration!.helperText,
          errorText: NSSLStrings.of(context).passwordEmptyError());
      error = true;
    }
    if (_validateEmpty(newPw2Input.textEditingController)) {
      newPw2Input.decoration = InputDecoration(
          labelText: newPw2Input.decoration!.labelText,
          helperText: newPw2Input.decoration!.helperText,
          errorText: NSSLStrings.of(context).passwordEmptyError());
      error = true;
    }
    if (error == true) return;
    if (newPwInput.textEditingController.text != newPw2Input.textEditingController.text) {
      newPw2Input.decoration = InputDecoration(
          labelText: newPw2Input.decoration!.labelText,
          helperText: newPw2Input.decoration!.helperText,
          errorText: NSSLStrings.of(context).passwordsDontMatchError());
      return;
    }
    _changePassword();
  }

  bool _validateEmpty(TextEditingController value) => (value.text.isEmpty);

  _changePassword() async {
    var res = await UserSync.changePassword(
        oldPwInput.textEditingController.text, newPwInput.textEditingController.text, User.token, context);
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
    oldPwInput.decoration = InputDecoration(
        helperText: NSSLStrings.of(context).oldPasswordHint(), labelText: NSSLStrings.of(context).oldPassword());
    newPwInput.decoration = InputDecoration(
        helperText: NSSLStrings.of(context).newPasswordHint(), labelText: NSSLStrings.of(context).newPassword());
    newPw2Input.decoration = InputDecoration(
        helperText: NSSLStrings.of(context).new2PasswordHint(), labelText: NSSLStrings.of(context).new2Password());
  }

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _resetInput();
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text(NSSLStrings.of(context).changePasswordPD())),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          Flexible(
            child: TextField(
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
          Flexible(
            child: TextField(
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
          Flexible(
            child: TextField(
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
