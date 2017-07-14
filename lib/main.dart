import 'dart:convert';
import 'package:testProject/localization/nssl_messages_all.dart';
import 'package:testProject/options/themes.dart';
import 'package:testProject/pages/pages.dart';
import 'package:testProject/manager/manager_export.dart';
import 'package:testProject/models/model_export.dart';
import 'package:testProject/server_communication/return_classes.dart';
import 'package:testProject/server_communication/s_c.dart';
import 'package:testProject/simple_dialog_single_input.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:testProject/localization/nssl_strings.dart';
import 'package:testProject/firebase/cloud_messsaging.dart';

void main() {
  Startup.initialize().whenComplete(() => runApp(new NSSL()));
}

class NSSL extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Home();
  }
}

class Home extends StatefulWidget {
  static ThemeData theme = new ThemeData(
      primarySwatch: Colors.blue,
      accentColor: Colors.teal,
      accentColorBrightness: Brightness.dark,
      brightness: Brightness.light);
  static MaterialColor swatch = Colors.blue;

  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => new _HomeState();
}

class _HomeState extends State<Home> {
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
  NSSLStrings loc = NSSLStrings.instance;

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'NSSL',
      color: Colors.grey[500],
      theme: Themes.themes.first,
//      theme: new ThemeData(
//          primarySwatch: Home.swatch,
//          accentColorBrightness: Home.theme.accentColorBrightness,
//          primaryColorBrightness: Home.theme.primaryColorBrightness,
//          accentColor: Home.theme.accentColor),
      //(themed ? lTheme : dTheme).copyWith(),
      home: User.username == null ? mainAppLoginRegister() : mainAppHome(),
      routes: <String, WidgetBuilder>{
        '/login': (BuildContext context) => new LoginPage(),
        '/registration': (BuildContext context) => new Registration(),
        '/search': (BuildContext context) => new ProductAddPage(),
      },
      showPerformanceOverlay: performanceOverlay,
      showSemanticsDebugger: false,
      debugShowMaterialGrid: materialGrid,
      onLocaleChanged: onLocaleChanged,
    );
  }

  Future<LocaleQueryData> onLocaleChanged(Locale locale) async {
    final String localeString = locale.toString();
    await initializeMessages(localeString);
    Intl.defaultLocale = localeString;
    setState(() {}); //Refresh for new language
    return NSSLStrings.instance;
  }

  Scaffold mainAppHome() {
    return new Scaffold(
        key: _mainScaffoldKey,
        appBar: new AppBar(
            title: new Text(
              User?.currentList?.name ?? "No List Loaded",
              style: new TextStyle(fontStyle: FontStyle.italic),
            ),
            actions: <Widget>[
              new PopupMenuButton<String>(
                  onSelected: selectedOption,
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuItem<String>>[
                        const PopupMenuItem<String>(
                            value: 'Login/Register',
                            child: const Text('Login/Register')),
                        new PopupMenuItem<String>(
                            value: 'Options',
                            child:
                                new Text(NSSLStrings.instance.changeTheme())),
                        const PopupMenuItem<String>(
                            value: 'PerformanceOverlay',
                            child: const Text('Toggle Performance Overlay')),
                        const PopupMenuItem<String>(
                            value: 'materialGrid',
                            child: const Text('Toggle Materialgrid')),
                      ])
            ]),
        body: new Builder(builder: buildBody),
        drawer: _buildDrawer(context),
        persistentFooterButtons: [
          new FlatButton(
            child: new Text(NSSLStrings.instance.deleteCrossedOutPB()),
            onPressed: _deleteCrossedOutItems,
          ),
          new FlatButton(
              child: new Text(NSSLStrings.instance.addPB()),
              onPressed: _addWithoutSearchDialog),
          new FlatButton(
              child: new Text(NSSLStrings.instance.scanPB()),
              onPressed: _getEAN),
          new FlatButton(
              child: new Text(NSSLStrings.instance.searchPB()),
              onPressed: search)
        ]);
  }

  Scaffold mainAppLoginRegister() => new Scaffold(
        key: _mainScaffoldKey,
        resizeToAvoidBottomPadding: false,
        body: new LoginPage(),
      );

  Widget buildBody(BuildContext context) {
    cont = context;

    if (User.currentList == null ||
        User.currentList.shoppingItems == null ||
        User.currentList.shoppingItems.length == 0) return const Text("");

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

    var lv = new CustomScrollView(
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

    return new RefreshIndicator(
      child: lv,
      onRefresh: _handleMainListRefresh,
    );
  }

  void showInSnackBar(String value,
      {Duration duration: null, SnackBarAction action}) {
    _mainScaffoldKey.currentState.showSnackBar(new SnackBar(
        content: new Text(value),
        duration: duration ?? new Duration(seconds: 3),
        action: action));
  }

  void showInDrawerSnackBar(String value,
      {Duration duration: null, SnackBarAction action}) {
    _drawerScaffoldKey.currentState.showSnackBar(new SnackBar(
        content: new Text(value),
        duration: duration ?? new Duration(seconds: 3),
        action: action));
  }

  Future register() => Navigator.pushNamed(cont, "/registration");

  Future search() => Navigator.pushNamed(cont, "/search");

  Future login() => Navigator.pushNamed(cont, "/login");

  //Future handleDismissDrawer(DismissDirection dir, Widget w) =>
  //    handleDismiss(dir, w, drawerList.children);
  void handleDismissMain(DismissDirection dir, ShoppingItem s) {
    //TODO wait for server?
    var list = User.currentList;
    final String action =
        (dir == DismissDirection.endToStart) ? loc.archived() : loc.deleted();
    var index = list.shoppingItems.indexOf(s);
    setState(() => list.shoppingItems.remove(s));
//    _mainScaffoldKey.currentState.removeCurrentSnackBar();
    ShoppingListSync.deleteProduct(list.id, s.id);
    list.save();
    showInSnackBar(loc.youHaveActionItemMessage() + "${s.name} $action",
        action: new SnackBarAction(
            label: loc.undo(),
            onPressed: () {
              setState(() {
                list.shoppingItems.insert(index, s);
                ShoppingListSync.changeProduct(list.id, s.id, s.amount);
                _mainScaffoldKey.currentState.removeCurrentSnackBar();
                list.save();
              });
            }),
        duration: new Duration(seconds: 10));
  }

  void selectedOption(String s) {
    switch (s) {
      case "Login/Register":
        login();
        break;
      case "Options":
        Navigator
            .push(
                cont,
                new MaterialPageRoute<DismissDialogAction>(
                  builder: (BuildContext context) => new CustomThemePage(),
                  fullscreenDialog: true,
                ))
            .then((x) => setState(() {
                  Home.theme = Home.theme;
                }));

        break;
      case "PerformanceOverlay":
        setState(() => performanceOverlay = !performanceOverlay);
        break;
      case "materialGrid":
        setState(() => materialGrid = !materialGrid);
        break;
    }
  }

  void changeCurrentList(int index) => setState(() {
        User.currentListIndex = index;
        setState(() => User.currentList = User.shoppingLists[index]);
        if (FileManager.fileExists("lastList.txt"))
          FileManager.deleteFile("lastList.txt");
        FileManager.createFile("lastList.txt");
        FileManager.write("lastList.txt", User.currentList.id.toString());
      });

  Future<Null> _getEAN() async {
    await platform.invokeMethod('getEAN');
    platform.setMethodCallHandler(setEAN);
  }

  Future<dynamic> setEAN(MethodCall methodCall) async {
    String method = methodCall.method;

    if (method == "setEAN") {
      var list = User.currentList;
      ean = methodCall.arguments;
      var firstRequest = await ProductSync.getProduct(ean);
      var z = JSON.decode((firstRequest).body);
      var k = ProductAddPage.fromJson(z);
      if (k.success) {
        var item = list.shoppingItems
            .firstWhere((x) => x.name == k.name, orElse: () => null);
        ShoppingItem afterAdd;
        if (item != null) {
          var answer =
              await ShoppingListSync.changeProduct(list.id, item.id, 1);
          var p = ChangeListItemResult.fromJson((answer).body);
          setState(() {
            item.amount = p.amount;
          });
        } else {
          var p = AddListItemResult.fromJson(
              (await ShoppingListSync.addProduct(list.id, k.name, '-', 1))
                  .body);
          afterAdd = new ShoppingItem()
            ..name = p.name
            ..amount = 1
            ..id = p.productId;
          setState(() => list.shoppingItems.add(afterAdd));
        }
        list.save();
        return;
      }
      Navigator.push(
          cont,
          new MaterialPageRoute<DismissDialogAction>(
            builder: (BuildContext context) => new AddProductToDatabase(ean),
            fullscreenDialog: true,
          ));
    }
  }

  void addListDialog() {
    var sd = SimpleDialogSingleInput.create(
        hintText: loc.newNameOfListHint(),
        labelText: loc.listName(),
        onSubmitted: createNewList,
        title: loc.addNewListTitle(),
        context: cont);
//rename ? (s) => renameList(listId, s)
    showDialog(child: sd, context: cont);
  }

  Future renameListDialog(int listId) => showDialog(
      context: cont,
      child: SimpleDialogSingleInput.create(
          hintText: loc.renameListHint(),
          labelText: loc.listName(),
          onSubmitted: (s) => renameList(listId, s),
          title: loc.renameListTitle(),
          context: cont));

  Future createNewList(String listName) async {
    var res = await ShoppingListSync.addList(listName);
    var newListRes = AddListResult.fromJson(res.body);
    var newList = new ShoppingList()
      ..id = newListRes.id
      ..name = newListRes.name;
    setState(() => User.shoppingLists.add(newList));
    User.currentListIndex = User.shoppingLists.indexOf(newList);
    firebaseMessaging
        .subscribeToTopic(newList.id.toString() + "shoppingListTopic");
    FileManager.createFile("ShoppingLists/${newList.id}.sl");
    FileManager.writeln("ShoppingLists/${newList.id}.sl", newList.name);
  }

  bool b = true;

  Widget _buildDrawer(BuildContext context) {
    var userheader = new UserAccountsDrawerHeader(
      accountName: new Text(User.username ?? loc.notLoggedInYet()),
      accountEmail: new Text(User.eMail ?? loc.notLoggedInYet()),
      currentAccountPicture: new FloatingActionButton(
        child: new CircleAvatar(
            child: new Text(User.username.substring(0, 2).toUpperCase()),
            backgroundColor: Themes.themes.first.accentColor),
        backgroundColor: Themes.themes.first.accentColor,
        onPressed: null,
        highlightElevation: 0.0,
      ),
    );

    var list = User.shoppingLists.isNotEmpty
        ? User.shoppingLists
            .map((x) => new ListTile(
                  key: new ValueKey(x),
                  title: new Text(x.name),
                  onTap: () => changeCurrentList(User.shoppingLists.indexOf(x)),
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
                                    NSSLStrings.instance.contributors()),
                              ),
                            ),
                            new PopupMenuItem<String>(
                                value: x.id.toString() + "\u{1E}" + 'Rename',
                                child: new ListTile(
                                    leading: const Icon(Icons.mode_edit),
                                    title: new Text(
                                        NSSLStrings.instance.rename()))),
                            const PopupMenuDivider() //ignore: list_element_type_not_assignable
                                ,
                            new PopupMenuItem<String>(
                                value: x.id.toString() + "\u{1E}" + 'Remove',
                                child: new ListTile(
                                    leading: const Icon(Icons.delete),
                                    title: new Text(
                                        NSSLStrings.instance.remove())))
                          ]),
                ))
            .toList()
        : [
            new ListTile(title: new Text(loc.noListsInDrawerMessage())),
          ];
    //drawerList = new MyList<ListTile>(children: list);

    var d = new Scaffold(
        key: _drawerScaffoldKey,
        body: new RefreshIndicator(
            child: new ListView(children: [
              userheader,
              new Column(children: list),
            ], physics: const AlwaysScrollableScrollPhysics()),
            onRefresh: _handleDrawerRefresh,
            displacement: 1.0),
        persistentFooterButtons: [
          new FlatButton(
              child: new Text(NSSLStrings.instance.addListPB()),
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
      case "Rename":
        renameListDialog(id);
        break;
      case "Remove":
        var res = Result.fromJson((await ShoppingListSync.deleteList(id)).body);
        if (!res.success)
          showInDrawerSnackBar(res.error);
        else {
          showInDrawerSnackBar(
              User.shoppingLists.firstWhere((x) => x.id == id).name +
                  " " +
                  loc.removed());
          setState(() => User.shoppingLists.removeWhere((x) => x.id == id));
        }
        break;
    }
  }

  Future _handleDrawerRefresh() async {
    var result =
        GetListsResult.fromJson((await ShoppingListSync.getLists()).body);
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
      list.save();
    }
  }

  Future _handleMainListRefresh() => _handleListRefresh(User.currentList.id);

  Future _handleListRefresh(int listId) async {
    await User.shoppingLists.firstWhere((s) => s.id == listId).refresh();
    setState(() {});
  }

  Future shoppingItemChange(ShoppingItem s, int change) async {
    var res = ChangeListItemResult.fromJson((await ShoppingListSync
            .changeProduct(User.currentList.id, s.id, change))
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
    await User.currentList.saveCrossedOut();
  }

  void _addWithoutSearchDialog() {
    showDialog(
        context: cont,
        child: SimpleDialogSingleInput.create(
            context: cont,
            title: loc.addProduct(),
            hintText: loc.addProductWithoutSearch(),
            labelText: loc.productName(),
            onSubmitted: _addWithoutSearch));
  }

  Future renameList(int id, String text) async {
    var put = await ShoppingListSync.changeLName(id, text);
    showInDrawerSnackBar("${put.statusCode}" + put.reasonPhrase);
    var res = Result.fromJson((put.body));
    if (!res.success) showInDrawerSnackBar(res.error);
  }

  Future _addWithoutSearch(String value) async {
    var list = User.currentList;
    var res = await ShoppingListSync.addProduct(list.id, value, null, 1);
    if (res.statusCode != 200) showInSnackBar(res.reasonPhrase);
    var product = AddListItemResult.fromJson(res.body);
    if (!product.success) showInSnackBar(product.error);
    setState(() => list.shoppingItems.add(new ShoppingItem()
      ..id = product.productId
      ..amount = 1
      ..name = product.name
      ..crossedOut = false));
  }

  Future _deleteCrossedOutItems() async {
    var list = User.currentList;
    var sublist = list.shoppingItems.where((s) => s.crossedOut).toList();
    var res = await ShoppingListSync.deleteProducts(
        list.id, sublist.map((s) => s.id).toList());
    if (!Result.fromJson(res.body).success) return;
    setState(() {
      for (var item in sublist) list.shoppingItems.remove(item);
    });
    list.save();
    showInSnackBar(loc.messageDeleteAllCrossedOut(),
        duration: new Duration(seconds: 10),
        action: new SnackBarAction(
            label: loc.undo(),
            onPressed: () async {
              var res = await ShoppingListSync.changeProducts(
                  list.id,
                  sublist.map((s) => s.id).toList(),
                  sublist.map((s) => s.amount).toList());
              var hashResult = HashResult.fromJson(res.body);
              int ownHash = 0;
              for (var item in sublist) ownHash += item.id + item.amount;
              if (ownHash == hashResult.hash)
                setState(() => list.shoppingItems.addAll(sublist));
              else
                _handleListRefresh(list.id);
            }));
  }

  @override
  initState() {
    super.initState();
    firebaseMessaging.configure(
        onMessage: (x) => CloudMessaging.onMessage(x, setState));

    /*firebaseMessaging.getToken().then((String token) {
    });*/
  }
}
