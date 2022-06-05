import 'package:flutter/material.dart';
import 'package:nssl/helper/iterable_extensions.dart';
import 'package:nssl/localization/nssl_strings.dart';
import 'package:nssl/models/model_export.dart';
import 'package:nssl/server_communication//s_c.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:nssl/server_communication/return_classes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductAddPage extends ConsumerStatefulWidget {
  ProductAddPage({Key? key, this.title}) : super(key: key);
  final String? title;

  @override
  _ProductAddPageState createState() => new _ProductAddPageState();

  static ProductResult fromJson(Map data) {
    var r = ProductResult();
    r.success = data["success"];
    r.error = data["error"];
    r.gtin = data["gtin"];
    r.quantity = data["quantity"];
    r.unit = data["unit"];
    r.name = data["name"];

    return r;
  }
}

class _ProductAddPageState extends ConsumerState<ProductAddPage> {
  final GlobalKey<ScaffoldState> _mainScaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey _iff = GlobalKey();
  GlobalKey _ib = GlobalKey();
  TextEditingController tec = TextEditingController();
  List<ProductResult> prList = <ProductResult>[];
  int k = 1;

  Future _addProductToList(String? name, String? gtin) async {
    var list = ref.read(currentListProvider);
    if (list != null) {
      var siState = ref.watch(shoppingItemsProvider.notifier);
      var shoppingItems = siState.state.toList();
      var item = shoppingItems.firstOrNull((x) => x.name == name);
      ShoppingItem? afterAdd;
      if (item != null) {
        var answer = await ShoppingListSync.changeProductAmount(list.id, item.id, 1, context);
        var p = ChangeListItemResult.fromJson((answer).body);
        shoppingItems.remove(item);
        afterAdd = item.cloneWith(newAmount: p.amount, newChanged: p.changed);
      } else {
        var p = AddListItemResult.fromJson(
            (await ShoppingListSync.addProduct(list.id, name!, gtin ?? '-', 1, context)).body);
        int sortOrder = 0;
        if (shoppingItems.length > 0) sortOrder = shoppingItems.last.sortOrder + 1;
        afterAdd = ShoppingItem(p.name, list.id, sortOrder, amount: 1, id: p.productId);
      }

      shoppingItems.add(afterAdd);
      siState.state = shoppingItems;

      showInSnackBar(
        item == null
            ? NSSLStrings.of(context).addedProduct() + "$name"
            : "$name" + NSSLStrings.of(context).productWasAlreadyInList(),
        duration: Duration(seconds: item == null ? 2 : 4),
        action: SnackBarAction(
            label: NSSLStrings.of(context).undo(),
            onPressed: () async {
              var res = item == null
                  ? await ShoppingListSync.deleteProduct(list.id, afterAdd!.id, context)
                  : await ShoppingListSync.changeProductAmount(list.id, item.id, -1, context);
              if (Result.fromJson(res.body).success) {
                var newState = siState.state.toList();

                newState.remove(afterAdd);
                if (item != null) newState.add(item);
                siState.state = newState;
              }
            }),
      );
    }
  }

  int lastLength = 0;

  bool noMoreProducts = false;
  String oldValue = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _mainScaffoldKey,
        appBar: AppBar(
            title: Form(
                child: TextField(
                    key: _iff,
                    decoration: InputDecoration(hintText: NSSLStrings.of(context).searchProductHint()),
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
        floatingActionButton: FloatingActionButton(
          onPressed: () => {},
          child: IconButton(
            key: _ib,
            icon: Icon(Icons.search),
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
    if (o.body.length < 1) return;
    List? z = jsonDecode(o.body); // .decode(o.body);
    if (!noMoreProducts && z!.length <= 0) {
      noMoreProducts = true;
      showInSnackBar(NSSLStrings.of(context).noMoreProductsMessage(), duration: Duration(seconds: 3));
    } else
      setState(() => prList.addAll(z!
          .map((f) => ProductResult()
            ..unit = f["unit"]
            ..name = f["name"]
            ..quantity = f["quantity"])
          .toList()));
  }

  Widget buildBody() {
    if (prList.length > 0) {
      var listView = ListView.builder(
          itemBuilder: (c, i) {
            if (!noMoreProducts && i + 20 > lastLength) {
              continueList();
              lastLength = prList.length;
            }
            return ListTile(
                title: Text(prList[i].name!), onTap: () => _addProductToList(prList[i].name, prList[i].gtin));
          },
          itemCount: prList.length);
      return listView;
    } else
      return Text("");
  }

  void showInSnackBar(String value, {Duration? duration, SnackBarAction? action}) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(value), duration: duration ?? Duration(seconds: 3), action: action));
  }
}
