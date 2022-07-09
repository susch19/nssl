import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:nssl/localization/nssl_strings.dart';
import 'package:nssl/models/model_export.dart';
import 'package:nssl/server_communication//s_c.dart';
import 'package:nssl/server_communication/return_classes.dart';
import 'package:nssl/helper/iterable_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _historyDateTimesProvider = StateProvider<List<DateTime>>((ref) {
  return [];
});
final _shoppingItemsProvider = StateProvider<List<ShoppingItem>>((ref) {
  return [];
});
final _searchModeProvider = StateProvider.autoDispose<bool>((ref) {
  return false;
});

final _shoppingItemsGroupedProvider = Provider.family<Iterable<ShoppingItem>, DateTime>((ref, arg) {
  var items = ref.watch(_shoppingItemsProvider);

  var forDate = DateTime.utc(arg.year, arg.month, arg.day);
  return items.where((element) {
    var changed = element.changed!;
    var changedFormat = DateTime.utc(changed.year, changed.month, changed.day);
    return changedFormat == forDate;
  });
});

final _filterProvider = StateProvider.autoDispose<String>((ref) {
  return "";
});
final _filterAsLowercaseProvider = Provider.autoDispose<String>((ref) {
  return ref.watch(_filterProvider).toLowerCase();
});

final _filteredShoppingItemsGroupedProvider = Provider.family.autoDispose<Iterable<ShoppingItem>, DateTime>((ref, arg) {
  var items = ref.watch(_shoppingItemsGroupedProvider(arg));
  var isFiltering = ref.watch(_searchModeProvider);
  var filter = ref.watch(_filterAsLowercaseProvider);
  return items.where((element) => !isFiltering || element.name.toLowerCase().contains(filter));
});

final _filteredDateTimeProvider = Provider.autoDispose<Iterable<DateTime>>(
  (ref) {
    var dates = ref.watch(_historyDateTimesProvider);
    var isFiltering = ref.watch(_searchModeProvider);
    var filter = ref.watch(_filterAsLowercaseProvider);
    if (!isFiltering || filter.isEmpty) return dates;

    return dates.where((element) => ref
        .read(_filteredShoppingItemsGroupedProvider(element))
        .any((element) => element.name.toLowerCase().contains(filter)));
  },
);

final _tabCountProvider = Provider.autoDispose<int>((ref) => ref.watch(_filteredDateTimeProvider).length);

final _shoppingItemsFromServerProvider =
    FutureProvider.autoDispose.family<List<ShoppingItem>, int>((ref, listId) async {
  var o = await ShoppingListSync.getList(listId, null, bought: true);

  if (o.statusCode == 500) {
    return [];
  }

  var z = GetBoughtListResult.fromJson(o.body);

  var shoppingItems = <ShoppingItem>[];

  shoppingItems.addAll(z.products.map((f) => ShoppingItem(f.name, listId, f.sortOrder,
      id: f.id, amount: f.amount, changed: f.changed, created: f.created, crossedOut: false)));

  ref.read(_shoppingItemsProvider.notifier).state = shoppingItems;
  HashSet<DateTime> dates = HashSet();

  DateTime dateTimeToDate(DateTime dateTime) {
    return DateTime.utc(dateTime.year, dateTime.month, dateTime.day);
  }

  for (var item in shoppingItems) dates.add(dateTimeToDate(item.changed!));
  var dateList = dates.toList();
  dateList.sort(((a, b) => b.compareTo(a)));
  ref.read(_historyDateTimesProvider.notifier).state = dateList;

  return shoppingItems;
});

class BoughtItemsPage extends ConsumerStatefulWidget {
  BoughtItemsPage(this.listId, {Key? key, this.title}) : super(key: key);
  final String? title;
  final int listId;
  @override
  _BoughtItemsPagePageState createState() => new _BoughtItemsPagePageState(listId);
}

class _BoughtItemsPagePageState extends ConsumerState<BoughtItemsPage> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _mainScaffoldKey = GlobalKey<ScaffoldState>();

  var tec = TextEditingController();
  int k = 1;
  int listId;

  late TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(
      length: 0,
      initialIndex: 0,
      vsync: this,
    );
    tec.addListener(() {
      ref.read(_filterProvider.notifier).state = tec.text;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void didUpdateWidget(covariant BoughtItemsPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    var count = ref.watch(_tabCountProvider);
    if (count != _controller.length) {
      final oldIndex = _controller.index;
      _controller.dispose();
      _controller = TabController(
        length: count,
        initialIndex: max(0, min(oldIndex, count)),
        vsync: this,
      );
    }
  }

  _BoughtItemsPagePageState(this.listId);

  DateTime dateTimeToDate(DateTime dateTime) {
    return DateTime.utc(dateTime.year, dateTime.month, dateTime.day);
  }

  @override
  Widget build(BuildContext context) {
    var fromServer = ref.watch(_shoppingItemsFromServerProvider(listId));

    return fromServer.when(
      loading: () {
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
      },
      data: (data) {
        didUpdateWidget(this.widget);
        return Scaffold(
          key: _mainScaffoldKey,
          appBar: AppBar(
            title: !ref.watch(_searchModeProvider)
                ? Text(NSSLStrings.of(context).boughtProducts())
                : TextField(
                    decoration: InputDecoration(hintText: NSSLStrings.of(context).searchProductHint()),
                    controller: tec,
                    maxLines: 1,
                    autofocus: true,
                  ),
            bottom: TabBar(
              controller: _controller,
              isScrollable: true,
              indicator: getIndicator(),
              tabs: createTabs(),
            ),
            actions: [
              ref.watch(_searchModeProvider)
                  ? IconButton(
                      onPressed: () {
                        ref.read(_searchModeProvider.notifier).state = false;
                      },
                      icon: Icon(Icons.search_off))
                  : IconButton(
                      onPressed: () {
                        ref.read(_searchModeProvider.notifier).state = true;
                      },
                      icon: Icon(Icons.search))
            ],
          ),
          body: TabBarView(
            controller: _controller,
            children: createChildren(),
          ),
        );
      },
      error: (error, stackTrace) {
        return Scaffold(
            appBar: AppBar(
              title: Text(NSSLStrings.of(context).boughtProducts()),
              actions: <Widget>[],
            ),
            body: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text("An error occured $error")],
            ));
      },
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

  void showInSnackBar(String value, {Duration? duration, SnackBarAction? action}) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(value), duration: duration ?? Duration(seconds: 3), action: action));
  }

  List<Tab> createTabs() {
    var tabs = <Tab>[];
    var dates = ref.watch(_filteredDateTimeProvider);
    for (var item in dates) {
      tabs.add(
          Tab(text: "${item.year}-${item.month.toString().padLeft(2, '0')}-${item.day.toString().padLeft(2, '0')}"));
    }

    return tabs;
  }

  List<Widget> createChildren() {
    var currentList = ref.watch(currentListProvider);
    var children = <Widget>[];
    if (currentList == null) return children;
    var dates = ref.watch(_filteredDateTimeProvider);
    for (var item in dates) {
      var items = ref.watch(_filteredShoppingItemsGroupedProvider(item));
      children.add(SafeArea(
        top: false,
        bottom: false,
        child: Container(
          key: ObjectKey(item),
          padding: const EdgeInsets.all(12.0),
          child: Card(
            child: Center(
              child: ListView(
                children: items.map(
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
