import 'dart:async';
import 'package:flutter/material.dart';
import 'package:testProject/models/model_export.dart';
import 'package:testProject/models/user.dart';
import 'package:testProject/server_communication/return_classes.dart';
import 'package:testProject/server_communication/s_c.dart';

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
            child: new AlertDialog(
                content:
                    new Text('Discard new product?', style: dialogTextStyle),
                actions: <Widget>[
                  new FlatButton(
                      child: const Text('CANCEL'),
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      }),
                  new FlatButton(
                      child: const Text('DISCARD'),
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
    final FormState form = _formKey.currentState;
    if (!form.validate()) {
      _autovalidate = true;
      showInSnackBar('Please fix the errors in red before submitting.');
      return false;
    } else {
      form.save();
      var first = (await ProductSync.addNewProduct(
          "$productName $brandName $weight", gtin));
      if (first.statusCode != 200) {
        showInSnackBar(first.reasonPhrase);
        return false;
      }
      var res = ProductResult.fromJson(first.body);
      if (!res.success)
        showInSnackBar(res.error);
      else {
        if (putInList) {
          var pres = AddListItemResult.fromJson(
              (await ShoppingListSync.addProduct(User.currentList.id,
                      "$productName $brandName $weight", gtin, 1))
                  .body);
          if (!pres.success)
            showInSnackBar(pres.error);
          else {
            setState(() {
              User.currentList.shoppingItems.add(new ShoppingItem()
                ..amount = 1
                ..id = pres.productId
                ..name = pres.name);
            });
            Navigator.pop(context, DismissDialogAction.save);
          }
        }
      }
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(title: const Text('New Product'), actions: <Widget>[
        new FlatButton(
            child: new Text('SAVE',
                style: theme.textTheme.body1.copyWith(color: Colors.white)),
            onPressed: () => _handleSubmitted())
      ]),
      body: new Form(
          key: _formKey,
          onWillPop: _onWillPop,
          autovalidate: _autovalidate,
          child: new ListView(
              padding: const EdgeInsets.all(16.0),
              children: <Widget>[
                new Container(
                    child: new TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Product Name *",
                          hintText: "How is this product called?",
                        ),
                        autofocus: true,
                        controller: tecProductName,
                        onSaved: (s) => productName = s,
                        validator: _validateName)),
                new Container(
                    child: new TextFormField(
                        decoration: const InputDecoration(
                            labelText: "Brand Name *",
                            hintText: "Which company sells this product?"),
                        autofocus: false,
                        controller: tecBrandName,
                        onSaved: (s) => brandName = s,
                        validator: _validateName)),
                new Container(
                    child: new TextFormField(
                        decoration: const InputDecoration(
                            labelText: "Weight",
                            hintText: "What is the normal packaging size?"),
                        autofocus: false,
                        onSaved: (s) => weight = s,
                        controller: tecPackagingSize)),
                new Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    decoration: new BoxDecoration(
                        border: new Border(
                            bottom: new BorderSide(color: theme.dividerColor))),
                    alignment: FractionalOffset.bottomLeft,
                    child: new Text('code: ' + gtin)),
                new Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    alignment: FractionalOffset.bottomLeft,
                    child: new Row(children: [
                      const Text("Add to current list"),
                      new Checkbox(
                          value: putInList,
                          onChanged: (b) =>
                              setState(() => putInList = !putInList))
                    ])),
                new Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: new Text('* indicates required field',
                      style: Theme.of(context).textTheme.caption),
                ),
              ])),
    );
  }

  String _validateName(String value) {
    _saveNeeded = true;
    if (value.isEmpty) return "This field is required!";
    if (value.length < 3) return "This name seems to be to short";
    return null;
  }
}
