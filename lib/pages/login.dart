import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:testProject/firebase/cloud_messsaging.dart';
import 'package:testProject/localization/nssl_strings.dart';
import 'package:testProject/main.dart';
import 'package:testProject/models/model_export.dart';
import 'package:testProject/models/user.dart';
import 'package:testProject/server_communication/helper_methods.dart';
import 'package:testProject/server_communication/return_classes.dart';
import 'package:testProject/server_communication/s_c.dart';
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
  InputDecoration decoration;
  FocusNode focusNode = new FocusNode();
}

class LoginPageState extends State<LoginPage> {
  LoginPageState() : super();
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  bool _autovalidate = false;
  var nameInput = new ForInput();
  var pwInput = new ForInput();
  var submit = new ForInput();

  void showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
        content: new Text(value), duration: new Duration(seconds: 3)));
  }

  Future _handleSubmitted() async {
    //bool error = false;
    //_resetInput();
    final FormState form = _formKey.currentState;
    if (!form.validate()) {
      _autovalidate = true;
      return;
    }
    //form.save();
    /*  var validate = _validateName(nameInput.textEditingController.text);
    if (validate != null) {
      nameInput.decoration = new InputDecoration(
          labelText: nameInput.decoration.labelText,
          helperText: nameInput.decoration.helperText,
          errorText: validate);
      error = true;
    }
    if (_validatePassword(pwInput.textEditingController.text) != null) {
      pwInput.decoration = new InputDecoration(
          labelText: pwInput.decoration.labelText,
          helperText: pwInput.decoration.helperText,
          errorText: _validatePassword(pwInput.textEditingController.text));
      error = true;
    }
    setState(() => {});*/
//    if (error == true) return;

    String name = nameInput.textEditingController.text;
    String password = pwInput.textEditingController.text;

    if (_validateEmail(nameInput.textEditingController.text) != null) {
      var res = await UserSync.login(name, password, context);
      if (!HelperMethods.reactToRespone(res, context,
          scaffoldState: _scaffoldKey?.currentState))
        return;
      else
        _handleLoggedIn(LoginResult.fromJson(res.body));
    } else {
      var res = await UserSync.loginEmail(name, password, context);
      if (!HelperMethods.reactToRespone(res, context,
          scaffoldState: _scaffoldKey?.currentState))
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
    bool firstBoot = User.username == null;
    User.token = res.token;
    User.username = res.username;
    User.eMail = res.eMail;
    User.ownId = res.id;
    await User.save();
    firebaseMessaging.subscribeToTopic(res.username + "userTopic");
    if (firstBoot) {
      await _getAllListsInit();
      if (User.shoppingLists?.length > 0) {
        User.currentList = User.shoppingLists.first;
        User.currentListIndex = 1;
        await User.save();
      }
      runApp(new NSSL());
    } else
      Navigator.pop(context);
  }

  Future _getAllListsInit() async {
    var result = GetListsResult
        .fromJson((await ShoppingListSync.getLists(context)).body);
    setState(() => User.shoppingLists.clear());
    for (var res in result.shoppingLists) {
      var list = new ShoppingList()
        ..id = res.id
        ..name = res.name
        ..shoppingItems = new List<ShoppingItem>();
      for (var item in res.products)
        list.shoppingItems.add(new ShoppingItem()
          ..name = item.name
          ..id = item.id
          ..amount = item.amount);
      setState(() => User.shoppingLists.add(list));
      list.subscribeForFirebaseMessaging();
      list.save();
    }
  }

  String _validateName(String value) {
    if (value.isEmpty) return NSSLStrings.of(context).nameEmailRequiredError();
    if (value.length < 4) return NSSLStrings.of(context).usernameToShortError();

    return null;
  }

  String _validateEmail(String value) {
    if (value.isEmpty) return NSSLStrings.of(context).emailRequiredError();
    RegExp email = new RegExp(
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
    if (!email.hasMatch(value))
      return NSSLStrings.of(context).emailIncorrectFormatError();
    return null;
  }

  String _validatePassword(String value) {
    if (pwInput.textEditingController == null ||
        pwInput.textEditingController.text.isEmpty)
      return NSSLStrings.of(context).passwordEmptyError();
    return null;
  }

  _resetInput() {
    nameInput.decoration = new InputDecoration(
        helperText: NSSLStrings.of(context).usernameOrEmailForLoginHint(),
        labelText: NSSLStrings.of(context).usernameOrEmailTitle());

    pwInput.decoration = new InputDecoration(
        helperText: NSSLStrings.of(context).choosenPasswordHint(),
        labelText: NSSLStrings.of(context).password());
  }

  @override
  initState() {
    super.initState();
    //
  }

  @override
  Widget build(BuildContext context) {
    _resetInput();
//    return new ListView(children: <Widget>[new (child: new Scaffold(
    return new Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomPadding: true,
      appBar: new AppBar(title: new Text(NSSLStrings.of(context).login())),
      body: new Form(
        key: _formKey,
        autovalidate: _autovalidate,
        child: new ListView(
//              physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            children: [
              new ListTile(
                  title: new TextFormField(
                      key: nameInput.key,
                      decoration: nameInput.decoration,
                      //onChanged: (input) => nameInput.errorText = _validateName(input),
                      controller: nameInput.textEditingController,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      autofocus: true,
                      validator: _validateName,
                      onSaved: (val) {
                        FocusScope.of(context).requestFocus(pwInput.focusNode);
                      })),
              new ListTile(
                  title: new TextFormField(
                      key: pwInput.key,
                      decoration: pwInput.decoration,
                      focusNode: pwInput.focusNode,
                      obscureText: true,
                      autocorrect: false,
                      controller: pwInput.textEditingController,
                      validator: _validatePassword,
                      onSaved: (val) {
                        _handleSubmitted();
                      })),
              new ListTile(
                title: new Container(
                    child: new RaisedButton(
                      key: submit.key,
                      child: new Center(
                          child:
                              new Text(NSSLStrings.of(context).loginButton())),
                      onPressed: _handleSubmitted,
                    ),
                    padding: const EdgeInsets.only(top: 16.0)),
              ),
              new ListTile(
                title: new Container(
                  padding: const EdgeInsets.only(top: 40.0),
                  child: new FlatButton(
                    onPressed: () {
                      User.username == null
                          ? Navigator.pushNamed(context, "/registration")
                          : Navigator.popAndPushNamed(context, "/registration");
                    },
                    child:
                        new Text(NSSLStrings.of(context).registerTextOnLogin()),
                  ), /*
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
            ]
            //]),

            ),
      ),
    );
  }
}
