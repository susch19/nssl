import 'package:flutter/material.dart';
import 'package:nssl/localization/nssl_strings.dart';
import 'package:nssl/models/model_export.dart';
import 'package:flutter/widgets.dart';
import 'package:nssl/server_communication//s_c.dart';
import 'package:nssl/server_communication/return_classes.dart';

class BoughtItemsPage extends StatefulWidget {
  BoughtItemsPage(this.listId, {Key key, this.title}) : super(key: key);
  final String title;
  final int listId;
  @override
  _BoughtItemsPagePageState createState() => new _BoughtItemsPagePageState(listId);
}

class _BoughtItemsPagePageState extends State<BoughtItemsPage> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _mainScaffoldKey = new GlobalKey<ScaffoldState>();
  GlobalKey _iff = new GlobalKey();
  GlobalKey _ib = new GlobalKey();
  var tec = new TextEditingController();
  var shoppingItems = new List<ShoppingItem>();
  var shoppingItemsGrouped = new Map<DateTime, List<ShoppingItem>>();
  int k = 1;
  int listId;
  TabController _controller;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _BoughtItemsPagePageState(int listId) {
    this.listId = listId;
    ShoppingListSync.getList(listId, context, bought: true).then((o) {
      if (o.statusCode == 500) {
        showInSnackBar("Internal Server Error");
        return;
      }
      var z = GetBoughtListResult.fromJson(o.body);
      if (z.products.length <= 0)
        showInSnackBar(NSSLStrings.of(context).nothingBoughtYet(), duration: new Duration(seconds: 10));
      else {
        shoppingItems.addAll(z.products.map((f) => new ShoppingItem(f.name)
          ..id = f.id
          ..amount = f.amount
          ..changed = f.changed
          ..created = f.created
          ..crossedOut = false));
        DateTime date;
        shoppingItems.sort((x, y) => y.changed.compareTo(x.changed));
        for (var item in shoppingItems) {
          date = dateTimeToDate(item.changed);
          if (!shoppingItemsGrouped.containsKey(dateTimeToDate(item.changed)))
            shoppingItemsGrouped[date] = new List<ShoppingItem>();
          shoppingItemsGrouped[date].add(item);
        }
      }

      setState(() {
        _controller = TabController(vsync: this, length: shoppingItemsGrouped.keys.length);
      });
    });
  }

  DateTime dateTimeToDate(DateTime dateTime) {
    return DateTime.utc(dateTime.year, dateTime.month, dateTime.day);
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null)
      return Scaffold(
        appBar: AppBar(
          title: Text(NSSLStrings.of(context).boughtProducts()),
          actions: <Widget>[],
        ), 
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          new Container(
            child: new SizedBox(
                width: 40.0,
                height: 40.0,
                child: new CircularProgressIndicator()),
            padding: const EdgeInsets.only(top: 16.0),
          )
        ],
      ));

    return Scaffold(
      key: _mainScaffoldKey,
      appBar: AppBar(
        title: Text(NSSLStrings.of(context).boughtProducts()),
        actions: <Widget>[],
        bottom: TabBar(
          controller: _controller,
          isScrollable: true,
          indicator: getIndicator(),
          tabs: createTabs(),
        ),
      ),
      body: TabBarView(
        controller: _controller,
        children: createChildren(),
      ),
    );
  }

  Decoration getIndicator() {
    return ShapeDecoration(
      shape: const StadiumBorder(
            side: BorderSide(
              color: Colors.white24,
              width: 2.0,
            ),
          ) +
          const StadiumBorder(
            side: BorderSide(
              color: Colors.transparent,
              width: 4.0,
            ),
          ),
    );
  }

  void showInSnackBar(String value, {Duration duration, SnackBarAction action}) {
    _mainScaffoldKey.currentState.removeCurrentSnackBar();
    _mainScaffoldKey.currentState.showSnackBar(
        new SnackBar(content: new Text(value), duration: duration ?? new Duration(seconds: 3), action: action));
  }

  List<Tab> createTabs() {
    var tabs = new List<Tab>();
    for (var item in shoppingItemsGrouped.keys) {
      tabs.add(Tab(text: "${item.year}-${item.month}-${item.day}"));
    }
    return tabs;
  }

  List<Widget> createChildren() {
    var children = new List<Widget>();
    for (var item in shoppingItemsGrouped.keys) {
      children.add(SafeArea(
        top: false,
        bottom: false,
        child: Container(
          key: ObjectKey(item),
          padding: const EdgeInsets.all(12.0),
          child: Card(
            child: Center(
              child: ListView(
                children: shoppingItemsGrouped[item]
                    .map((i) => ListTile(
                          title: Text(i.name),
                          leading: Text(i.amount.toString() + "x"),
                        ))
                    .toList(growable: false),
              ),
            ),
          ),
        ),
      ));
    }
    return children;
  }
}
