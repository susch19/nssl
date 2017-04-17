// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'dart:async';

typedef void ListDismissCallback(DismissDirection direction, Widget item);

class MyList<Widget> extends StatefulWidget {
  MyList({
    Key key,
    this.children,
    this.divider: true,
    this.onRefresh,
    this.onDismiss,
    this.dismissDirection: DismissDirection.horizontal,
  })
      : super(key: key);

  // static const String routeName = '/list';
  List<Widget> children;
  bool divider;
  DismissDirection dismissDirection;

  final ListDismissCallback onDismiss;
  final RefreshCallback onRefresh;

  MyList<Widget> copy() {
    return new MyList<Widget>(
        onRefresh: this.onRefresh, onDismiss: this.onDismiss)
      ..children = this.children
      ..divider = this.divider
      ..dismissDirection = this.dismissDirection;
  }

  @override
  MyListState createState() => new MyListState<Widget>(
      children: children,
      showDividers: divider,
      onRefresh: onRefresh,
      onDismiss: onDismiss,
      dismissDirection: dismissDirection);
}

class MyListState<Widget> extends State<MyList> {
  MyListState(
      {Key key,
      this.children,
      this.showDividers: true,
      this.onRefresh,
      this.onDismiss,
      this.dismissDirection: DismissDirection.horizontal})
      : super();
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  bool _dense = false;
  bool showDividers;
  List<Widget> children;
  AppBar appBar;
  DismissDirection dismissDirection;


  final RefreshCallback onRefresh;
  final ListDismissCallback onDismiss;

  Future<Null> refresh() {
    Completer<Null> completer = new Completer<Null>();
    new Timer(new Duration(seconds: 3), () {
      completer.complete(null);
    });
    return completer.future.then((_) {
      scaffoldKey.currentState?.showSnackBar(new SnackBar(
          content: new Text("Refresh complete"),
          action: new SnackBarAction(
              label: 'RETRY',
              onPressed: () {
                _refreshIndicatorKey.currentState.show();
              })));
    });
  }

  Widget buildListTile(BuildContext context, Object item) {

    return onDismiss == null
        ? item
        : new Dismissible(
            key: new ObjectKey(item),
            child: item,
            onDismissed: (DismissDirection d) => onDismiss(d, item),
            direction: dismissDirection,
            background: new Container(
                decoration: new BoxDecoration(
                    backgroundColor: Theme.of(context).primaryColor),
                child: new ListTile(
                    leading: new Icon(Icons.delete,
                        color: Theme.of(context).accentIconTheme.color,
                        size: 36.0))),
          );
  }



  @override
   build(BuildContext context) {


    Iterable listItems =
        children //.map((t) => new ListTile(title: new Text(t.toString())))
            .map((Widget w) => buildListTile(context, w));
    if (showDividers)
      listItems = ListTile.divideTiles(context: context, tiles: listItems);
  var lv =new ListView(
  padding: new EdgeInsets.symmetric(vertical: _dense ? 4.0 : 8.0),
  children: listItems.toList());


    //if (onRefresh != null) {
    //  body = new RefreshIndicator(
    //      key: _refreshIndicatorKey, onRefresh: onRefresh, child: body);
    //}

    return lv;
  }
}


