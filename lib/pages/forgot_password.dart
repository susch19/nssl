import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nssl/localization/nssl_strings.dart';
import 'package:nssl/server_communication/s_c.dart';

class ForgotPasswordPage extends StatefulWidget {
  ForgotPasswordPage({Key? key, this.scaffoldKey}) : super(key: key);

  final GlobalKey<ScaffoldState>? scaffoldKey;
  @override
  ForgotPasswordPageState createState() => ForgotPasswordPageState();
}

class PersonData {
  String name = '';
  String email = '';
  String password = '';
}

class ForInput {
  TextEditingController textEditingController = TextEditingController();
  String errorText = '';
  GlobalKey key = GlobalKey();
  InputDecoration? decoration;
  FocusNode focusNode = FocusNode();
}

class ForgotPasswordPageState extends State<ForgotPasswordPage> {
  ForgotPasswordPageState() : super();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  var emailInput = ForInput();
  var submit = ForInput();
  var validateMode = AutovalidateMode.disabled;

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(value), duration: Duration(seconds: 3)));
  }

  Future _handleSubmitted() async {
    final FormState form = _formKey.currentState!;
    if (!form.validate()) {
      validateMode = AutovalidateMode.onUserInteraction;
      return;
    }

    String email = emailInput.textEditingController.text;

    if (emailInput.textEditingController.text.length > 0 &&
        _validateEmail(emailInput.textEditingController.text) == null) {
      var res = await UserSync.resetPassword(email, context);
      if (!HelperMethods.reactToRespone(res, context,
          scaffoldState: _scaffoldKey.currentState)) return;
      await showDialog<bool>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
                  content: Text(
                      NSSLStrings.of(context)!.requestPasswordResetSuccess()),
                  actions: <Widget>[
                    TextButton(
                        child: Text(NSSLStrings.of(context)!.okayButton()),
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        })
                  ]));
      Navigator.pop(context);
    }
  }

  String? _validateEmail(String? value) {
    if (value == null) return value;
    if (value.isEmpty) return NSSLStrings.of(context)!.emailRequiredError();
    RegExp email = RegExp(
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
    if (!email.hasMatch(value))
      return NSSLStrings.of(context)!.emailIncorrectFormatError();
    return null;
  }

  _resetInput() {
    emailInput.decoration = InputDecoration(labelText: "E-Mail");
  }

  @override
  Widget build(BuildContext context) {
    _resetInput();
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
          title: Text(NSSLStrings.of(context)!.requestPasswordResetTitle())),
      body: Form(
        key: _formKey,
        autovalidateMode: validateMode,
        child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            children: [
              ListTile(
                title: TextFormField(
                  key: emailInput.key,
                  decoration: emailInput.decoration,
                  controller: emailInput.textEditingController,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: [AutofillHints.username, AutofillHints.email],
                  autocorrect: false,
                  autofocus: true,
                  validator: _validateEmail,
                  onSaved: (s) => _handleSubmitted(),
                ),
              ),
              ListTile(
                title: Container(
                    child: ElevatedButton(
                      key: submit.key,
                      child: Center(
                          child: Text(NSSLStrings.of(context)!
                              .requestPasswordResetButton())),
                      onPressed: _handleSubmitted,
                    ),
                    padding: const EdgeInsets.only(top: 16.0)),
              ),
            ]),
      ),
    );
  }
}
