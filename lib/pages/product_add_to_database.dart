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
  final String? gtin;

  @override
  AddProductToDatabaseState createState() =>
      AddProductToDatabaseState(gtin);
}

class AddProductToDatabaseState extends State<AddProductToDatabase> {
  AddProductToDatabaseState(this.gtin);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final String? gtin;

  bool _isSendToServer = false;
  bool _saveNeeded = false;
  bool putInList = true;
  TextEditingController tecProductName = TextEditingController();
  TextEditingController tecBrandName = TextEditingController();
  TextEditingController tecPackagingSize = TextEditingController();
  String? productName;
  String? brandName;
  String? weight;
  var validateMode = AutovalidateMode.disabled;

  Future<bool> _onWillPop() async {
    if (!_saveNeeded) return true;

    final ThemeData theme = Theme.of(context);
    final TextStyle dialogTextStyle =
        theme.textTheme.subtitle1!.copyWith(color: theme.textTheme.caption!.color);

    return await (showDialog<bool>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
                content: Text(NSSLStrings.of(context)!.discardNewProduct(),
                    style: dialogTextStyle),
                actions: <Widget>[
                  TextButton(
                      child: Text(NSSLStrings.of(context)!.cancelButton()),
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      }),
                  TextButton(
                      child: Text(NSSLStrings.of(context)!.discardButton()),
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      })
                ])) as FutureOr<bool>?) ??
        false;
  }

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(value)));
  }

  Future<bool> _handleSubmitted() async {
    if (_isSendToServer) {
      showInSnackBar(NSSLStrings.of(context)!.bePatient());
      return false;
    }
    final FormState form = _formKey.currentState!;
    if (!form.validate()) {
      showInSnackBar(NSSLStrings.of(context)!.fixErrorsBeforeSubmittingPrompt());
      validateMode = AutovalidateMode.onUserInteraction;
      return false;
    } else {
      form.save();
      //double realWeight = recursiveParsing(weight);
      var numberReg = RegExp('(?:\\d*[\\.\\,])?\\d+');
      var unitReg = RegExp('[a-z]+', caseSensitive: false);
      var match = numberReg.firstMatch(weight!);
      double realWeight = 0.0;
      String? unit;
      if (weight!.length > 0) {
        realWeight = double.parse(weight!.substring(match!.start, match.end));
        match = unitReg.firstMatch(weight!);
        unit = weight!.substring(match!.start, match.end);
      }
      _isSendToServer = true;
      var first = (await ProductSync.addNewProduct(
          "$productName $brandName", gtin, realWeight, unit, context));
      if (first.statusCode != 200) {
        showInSnackBar(first.reasonPhrase!);
        _isSendToServer = false;
        return false;
      }
      var res = ProductResult.fromJson(first.body);
      if (!res.success!)
        showInSnackBar(res.error!);
      else {
        showInSnackBar(NSSLStrings.of(context)!.successful());
        if (putInList) {
          var list = User.currentList!;
          var pres = AddListItemResult.fromJson(
              (await ShoppingListSync.addProduct(list.id,
                      "$productName $brandName $weight", gtin, 1, context))
                  .body);
          if (!pres.success!)
            showInSnackBar(pres.error!);
          else {
            setState(() {
              list.shoppingItems!.add(ShoppingItem(pres.name)
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

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
          title: Text(NSSLStrings.of(context)!.newProductTitle()),
          actions: <Widget>[
            TextButton(
                child: Text(NSSLStrings.of(context)!.saveButton(),
                    style: theme.textTheme.bodyText2!.copyWith(color: Colors.white)),
                onPressed: () => _handleSubmitted())
          ]),
      body: Form(
          key: _formKey,
          onWillPop: _onWillPop,
        autovalidateMode: validateMode,
          child: ListView(padding: const EdgeInsets.all(16.0), children: <
              Widget>[
            Container(
                child: TextFormField(
                    decoration: InputDecoration(
                      labelText: NSSLStrings.of(context)!.newProductName(),
                      hintText: NSSLStrings.of(context)!.newProductNameHint(),
                    ),
                    autofocus: true,
                    controller: tecProductName,
                    onSaved: (s) => productName = s,
                    validator: _validateName)),
            Container(
                child: TextFormField(
                    decoration: InputDecoration(
                        labelText:
                            NSSLStrings.of(context)!.newProductBrandName(),
                        hintText:
                            NSSLStrings.of(context)!.newProductBrandNameHint()),
                    autofocus: false,
                    controller: tecBrandName,
                    onSaved: (s) => brandName = s,
                    validator: _validateName)),
            Container(
                child: TextFormField(
                    decoration: InputDecoration(
                        labelText: NSSLStrings.of(context)!.newProductWeight(),
                        hintText:
                            NSSLStrings.of(context)!.newProductWeightHint()),
                    autofocus: false,
                    onSaved: (s) => weight = s,
                    controller: tecPackagingSize)),
            Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(color: theme.dividerColor))),
                alignment: FractionalOffset.bottomLeft,
                child: Text(NSSLStrings.of(context)!.codeText() + gtin!)),
            Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                alignment: FractionalOffset.bottomLeft,
                child: Row(children: [
                  Text(NSSLStrings.of(context)!.newProductAddToList()),
                  Checkbox(
                      value: putInList,
                      onChanged: (b) => setState(() => putInList = !putInList))
                ])),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                  NSSLStrings.of(context)!.newProductStarExplanation(),
                  style: Theme.of(context).textTheme.caption),
            ),
          ])),
    );
  }

  String? _validateName(String? value) {
    _saveNeeded = true;
    if (value!.isEmpty) return NSSLStrings.of(context)!.fieldRequiredError();
    if (value.length < 3)
      return NSSLStrings.of(context)!.newProductNameToShort();
    return null;
  }

  // double recursiveParsing(String source) {
  //   if (source.length == 0) return null;
  //   return double.parse(
  //       source.substring(0, source.length - 1), recursiveParsing);
  // }
}
