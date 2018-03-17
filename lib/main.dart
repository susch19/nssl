import 'dart:convert';
import 'package:scandit/scandit.dart';
import 'package:testProject/helper/simple_dialog.dart';
import 'package:testProject/options/themes.dart';
import 'package:testProject/pages/pages.dart';
import 'package:testProject/manager/manager_export.dart';
import 'package:testProject/models/model_export.dart';
import 'package:testProject/server_communication/return_classes.dart';
import 'package:testProject/server_communication/s_c.dart';
import 'package:testProject/helper/simple_dialog_single_input.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:testProject/localization/nssl_strings.dart';
import 'package:testProject/firebase/cloud_messsaging.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
// iWonderHowLongThisTakes();
  Startup.initialize().then((s) {
    //if (s) Startup.initializeNewListsFromServer();
    runApp(new NSSLPage());
  });
}

class NSSL extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new NSSLPage();
  }
}

class NSSLPage extends StatefulWidget {
  NSSLPage({Key key}) : super(key: key);

  static _NSSLState state;
  @override
  _NSSLState createState() {
    state = new _NSSLState();
    return state;
  }
}

class _NSSLState extends State<NSSLPage> {
  _NSSLState() : super();
  static BuildContext cont;

  final GlobalKey<ScaffoldState> _mainScaffoldKey =
      new GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> _drawerScaffoldKey =
      new GlobalKey<ScaffoldState>();

  static const platform =
      const MethodChannel('com.yourcompany.testProject/Scandit');

  String ean = "";
  bool performanceOverlay = false;
  bool materialGrid = false;

  @override
  initState() {
    super.initState();
    firebaseMessaging.configure(
        onMessage: (x) => CloudMessaging.onMessage(x, setState));
    for (var list in User.shoppingLists)
      if (list.messagingEnabled) list.subscribeForFirebaseMessaging();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'NSSL',
      color: Colors.grey[500],
      localizationsDelegates: <LocalizationsDelegate<dynamic>>[
        new _NSSLLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const <Locale>[
        const Locale('en', 'US'),
        const Locale('de', 'DE'),
      ],
      theme: Themes.themes.first,
      home: User.username == null ? mainAppLoginRegister() : mainAppHome(),
      routes: <String, WidgetBuilder>{
        '/login': (BuildContext context) => new LoginPage(),
        '/registration': (BuildContext context) => new Registration(),
        '/search': (BuildContext context) => new ProductAddPage(),
        '/forgot_password': (BuildContext context) => new CustomThemePage(),
      },
      showPerformanceOverlay: performanceOverlay,
      showSemanticsDebugger: false,
      debugShowMaterialGrid: materialGrid,
    );
  }

  Scaffold mainAppHome() => new Scaffold(
      key: _mainScaffoldKey,
      resizeToAvoidBottomPadding: false,
      body: new HomePage() //new CustomThemePage()//LoginPage(),
      );

  Scaffold mainAppLoginRegister() => new Scaffold(
        key: _mainScaffoldKey,
        resizeToAvoidBottomPadding: false,
        body: new LoginPage(),
      );
}

class _NSSLLocalizationsDelegate extends LocalizationsDelegate<NSSLStrings> {
  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<NSSLStrings> load(Locale locale) => NSSLStrings.load(locale);

  @override
  bool shouldReload(_NSSLLocalizationsDelegate old) => false;
}

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => new HomePageState();
}

class HomePageState extends State<HomePage> with TickerProviderStateMixin {
  BuildContext cont;

  final GlobalKey<ScaffoldState> _mainScaffoldKey =
      new GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> _drawerScaffoldKey =
      new GlobalKey<ScaffoldState>();

  static const platform =
      const MethodChannel('com.yourcompany.testProject/Scandit');

  String ean = "";
  bool performanceOverlay = false;
  bool materialGrid = false;

  AnimationController _controller;
  Animation<double> _drawerContentsOpacity;
  Animation<Offset> _drawerDetailsPosition;
  bool _showDrawerContents = true;

  @override
  void initState() {
    super.initState();
    Startup.initializeNewListsFromServer();
    Scandit.initialize("***REMOVED***");
    setState(() {});
    _controller = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _drawerContentsOpacity = new CurvedAnimation(
      parent: new ReverseAnimation(_controller),
      curve: Curves.fastOutSlowIn,
    );
    _drawerDetailsPosition = new Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    )
        .animate(new CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    ));
  }

  @override
  Widget build(BuildContext context) {
//    return new WillPopScope(
//        onWillPop: _onWillPop,
//        child:

    return new Scaffold(
        key: _mainScaffoldKey,
        appBar: new AppBar(
            title: new Text(
              User?.currentList?.name ?? NSSLStrings.of(context).noListLoaded(),
            ),
            actions: <Widget>[
              new PopupMenuButton<String>(
                  onSelected: selectedOption,
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuItem<String>>[
                        new PopupMenuItem<String>(
                            value: 'Options',
                            child: new Text(
                                NSSLStrings.of(context).changeTheme())),
                        new PopupMenuItem<String>(
                            value: 'deleteCrossedOut',
                            child: new Text(
                                NSSLStrings.of(context).deleteCrossedOutPB())),
                      ])
            ]),
        body: buildBody(context),
        drawer: _buildDrawer(context),
        persistentFooterButtons: [
          new FlatButton(
              child: new Text(NSSLStrings.of(context).addPB()),
              onPressed: _addWithoutSearchDialog),
          new FlatButton(
              child: new Text(NSSLStrings.of(context).scanPB()),
              onPressed: _getEAN),
          new FlatButton(
              child: new Text(NSSLStrings.of(context).searchPB()),
              onPressed: search),
        ]);
  }

  Widget buildBody(BuildContext context) {
    cont = context;

    if (User.currentList == null || User.currentList.shoppingItems == null)
      return const Text("");
    var lv;
    if (User.currentList.shoppingItems.length > 0) {
      User.currentList?.shoppingItems?.sort((a, b) => a.id.compareTo(b.id));
      User.currentList?.shoppingItems?.sort(
          (a, b) => a.crossedOut.toString().compareTo(b.crossedOut.toString()));
      var mainList = User.currentList.shoppingItems.map((x) {
        var lt = new ListTile(
          title: new Row(children: [
            new Expanded(
                child: new Text(
              x.name,
              maxLines: 2,
              softWrap: true,
              style: new TextStyle(
                  decoration: x.crossedOut
                      ? TextDecoration.lineThrough
                      : TextDecoration.none),
            )),
          ]),
          leading: new PopupMenuButton<String>(
            child: new Row(children: [
              new Text(x.amount.toString() + "x"),
              const Icon(Icons.expand_more, size: 16.0),
              new SizedBox(height: 38.0), //for larger clickable size (2 Lines)
            ]),
            initialValue: x.amount.toString(),
            onSelected: (y) => shoppingItemChange(x, int.parse(y) - x.amount),
            itemBuilder: buildChangeMenuItems,
          ),
          onTap: () => crossOutMainListItem(x),
          onLongPress: () => renameListItem(x),
        );

        return new Dismissible(
          key: new ValueKey(x),
          child: lt,
          onDismissed: (DismissDirection d) => handleDismissMain(d, x),
          direction: DismissDirection.startToEnd,
          background: new Container(
              decoration:
                  new BoxDecoration(color: Theme.of(context).primaryColor),
              child: new ListTile(
                  leading: new Icon(Icons.delete,
                      color: Theme.of(context).accentIconTheme.color,
                      size: 36.0))),
        );
      }).toList(growable: true);

      lv = new CustomScrollView(
        slivers: [
          new SliverFixedExtentList(
              delegate: new SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                return new Container(
                  alignment: FractionalOffset.center,
                  child: mainList[index],
                );
              }, childCount: mainList.length),
              itemExtent: 50.0)
        ],
        physics: const AlwaysScrollableScrollPhysics(),
      );
    } else
      lv = new ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: <Widget>[new ListTile(title: const Text(""))],
      );
    return new RefreshIndicator(
      child: lv,
      onRefresh: _handleMainListRefresh,
    );
  }

  void showInSnackBar(String value,
      {Duration duration, SnackBarAction action}) {
    _mainScaffoldKey.currentState.showSnackBar(new SnackBar(
        content: new Text(value),
        duration: duration ?? new Duration(seconds: 3),
        action: action));
  }

  void showInDrawerSnackBar(String value,
      {Duration duration, SnackBarAction action}) {
    _drawerScaffoldKey.currentState.showSnackBar(new SnackBar(
        content: new Text(value),
        duration: duration ?? new Duration(seconds: 3),
        action: action));
  }

  Future register() => Navigator.pushNamed(cont, "/registration");

  Future search() => Navigator.pushNamed(cont, "/search");

  Future login() => Navigator.pushNamed(cont, "/login");

  Future addProduct() => Navigator.pushNamed(cont, "/addProduct");

  void handleDismissMain(DismissDirection dir, ShoppingItem s) {
    var list = User.currentList;
    final String action = (dir == DismissDirection.endToStart)
        ? NSSLStrings.of(context).archived()
        : NSSLStrings.of(context).deleted();
    var index = list.shoppingItems.indexOf(s);
    setState(() => list.shoppingItems.remove(s));
//    _mainScaffoldKey.currentState.removeCurrentSnackBar();
    ShoppingListSync.deleteProduct(list.id, s.id, context);
    list.save();
    showInSnackBar(
        NSSLStrings.of(context).youHaveActionItemMessage() +
            "${s.name} $action",
        action: new SnackBarAction(
            label: NSSLStrings.of(context).undo(),
            onPressed: () {
              setState(() {
                list.shoppingItems.insert(index, s);
                ShoppingListSync.changeProductAmount(
                    list.id, s.id, s.amount, context);
                _mainScaffoldKey.currentState.removeCurrentSnackBar();
                list.save();
              });
            }),
        duration: new Duration(seconds: 10));
  }

  Future selectedOption(String s) async {
    switch (s) {
      case "Login/Register":
        login();
        break;
      case "Options":
        await Navigator.push(
            cont,
            new MaterialPageRoute<DismissDialogAction>(
              builder: (BuildContext context) => new CustomThemePage(),
              fullscreenDialog: true,
            ));
        NSSLPage.state.setState(() {});
        break;
      case "PerformanceOverlay":
        setState(() => performanceOverlay = !performanceOverlay);
        break;
      case "deleteCrossedOut":
        _deleteCrossedOutItems();
        break;
      case "materialGrid":
        setState(() => materialGrid = !materialGrid);
        break;
      case "ChangePassword":
        Navigator.push(
            cont,
            new MaterialPageRoute<DismissDialogAction>(
              builder: (BuildContext context) => new ChangePasswordPage(),
              fullscreenDialog: true,
            ));
        break;
    }
  }

  void changeCurrentList(int index) => setState(() {
        User.currentListIndex = index;
        setState(() => User.currentList = User.shoppingLists[index]);
        User.currentListIndex = User.shoppingLists[index].id;
        User.save();
        Navigator.of(context).pop();
      });

  Future<Null> _getEAN() async {

    ean = await Scandit.scan();

    if (ean == "" || ean == "Permissions denied") return;

    var list = User.currentList;
    var firstRequest = await ProductSync.getProduct(ean, cont);
    var z = JSON.decode((firstRequest).body);
    var k = ProductAddPage.fromJson(z);

    if (k.success) {
      RegExp reg = new RegExp("([0-9]+[.,]?[0-9]*(\\s)?[gkmlGKML]{1,2})");
      String name =
          reg.hasMatch(k.name) ? k.name : "${k.name} ${k.quantity}${k.unit}";
      var item = list.shoppingItems
          .firstWhere((x) => x.name == name, orElse: () => null);
      ShoppingItem afterAdd;
      if (item != null) {
        var answer = await ShoppingListSync.changeProductAmount(
            list.id, item.id, 1, cont);
        var p = ChangeListItemResult.fromJson((answer).body);
        setState(() {
          item.amount = p.amount;
        });
      } else {
        var p = AddListItemResult.fromJson(
            (await ShoppingListSync.addProduct(list.id, name, '-', 1, cont))
                .body);
        afterAdd = new ShoppingItem()
          ..name = "${p.name}"
          ..amount = 1
          ..id = p.productId;
        setState(() => list.shoppingItems.add(afterAdd));
      }
      list.save();
      return;
    }
    Navigator.push(
        context,
        new MaterialPageRoute<DismissDialogAction>(
            builder: (BuildContext context) => new AddProductToDatabase(ean),
            fullscreenDialog: true));
  }

  void addListDialog() {
    var sd = SimpleDialogSingleInput.create(
        hintText: NSSLStrings.of(context).newNameOfListHint(),
        labelText: NSSLStrings.of(context).listName(),
        onSubmitted: createNewList,
        title: NSSLStrings.of(context).addNewListTitle(),
        context: cont);
//rename ? (s) => renameList(listId, s)

    showDialog(child: sd, context: cont);
  }

  Future renameListDialog(int listId) {
    return showDialog(
        context: cont,
        child: SimpleDialogSingleInput.create(
            hintText: NSSLStrings.of(context).renameListHint(),
            labelText: NSSLStrings.of(context).listName(),
            onSubmitted: (s) => renameList(listId, s),
            title: NSSLStrings.of(context).renameListTitle(),
            context: cont));
  }

  Future createNewList(String listName) async {
    var res = await ShoppingListSync.addList(listName, cont);
    var newListRes = AddListResult.fromJson(res.body);
    var newList = new ShoppingList()
      ..id = newListRes.id
      ..name = newListRes.name;
    setState(() => User.shoppingLists.add(newList));
    User.currentListIndex = User.shoppingLists.indexOf(newList);
    firebaseMessaging
        .subscribeToTopic(newList.id.toString() + "shoppingListTopic");
    newList.save();
  }

  Widget _buildDrawer(BuildContext context) {
    var userheader = new UserAccountsDrawerHeader(
      accountName:
          new Text(User.username ?? NSSLStrings.of(context).notLoggedInYet()),
      accountEmail:
          new Text(User.eMail ?? NSSLStrings.of(context).notLoggedInYet()),
      currentAccountPicture: new CircleAvatar(
          child: new Text(User.username.substring(0, 2)?.toUpperCase()),
          backgroundColor: Themes.themes.first.accentColor),
      onDetailsPressed: () {
        _showDrawerContents = !_showDrawerContents;
        _showDrawerContents ? _controller.reverse() : _controller.forward();
      },
    );

    var list = User.shoppingLists.isNotEmpty
        ? User.shoppingLists
            .map((x) => new ListTile(
                  key: new ValueKey(x),
                  title: new Text(x.name),
                  onTap: () => changeCurrentList(User.shoppingLists.indexOf(
                      User.shoppingLists.firstWhere((y) => y.id == x.id))),
                  trailing: new PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      onSelected: drawerListItemMenuClicked,
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                            new PopupMenuItem<String>(
                              value:
                                  x.id.toString() + "\u{1E}" + "Contributors",
                              child: new ListTile(
                                leading: const Icon(Icons.person_add),
                                title: new Text(
                                    NSSLStrings.of(context).contributors()),
                              ),
                            ),
//                            new PopupMenuItem<String>(
//                              value:
//                              x.id.toString() + "\u{1E}" + "BoughtList",
//                              child: new ListTile(
//                                leading: const Icon(Icons.history),
//                                title: new Text("BoughtList"),
//                                   // NSSLStrings.of(context).contributors()),
//                              ),
//                            ),
                            new PopupMenuItem<String>(
                                value: x.id.toString() + "\u{1E}" + 'Rename',
                                child: new ListTile(
                                    leading: const Icon(Icons.mode_edit),
                                    title: new Text(
                                        NSSLStrings.of(context).rename()))),
                            new PopupMenuItem<String>(
                                value: x.id.toString() + "\u{1E}" + 'Auto-Sync',
                                child: new ListTile(
                                    leading: new Icon(x.messagingEnabled
                                        ? Icons.check_box
                                        : Icons.check_box_outline_blank),
                                    title: new Text(
                                        NSSLStrings.of(context).autoSync()))),
                            const PopupMenuDivider(),
                            new PopupMenuItem<String>(
                                value: x.id.toString() + "\u{1E}" + 'Remove',
                                child: new ListTile(
                                    leading: const Icon(Icons.delete),
                                    title: new Text(
                                        NSSLStrings.of(context).remove())))
                          ]),
                ))
            .toList()
        : [
            new ListTile(
                title:
                    new Text(NSSLStrings.of(context).noListsInDrawerMessage())),
          ];
    //drawerList = new MyList<ListTile>(children: list);
    var emptyListTiles = new List<ListTile>();
    for (int i = 0; i < list.length - 2; i++)
      emptyListTiles.add(new ListTile(
        title: const Text(("")),
      ));
    var d = new Scaffold(
        key: _drawerScaffoldKey,
        body: new RefreshIndicator(
            child: new ListView(
              children: <Widget>[
                userheader,
                new Stack(
                  children: <Widget>[
                    new FadeTransition(
                      opacity: _drawerContentsOpacity,
                      child: new Column(children: list),
                    ),
                    new SlideTransition(
                      position: _drawerDetailsPosition,
                      child: new FadeTransition(
                        opacity: new ReverseAnimation(_drawerContentsOpacity),
                        child: new Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            new ListTile(
                              leading: const Icon(Icons.sync),
                              title: new Text(
                                NSSLStrings.of(context).changePasswordPD(),
                              ),
                              onTap: () => selectedOption("ChangePassword"),
                            ),
                            new ListTile(
                              leading: const Icon(Icons.exit_to_app),
                              title: new Text(NSSLStrings.of(context).logout()),
                              onTap: () async {
                                await User.delete();
                                User.username = null;
                                User.eMail = null;
                                User.token = null;
                                runApp(new NSSL());
                              },
                            ),
                            new Column(children: emptyListTiles)
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              physics: new AlwaysScrollableScrollPhysics(),
            ),
            onRefresh: _handleDrawerRefresh,
            displacement: 1.0),
        persistentFooterButtons: [
          new FlatButton(
              child: new Text(NSSLStrings.of(context).addListPB()),
              onPressed: addListDialog)
        ]);

    return new Drawer(child: d);
  }

  Future drawerListItemMenuClicked(String value) async {
    var splitted = value.split('\u{1E}');
    int id = int.parse(splitted[0]);
    switch (splitted[1]) {
      case "Contributors":
        Navigator.push(
            cont,
            new MaterialPageRoute<DismissDialogAction>(
              builder: (BuildContext context) => new ContributorsPage(id),
              fullscreenDialog: true,
            ));
        break;
      case "BoughtList":
        Navigator.push(
            cont,
            new MaterialPageRoute<DismissDialogAction>(
              builder: (BuildContext context) => new ContributorsPage(id),
              fullscreenDialog: true,
            ));
        break;
      case "Rename":
        renameListDialog(id);
        break;
      case "Remove":
        var deleteList = User.shoppingLists.firstWhere((x) => x.id == id);
        showDialog(
            context: cont,
            child: SimpleDialogAcceptDeny.create(
                title: "Delete List " + deleteList.name,
                text:
                    "Do you really want to delete the list? This CAN'T be undone!",
                onSubmitted: (s) async {
                  var res = Result.fromJson(
                      (await ShoppingListSync.deleteList(id, cont)).body);
                  if (!res.success)
                    showInDrawerSnackBar(res.error);
                  else {
                    showInDrawerSnackBar(deleteList.name +
                        " " +
                        NSSLStrings.of(context).removed());
                    if (User.currentList.id == id) {
                      changeCurrentList(User.shoppingLists
                        .indexOf(
                            User.shoppingLists.firstWhere((l) => l.id != id)));
                    }
                    setState(() =>
                        User.shoppingLists.removeWhere((x) => x.id == id));
                  }
                },
                context: cont));
        break;
      case "Auto-Sync":
        var list = User.shoppingLists.firstWhere((x) => x.id == id);
        list.messagingEnabled
            ? list.unsubscribeFromFirebaseMessaging()
            : list.subscribeForFirebaseMessaging();
        list.messagingEnabled = !list.messagingEnabled;
        list.save();
        break;
    }
  }

  Future _handleDrawerRefresh() async
  {
    await ShoppingList.reloadAllLists(context);
    setState(()=>{});
  }


  Future _handleMainListRefresh() => _handleListRefresh(User.currentList.id);

  Future _handleListRefresh(int listId) async {
    await User.shoppingLists.firstWhere((s) => s.id == listId).refresh(cont);
    setState(() {});
  }

  Future shoppingItemChange(ShoppingItem s, int change) async {
    var res = ChangeListItemResult.fromJson((await ShoppingListSync
            .changeProductAmount(User.currentList.id, s.id, change, cont))
        .body);
    setState(() {
      s.id = res.id;
      s.amount = res.amount;
      s.name = res.name;
    });
  }

  List<PopupMenuEntry<String>> buildChangeMenuItems(BuildContext context) {
    var list = new List<PopupMenuEntry<String>>();
    for (int i = 1; i <= 30; i++)
      list.add(new PopupMenuItem<String>(
          value: i.toString(), child: new Text(i.toString())));
    return list;
  }

  Future crossOutMainListItem(ShoppingItem x) async {
    setState(() => x.crossedOut = !x.crossedOut);
    await User.currentList.save();
  }

  void _addWithoutSearchDialog() {
    showDialog(
        context: cont,
        child: SimpleDialogSingleInput.create(
            context: cont,
            title: NSSLStrings.of(context).addProduct(),
            hintText: NSSLStrings.of(context).addProductWithoutSearch(),
            labelText: NSSLStrings.of(context).productName(),
            onSubmitted: _addWithoutSearch));
  }

  Future renameList(int id, String text) async {
    var put = await ShoppingListSync.changeLName(id, text, cont);
    showInDrawerSnackBar("${put.statusCode}" + put.reasonPhrase);
    var res = Result.fromJson((put.body));
    if (!res.success) showInDrawerSnackBar(res.error);
  }

  Future _addWithoutSearch(String value) async {
    var list = User.currentList;
    var same = list.shoppingItems
        .where((x) => x.name.toLowerCase() == value.toLowerCase());
    if (same.length > 0) {
      var res = await ShoppingListSync.changeProductAmount(
          list.id, same.first.id, 1, cont);
      if (res.statusCode != 200) showInSnackBar(res.reasonPhrase);
      var product = ChangeListItemResult.fromJson(res.body);
      if (!product.success) showInSnackBar(product.error);
      setState(() => same.first.amount = product.amount);
      same.first;
    } else {
      var res =
          await ShoppingListSync.addProduct(list.id, value, null, 1, cont);
      if (res.statusCode != 200) showInSnackBar(res.reasonPhrase);
      var product = AddListItemResult.fromJson(res.body);
      if (!product.success) showInSnackBar(product.error);
      setState(() => list.shoppingItems.add(new ShoppingItem()
        ..id = product.productId
        ..amount = 1
        ..name = product.name
        ..crossedOut = false));
    }
  }

  Future _deleteCrossedOutItems() async {
    var list = User.currentList;
    var sublist = list.shoppingItems.where((s) => s.crossedOut).toList();
    var res = await ShoppingListSync.deleteProducts(
        list.id, sublist.map((s) => s.id).toList(), cont);
    if (!Result.fromJson(res.body).success) return;
    setState(() {
      for (var item in sublist) list.shoppingItems.remove(item);
    });
    list.save();
    showInSnackBar(NSSLStrings.of(context).messageDeleteAllCrossedOut(),
        duration: new Duration(seconds: 10),
        action: new SnackBarAction(
            label: NSSLStrings.of(context).undo(),
            onPressed: () async {
              var res = await ShoppingListSync.changeProducts(
                  list.id,
                  sublist.map((s) => s.id).toList(),
                  sublist.map((s) => s.amount).toList(),
                  cont);
              var hashResult = HashResult.fromJson(res.body);
              int ownHash = 0;
              for (var item in sublist) ownHash += item.id + item.amount;
              if (ownHash == hashResult.hash){
                setState(() => list.shoppingItems.addAll(sublist));
                list.save();
              }
              else
                _handleListRefresh(list.id);
            }));
  }

  renameListItem(ShoppingItem x) {
    showDialog(
        context: cont,
        child: SimpleDialogSingleInput.create(
            context: cont,
            title: NSSLStrings.of(context).renameListItem(),
            hintText: NSSLStrings.of(context).renameListHint(),
            labelText: NSSLStrings.of(context).renameListItemLabel(),
            defaultText: x.name,
            maxLines: 2,
            onSubmitted: (s) async {
              var res = ChangeListItemResult.fromJson((await ShoppingListSync
                      .changeProductName(User.currentList.id, x.id, s, cont))
                  .body);
              setState(() {
                x.id = res.id;
                x.amount = res.amount;
                x.name = res.name;
              });
            }));
  }
}
