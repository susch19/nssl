import 'package:flutter/material.dart';
import 'package:testProject/localization/nssl_strings.dart';
import 'package:testProject/models/model_export.dart';
import 'package:flutter/widgets.dart';
import 'package:testProject/server_communication//s_c.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:testProject/server_communication/return_classes.dart';

class ProductAddPage extends StatefulWidget {
  ProductAddPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _ProductAddPageState createState() => new _ProductAddPageState();

  static ProductResult fromJson(Map data) {
    var r = new ProductResult();
    r.success = data["success"];
    r.error = data["error"];
    r.gtin = data["gtin"];
    r.quantity = data["quantity"];
    r.unit = data["unit"];
    r.name = data["name"];

    return r;
  }
}

class _ProductAddPageState extends State<ProductAddPage> {
  final GlobalKey<ScaffoldState> _mainScaffoldKey =
      new GlobalKey<ScaffoldState>();
  GlobalKey _iff = new GlobalKey();
  GlobalKey _ib = new GlobalKey();
  TextEditingController tec = new TextEditingController();
  List<ProductResult> prList = new List<ProductResult>();
  int k = 1;

  Future _addProductToList(String name, String gtin) async {
    var list = User.currentList;
    if (list != null) {
      if (list.shoppingItems == null) list.shoppingItems = new List();

      var item = list.shoppingItems
          .firstWhere((x) => x.name == name, orElse: () => null);
      ShoppingItem afterAdd;
      if (item != null) {
        var answer =
            await ShoppingListSync.changeProduct(list.id, item.id, 1, context);
        var p = ChangeListItemResult.fromJson((answer).body);
        setState(() {
          item.amount = p.amount;
        });
      } else {
        var p = AddListItemResult.fromJson((await ShoppingListSync.addProduct(
                list.id, name, gtin ?? '-', 1, context))
            .body);
        afterAdd = new ShoppingItem()
          ..name = p.name
          ..amount = 1
          ..id = p.productId;
        setState(() => list.shoppingItems.add(afterAdd));
      }

      showInSnackBar(
          item == null
              ? NSSLStrings.of(context).addedProduct() + "$name"
              : "$name" + NSSLStrings.of(context).productWasAlreadyInList(),
          duration: new Duration(seconds: item == null ? 2 : 4),
          action: new SnackBarAction(
              label: NSSLStrings.of(context).undo(),
              onPressed: () async {
                var res = item == null
                    ? await ShoppingListSync.deleteProduct(
                        list.id, afterAdd.id, context)
                    : await ShoppingListSync.changeProduct(
                        list.id, item.id, -1, context);
                if (Result.fromJson(res.body).success) {
                  if (item == null)
                    list.shoppingItems.remove(afterAdd);
                  else
                    item.amount--;
                }
              }));
      list.save();
    }
  }

  int lastLength = 0;

  bool noMoreProducts = false;
  String oldValue = "";

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: _mainScaffoldKey,
        appBar: new AppBar(
            title: new Form(
                child: new TextField(
                    key: _iff,
                    decoration:
                        new InputDecoration(hintText: NSSLStrings.of(context).searchProductHint()),
                    onSubmitted: (x) => _searchProducts(x, 1),
                    autofocus: true,
                    controller: tec,
                    onChanged: (s) => setState(() {
                          if (s == oldValue) return;
                          prList.clear();
                          k = 1;
                          lastLength = 0;
                          noMoreProducts = false;
                          oldValue = s;
                    })))),
        floatingActionButton: new FloatingActionButton(
          onPressed: () => {},
          child: new IconButton(
            key: _ib,
            icon: new Icon(Icons.search),
            onPressed: () {
              _searchProducts(tec.text, 1);
            },
          ),
        ),
        body: buildBody());
  }

  Future continueList() => _searchProducts(tec.text, ++k);

  Future _searchProducts(String value, int page) async {
    Response o = await ProductSync.getProducts(value, page, context);

    List<Map> z = JSON.decode(o.body);
    if (!noMoreProducts && z.length <= 0) {
      noMoreProducts = true;
      showInSnackBar(NSSLStrings.of(context).noMoreProductsMessage(),
          duration: new Duration(seconds: 3));
    } else
      setState(() => prList.addAll(z.map(ProductAddPage.fromJson).toList()));
  }

  Widget buildBody() {
    if (prList.length > 0) {
      var listView = new ListView.builder(
          itemBuilder: (c, i) {
            if (!noMoreProducts && i + 20 > lastLength) {
              continueList();
              lastLength = prList.length;
            }
            return new ListTile(
                title: new Text(prList[i].name),
                onTap: () => _addProductToList(prList[i].name, prList[i].gtin));
          },
          itemCount: prList.length);
      return listView;
    } else
      return new Text("");
  }

  void showInSnackBar(String value,
      {Duration duration, SnackBarAction action}) {
    _mainScaffoldKey.currentState.removeCurrentSnackBar();
    _mainScaffoldKey.currentState.showSnackBar(new SnackBar(
        content: new Text(value),
        duration: duration ?? new Duration(seconds: 3),
        action: action));
  }
}
