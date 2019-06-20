import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nssl/localization/nssl_strings.dart';
import 'package:nssl/models/model_export.dart';
import 'package:nssl/models/user.dart';
import 'package:nssl/server_communication/return_classes.dart';
import 'package:nssl/server_communication/s_c.dart';

enum DismissDialogAction {
  cancel,
  discard,
  save,
}

class AddProductToDatabase extends StatefulWidget {
  AddProductToDatabase(this.gtin);
  final String gtin;

  @override
  AddProductToDatabaseState createState() =>
      new AddProductToDatabaseState(gtin);
}

class AddProductToDatabaseState extends State<AddProductToDatabase> {
  AddProductToDatabaseState(this.gtin);
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  final String gtin;

  bool _isSendToServer = false;
  bool _saveNeeded = false;
  bool putInList = true;
  bool _autovalidate = false;
  TextEditingController tecProductName = new TextEditingController();
  TextEditingController tecBrandName = new TextEditingController();
  TextEditingController tecPackagingSize = new TextEditingController();
  String productName;
  String brandName;
  String weight;

  Future<bool> _onWillPop() async {
    if (!_saveNeeded) return true;

    final ThemeData theme = Theme.of(context);
    final TextStyle dialogTextStyle =
        theme.textTheme.subhead.copyWith(color: theme.textTheme.caption.color);

    return await showDialog<bool>(
            context: context,
            builder: (BuildContext context) => new AlertDialog(
                content: new Text(NSSLStrings.of(context).discardNewProduct(),
                    style: dialogTextStyle),
                actions: <Widget>[
                  new FlatButton(
                      child: new Text(NSSLStrings.of(context).cancelButton()),
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      }),
                  new FlatButton(
                      child: new Text(NSSLStrings.of(context).discardButton()),
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      })
                ])) ??
        false;
  }

  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  Future<bool> _handleSubmitted() async {
    if (_isSendToServer) {
      showInSnackBar(NSSLStrings.of(context).bePatient());
      return false;
    }
    final FormState form = _formKey.currentState;
    if (!form.validate()) {
      _autovalidate = true;
      showInSnackBar(NSSLStrings.of(context).fixErrorsBeforeSubmittingPrompt());
      return false;
    } else {
      form.save();
      //double realWeight = recursiveParsing(weight);
      var numberReg = new RegExp('(?:\\d*[\\.\\,])?\\d+');
      var unitReg = new RegExp('[a-z]+', caseSensitive: false);
      var match = numberReg.firstMatch(weight);
      double realWeight = 0.0;
      String unit;
      if (weight.length > 0) {
        realWeight = double.parse(weight.substring(match.start, match.end));
        match = unitReg.firstMatch(weight);
        unit = weight.substring(match.start, match.end);
      }
      _isSendToServer = true;
      var first = (await ProductSync.addNewProduct(
          "$productName $brandName", gtin, realWeight, unit, context));
      if (first.statusCode != 200) {
        showInSnackBar(first.reasonPhrase);
        _isSendToServer = false;
        return false;
      }
      var res = ProductResult.fromJson(first.body);
      if (!res.success)
        showInSnackBar(res.error);
      else {
        showInSnackBar(NSSLStrings.of(context).successful());
        if (putInList) {
          var list = User.currentList;
          var pres = AddListItemResult.fromJson(
              (await ShoppingListSync.addProduct(list.id,
                      "$productName $brandName $weight", gtin, 1, context))
                  .body);
          if (!pres.success)
            showInSnackBar(pres.error);
          else {
            setState(() {
              list.shoppingItems.add(new ShoppingItem(pres.name)
                ..amount = 1
                ..id = pres.productId);
            });
          }
        }
        _isSendToServer = false;
        Navigator.of(context).pop();
      }
      _isSendToServer = false;
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
          title: new Text(NSSLStrings.of(context).newProductTitle()),
          actions: <Widget>[
            new FlatButton(
                child: new Text(NSSLStrings.of(context).saveButton(),
                    style: theme.textTheme.body1.copyWith(color: Colors.white)),
                onPressed: () => _handleSubmitted())
          ]),
      body: new Form(
          key: _formKey,
          onWillPop: _onWillPop,
          autovalidate: _autovalidate,
          child: new ListView(padding: const EdgeInsets.all(16.0), children: <
              Widget>[
            new Container(
                child: new TextFormField(
                    decoration: new InputDecoration(
                      labelText: NSSLStrings.of(context).newProductName(),
                      hintText: NSSLStrings.of(context).newProductNameHint(),
                    ),
                    autofocus: true,
                    controller: tecProductName,
                    onSaved: (s) => productName = s,
                    validator: _validateName)),
            new Container(
                child: new TextFormField(
                    decoration: new InputDecoration(
                        labelText:
                            NSSLStrings.of(context).newProductBrandName(),
                        hintText:
                            NSSLStrings.of(context).newProductBrandNameHint()),
                    autofocus: false,
                    controller: tecBrandName,
                    onSaved: (s) => brandName = s,
                    validator: _validateName)),
            new Container(
                child: new TextFormField(
                    decoration: new InputDecoration(
                        labelText: NSSLStrings.of(context).newProductWeight(),
                        hintText:
                            NSSLStrings.of(context).newProductWeightHint()),
                    autofocus: false,
                    onSaved: (s) => weight = s,
                    controller: tecPackagingSize)),
            new Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                decoration: new BoxDecoration(
                    border: new Border(
                        bottom: new BorderSide(color: theme.dividerColor))),
                alignment: FractionalOffset.bottomLeft,
                child: new Text(NSSLStrings.of(context).codeText() + gtin)),
            new Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                alignment: FractionalOffset.bottomLeft,
                child: new Row(children: [
                  new Text(NSSLStrings.of(context).newProductAddToList()),
                  new Checkbox(
                      value: putInList,
                      onChanged: (b) => setState(() => putInList = !putInList))
                ])),
            new Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: new Text(
                  NSSLStrings.of(context).newProductStarExplanation(),
                  style: Theme.of(context).textTheme.caption),
            ),
          ])),
    );
  }

  String _validateName(String value) {
    _saveNeeded = true;
    if (value.isEmpty) return NSSLStrings.of(context).fieldRequiredError();
    if (value.length < 3)
      return NSSLStrings.of(context).newProductNameToShort();
    return null;
  }

  // double recursiveParsing(String source) {
  //   if (source.length == 0) return null;
  //   return double.parse(
  //       source.substring(0, source.length - 1), recursiveParsing);
  // }
}
