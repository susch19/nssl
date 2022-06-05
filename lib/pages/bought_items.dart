import 'package:flutter/material.dart';
import 'package:nssl/localization/nssl_strings.dart';
import 'package:nssl/models/model_export.dart';
import 'package:nssl/server_communication//s_c.dart';
import 'package:nssl/server_communication/return_classes.dart';
import 'package:nssl/helper/iterable_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BoughtItemsPage extends ConsumerStatefulWidget {
  BoughtItemsPage(this.listId, {Key? key, this.title}) : super(key: key);
  final String? title;
  final int listId;
  @override
  _BoughtItemsPagePageState createState() => new _BoughtItemsPagePageState(listId);
}

class _BoughtItemsPagePageState extends ConsumerState<BoughtItemsPage> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _mainScaffoldKey = GlobalKey<ScaffoldState>();

  var tec = TextEditingController();
  var shoppingItemsGrouped = new Map<DateTime, List<ShoppingItem>>();
  int k = 1;
  int listId;
  TabController? _controller;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  _BoughtItemsPagePageState(this.listId);

  DateTime dateTimeToDate(DateTime dateTime) {
    return DateTime.utc(dateTime.year, dateTime.month, dateTime.day);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        builder: (c, t) {
          if (t.connectionState == ConnectionState.done) {
            return Scaffold(
              key: _mainScaffoldKey,
              appBar: AppBar(
                title: Text(NSSLStrings.of(context).boughtProducts()),
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
          } else {
            return Scaffold(
                appBar: AppBar(
                  title: Text(NSSLStrings.of(context).boughtProducts()),
                  actions: <Widget>[],
                ),
                body: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: SizedBox(width: 40.0, height: 40.0, child: CircularProgressIndicator()),
                      padding: const EdgeInsets.only(top: 16.0),
                    )
                  ],
                ));
          }
        },
        future: ShoppingListSync.getList(listId, null, bought: true).then((o) {
          if (o.statusCode == 500) {
            showInSnackBar("Internal Server Error");
            return;
          }
          var z = GetBoughtListResult.fromJson(o.body);
          if (z.products.length <= 0)
            showInSnackBar(NSSLStrings.of(context).nothingBoughtYet(), duration: Duration(seconds: 10));
          else {
            var shoppingItems = <ShoppingItem>[];

            shoppingItems.addAll(z.products.map((f) => ShoppingItem(f.name, listId, f.sortOrder,
                id: f.id, amount: f.amount, changed: f.changed, created: f.created, crossedOut: false)));

            DateTime date;
            shoppingItems.sort((x, y) => y.changed!.compareTo(x.changed!));
            for (var item in shoppingItems) {
              date = dateTimeToDate(item.changed!);
              if (!shoppingItemsGrouped.containsKey(dateTimeToDate(item.changed!)))
                shoppingItemsGrouped[date] = <ShoppingItem>[];
              shoppingItemsGrouped[date]!.add(item);
            }
          }

          _controller = TabController(vsync: this, length: shoppingItemsGrouped.keys.length);
        }));
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

  void showInSnackBar(String value, {Duration? duration, SnackBarAction? action}) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(value), duration: duration ?? Duration(seconds: 3), action: action));
  }

  List<Tab> createTabs() {
    var tabs = <Tab>[];
    for (var item in shoppingItemsGrouped.keys) {
      tabs.add(Tab(text: "${item.year}-${item.month}-${item.day}"));
    }
    return tabs;
  }

  List<Widget> createChildren() {
    var currentList = ref.watch(currentListProvider);
    var children = <Widget>[];
    if (currentList == null) return children;
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
                children: shoppingItemsGrouped[item]!.map(
                  (i) {
                    return ListTile(
                      title: Text(i.name),
                      leading: Text(i.amount.toString() + "x"),
                      onTap: () async {
                        var shoppingItems = ref.read(currentShoppingItemsProvider);
                        var existingItem = shoppingItems.firstOrNull((item) => item.name == i.name);
                        var listsProvider = ref.read(shoppingListsProvider);
                        if (existingItem != null) {
                          var answer = await ShoppingListSync.changeProductAmount(
                              currentList.id, existingItem.id, i.amount, context);
                          var p = ChangeListItemResult.fromJson((answer).body);
                          listsProvider.addSingleItem(
                              currentList, existingItem.cloneWith(newAmount: p.amount, newChanged: p.changed));
                        } else {
                          var p = AddListItemResult.fromJson(
                              (await ShoppingListSync.addProduct(listId, i.name, null, i.amount, context)).body);
                          int sortOrder = 0;
                          if (shoppingItems.length > 0) sortOrder = shoppingItems.last.sortOrder + 1;
                          var newItem =
                              ShoppingItem(p.name, currentList.id, sortOrder, amount: i.amount, id: p.productId);

                          listsProvider.addSingleItem(currentList, newItem);
                        }

                        showInSnackBar(
                            "${i.amount}x ${i.name}${NSSLStrings.of(context).newProductAddedToList()}${currentList.name}");
                      },
                    );
                  },
                ).toList(growable: false),
              ),
            ),
          ),
        ),
      ));
    }
    return children;
  }
}
