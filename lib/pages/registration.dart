import 'dart:async';

import 'package:nssl/localization/nssl_strings.dart';
import 'package:nssl/main.dart';
import 'package:nssl/server_communication/return_classes.dart';
import 'package:nssl/server_communication/s_c.dart';
import 'package:flutter/material.dart';
import 'package:nssl/models/model_export.dart';
import '../helper/password_service.dart';
import 'login.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Registration extends ConsumerStatefulWidget {
  Registration({Key? key}) : super(key: key);

  static const String routeName = '/Registration';

  @override
  RegistrationState createState() => RegistrationState();
}

class RegistrationState extends ConsumerState<Registration> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  var nameInput = ForInput();
  var emailInput = ForInput();
  var pwInput = ForInput();
  var pw2Input = ForInput();
  var submit = ForInput();
  var validateMode = AutovalidateMode.disabled;
  bool initialized = false;

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value), duration: Duration(seconds: 3)));
  }

  Future _handleSubmitted() async {
    final FormState form = _formKey.currentState!;
    if (!form.validate()) {
      validateMode = AutovalidateMode.onUserInteraction;
      return;
    }

    String name = nameInput.textEditingController.text;
    String email = emailInput.textEditingController.text;
    String password = pwInput.textEditingController.text;

    var res = await UserSync.create(name, email, password, context);

    if (res.statusCode != 200)
      return;
    else {
      var response = LoginResult.fromJson(res.body);
      if (!response.success) {
        showInSnackBar(response.error);
        return;
      }
      showInSnackBar(NSSLStrings.of(context).registrationSuccessfulMessage());
      var x = await UserSync.login(name, password, context);

      if (x.statusCode != 200) {
        Navigator.pop(context);
        return;
      }
      var loginRes = LoginResult.fromJson(x.body);
      var userState = ref.watch(userStateProvider.notifier);
      User.token = loginRes.token;
      var user = User(loginRes.id, loginRes.username, loginRes.eMail);
      userState.state = user;
      ref.watch(currentListIndexProvider.notifier).state = 0;
      await user.save(0);

      // Navigator.pop(context);
      var restartState = ref.watch(appRestartProvider.notifier);
      restartState.state = restartState.state + 1;
    }
  }

  String? _validateName(String? value) {
    if (value!.isEmpty)
      return NSSLStrings.of(context).usernameEmptyError();
    else if (value.length < 4) return NSSLStrings.of(context).usernameToShortError();
    return null;
  }

  String? _validateEmail(String? value) {
    if (value!.isEmpty) return NSSLStrings.of(context).emailEmptyError();
    RegExp email = RegExp(
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
    if (!email.hasMatch(value)) return NSSLStrings.of(context).emailIncorrectFormatError();
    return null;
  }

  String? _validatePassword(String? value) {
    var errorCode = PasswordService.checkNewPassword(value ?? "");

    String errorText = "";
    if (errorCode != PasswordErrorCode.none) {
      switch (errorCode) {
        case PasswordErrorCode.empty:
          return NSSLStrings.of(context).passwordEmptyError();
        case PasswordErrorCode.none:
          return null;
        case PasswordErrorCode.tooShort:
          return NSSLStrings.of(context).passwordTooShortError();
        case PasswordErrorCode.missingCharacters:
          return NSSLStrings.of(context).passwordMissingCharactersError();
      }
    }
    return errorText;
  }

  String? _validatePassword2(String? value) {
    if (pwInput.textEditingController.text.isEmpty) return NSSLStrings.of(context).reenterPasswordPrompt();
    if (pwInput.textEditingController.text != value) return NSSLStrings.of(context).passwordsDontMatchError();
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (!initialized) _resetInput();
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(title: Text(NSSLStrings.of(context).registrationTitle())),
        body: Form(
            key: _formKey,
            autovalidateMode: validateMode,
            child: ListView(
//              physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                children: [
                  TextFormField(
                      decoration: nameInput.decoration,
                      controller: nameInput.textEditingController,
                      autofocus: true,
                      autocorrect: false,
                      validator: _validateName,
                      onSaved: (s) {
                        FocusScope.of(context).requestFocus(emailInput.focusNode);
                      }),
                  TextFormField(
                      key: emailInput.key,
                      decoration: emailInput.decoration,
                      controller: emailInput.textEditingController,
                      focusNode: emailInput.focusNode,
                      autocorrect: false,
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                      onSaved: (s) {
                        FocusScope.of(context).requestFocus(pwInput.focusNode);
                      }),
                  TextFormField(
                      key: pwInput.key,
                      decoration: pwInput.decoration,
                      controller: pwInput.textEditingController,
                      focusNode: pwInput.focusNode,
                      autocorrect: false,
                      obscureText: true,
                      validator: _validatePassword,
                      onSaved: (s) {
                        FocusScope.of(context).requestFocus(pw2Input.focusNode);
                      }),
                  TextFormField(
                      key: pw2Input.key,
                      decoration: pw2Input.decoration,
                      controller: pw2Input.textEditingController,
                      focusNode: pw2Input.focusNode,
                      autocorrect: false,
                      obscureText: true,
                      validator: _validatePassword2,
                      onSaved: (s) {
                        _handleSubmitted();
                      }),
                  Row(children: [
                    Flexible(
                        child: Container(
                      padding: const EdgeInsets.only(top: 20.0),
                      alignment: const FractionalOffset(0.5, 0.5),
                      child: ElevatedButton(
                        child: Center(
                          child: Text(NSSLStrings.of(context).registerButton()),
                        ),
                        onPressed: _handleSubmitted,
                      ),
                    ))
                  ])
                  /*
                   Container(
                    padding: const EdgeInsets.all(20.0),
                    alignment: const FractionalOffset(0.5, 0.5),
                    child:
                  ElevatedButton(
                    key: submit.key,
                    child: SizedBox.expand(
                      child: Center(
                        child:
                            Text(NSSLStrings.of(context).registerButton()),
                      ),
                    ),
                    onPressed: _handleSubmitted,
                    ),
                  )*/
                ])));
  }

  _resetInput() {
    nameInput.decoration = InputDecoration(
        helperText: NSSLStrings.of(context).usernameRegisterHint(), labelText: NSSLStrings.of(context).username());

    emailInput.decoration = InputDecoration(
        helperText: NSSLStrings.of(context).emailRegisterHint(), labelText: NSSLStrings.of(context).emailTitle());

    pwInput.decoration = InputDecoration(
        helperText: NSSLStrings.of(context).passwordRegisterHint(), labelText: NSSLStrings.of(context).password());

    pw2Input.decoration = InputDecoration(
        helperText: NSSLStrings.of(context).retypePasswordHint(),
        labelText: NSSLStrings.of(context).retypePasswordTitle());
    initialized = true;
  }
}
