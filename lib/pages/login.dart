import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nssl/firebase/cloud_messsaging.dart';
import 'package:nssl/localization/nssl_strings.dart';
import 'package:nssl/models/model_export.dart';
import 'package:nssl/server_communication/return_classes.dart';
import 'package:nssl/server_communication/s_c.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginPage extends ConsumerStatefulWidget {
  LoginPage({Key? key, this.scaffoldKey}) : super(key: key);

  final GlobalKey<ScaffoldState>? scaffoldKey;
  @override
  LoginPageState createState() => LoginPageState();
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

class LoginPageState extends ConsumerState<LoginPage> {
  LoginPageState() : super();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  var nameInput = ForInput();
  var pwInput = ForInput();
  var submit = ForInput();
  var validateMode = AutovalidateMode.disabled;

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value), duration: Duration(seconds: 3)));
  }

  Future _handleSubmitted() async {
    //bool error = false;
    //_resetInput();
    final FormState form = _formKey.currentState!;
    if (!form.validate()) {
      validateMode = AutovalidateMode.onUserInteraction;
      return;
    }

    String name = nameInput.textEditingController.text;
    String password = pwInput.textEditingController.text;

    if (_validateEmail(nameInput.textEditingController.text) != null) {
      var res = await UserSync.login(name, password, context);
      if (!HelperMethods.reactToRespone(res, context, scaffoldState: _scaffoldKey.currentState))
        return;
      else
        _handleLoggedIn(LoginResult.fromJson(res.body));
    } else {
      var res = await UserSync.loginEmail(name, password, context);
      if (!HelperMethods.reactToRespone(res, context, scaffoldState: _scaffoldKey.currentState))
        return;
      else
        _handleLoggedIn(LoginResult.fromJson(res.body));
    }
  }

  Future _handleLoggedIn(LoginResult res) async {
    if (!res.success) {
      showInSnackBar(res.error);
      return;
    }
    showInSnackBar(NSSLStrings.of(context).loginSuccessfulMessage());

    var userState = ref.watch(userStateProvider.notifier);
    User.token = res.token;
    var user = User(res.id, res.username, res.eMail);

    firebaseMessaging?.subscribeToTopic(res.username + "userTopic");

    var listController = ref.read(shoppingListsProvider);
    await listController.reloadAllLists(context);

    user.save(0);
    ref.watch(currentListIndexProvider.notifier).state = 0;
    userState.state = user;
  }

  String? _validateName(String? value) {
    if (value!.isEmpty) return NSSLStrings.of(context).nameEmailRequiredError();
    if (value.length < 4) return NSSLStrings.of(context).usernameToShortError();

    return null;
  }

  String? _validateEmail(String value) {
    if (value.isEmpty) return NSSLStrings.of(context).emailRequiredError();
    RegExp email = RegExp(
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');

    if (!email.hasMatch(value)) return NSSLStrings.of(context).emailIncorrectFormatError();
    return null;
  }

  String? _validatePassword(String? value) {
    if (pwInput.textEditingController.text.isEmpty) return NSSLStrings.of(context).passwordEmptyError();
    return null;
  }

  _resetInput() {
    nameInput.decoration = InputDecoration(
        helperText: NSSLStrings.of(context).usernameOrEmailForLoginHint(),
        labelText: NSSLStrings.of(context).usernameOrEmailTitle());

    pwInput.decoration = InputDecoration(
        helperText: NSSLStrings.of(context).choosenPasswordHint(), labelText: NSSLStrings.of(context).password());
  }

  @override
  initState() {
    super.initState();
    //
  }

  @override
  Widget build(BuildContext context) {
    _resetInput();
//    return ListView(children: <Widget>[new (child: Scaffold(
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: Text(NSSLStrings.of(context).login())),
      body: Form(
        key: _formKey,
        autovalidateMode: validateMode,
        child: ListView(
//              physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            children: [
              ListTile(
                  title: TextFormField(
                      key: nameInput.key,
                      decoration: nameInput.decoration,
                      //onChanged: (input) => nameInput.errorText = _validateName(input),
                      controller: nameInput.textEditingController,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: [AutofillHints.username, AutofillHints.email],
                      autocorrect: false,
                      autofocus: true,
                      validator: _validateName,
                      onSaved: (val) {
                        FocusScope.of(context).requestFocus(pwInput.focusNode);
                      })),
              ListTile(
                  title: TextFormField(
                      key: pwInput.key,
                      decoration: pwInput.decoration,
                      focusNode: pwInput.focusNode,
                      obscureText: true,
                      autocorrect: false,
                      autofillHints: [AutofillHints.password],
                      controller: pwInput.textEditingController,
                      validator: _validatePassword,
                      onSaved: (val) {
                        _handleSubmitted();
                      })),
              ListTile(
                title: Container(
                    child: ElevatedButton(
                      key: submit.key,
                      child: Center(child: Text(NSSLStrings.of(context).loginButton())),
                      onPressed: _handleSubmitted,
                    ),
                    padding: const EdgeInsets.only(top: 16.0)),
              ),
              ListTile(
                title: Container(
                  padding: const EdgeInsets.only(top: 40.0),
                  child: TextButton(
                    onPressed: () {
                      var userId = ref.read(userIdProvider);
                      userId == null || userId < 0
                          ? Navigator.pushNamed(context, "/registration")
                          : Navigator.popAndPushNamed(context, "/registration");
                    },
                    child: Text(NSSLStrings.of(context).registerTextOnLogin()),
                  ),
                ),
              ),
              ListTile(
                title: Container(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, "/forgot_password");
                    },
                    child: Text(NSSLStrings.of(context).forgotPassword()),
                  ),
                ),
              ),
              //padding: EdgeInsets.only(
              //    top: MediaQuery.of(context).size.height / 5),
            ]
            //]),

            ),
      ),
    );
  }
}
