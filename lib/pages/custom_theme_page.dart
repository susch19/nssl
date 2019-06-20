import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nssl/localization/nssl_strings.dart';
import 'package:nssl/options/themes.dart';

import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_colorpicker/material_picker.dart';
import 'package:flutter_colorpicker/block_picker.dart';
import 'package:flutter_colorpicker/utils.dart';

class CustomThemePage extends StatefulWidget {
  CustomThemePage();

  @override
  CustomThemePageState createState() => new CustomThemePageState();
}

class CustomThemePageState extends State<CustomThemePage> {
Color pickerColor = Color(0xff443a49);
Color currentColor = Color(0xff443a49);
void changeColor(Color color) {
  setState(() => pickerColor = color);
}
  CustomThemePageState();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  bool _saveNeeded = false;
  TextEditingController tec = new TextEditingController();

  MaterialColor primary = Colors.blue;
  MaterialAccentColor accent = Colors.blueAccent;
  Brightness primaryBrightness = Brightness.light;
  Brightness accentBrightness = Brightness.dark;

  ThemeData td = Themes.themes.first;

  double primaryColorSlider = 0.0;
  double accentColorSlider = 0.0;
  bool primaryColorCheckbox = false;
  bool accentColorCheckbox = true;

  Future<bool> _onWillPop() async {
    if (!_saveNeeded) return true;

    final ThemeData theme = Theme.of(context);
    final TextStyle dialogTextStyle = theme.textTheme.subhead.copyWith(color: theme.textTheme.caption.color);

    return await showDialog<bool>(
            context: context,
            builder: (BuildContext context) => new AlertDialog(
                    content: new Text(NSSLStrings.of(context).discardNewTheme(), style: dialogTextStyle),
                    actions: <Widget>[
                      new FlatButton(
                          child: new Text(NSSLStrings.of(context).cancelButton()),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          }),
                      new FlatButton(
                          child: new Text(NSSLStrings.of(context).discardButton()),
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          })
                    ])) ??
        false;
  }

  void _handleSubmitted() {
    Themes.themes.clear();
    Themes.saveTheme(td, primary, accent);
    setState(() {
      Themes.themes.add(td);
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    var textColorTheme = new TextStyle(color: td.textTheme.title.color);
    return new Scaffold(
      floatingActionButton: new FloatingActionButton(
          child: new IconButton(
              icon: new Icon(
                Icons.save,
                color: td.accentIconTheme.color,
              ),
              onPressed: null),
          backgroundColor: td.accentColor,
          onPressed: _handleSubmitted),
      backgroundColor: td.scaffoldBackgroundColor,
      key: _scaffoldKey,
      appBar: new AppBar(
          title: new Text(NSSLStrings.of(context).changeTheme(), style: textColorTheme),
          backgroundColor: td.primaryColor,
          iconTheme: td.iconTheme,
          textTheme: td.textTheme,
          actions: <Widget>[
            new FlatButton(
                child: new Text(NSSLStrings.of(context).saveButton(), style: textColorTheme),
                onPressed: () => _handleSubmitted())
          ]),
      body: new Form(
          key: _formKey,
          onWillPop: _onWillPop,
          child: new ListView(padding: const EdgeInsets.all(16.0), children: <Widget>[
            new Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              new Text(
                NSSLStrings.of(context).changePrimaryColor(),
                style: textColorTheme,
              ),
              new Slider(
                value: primaryColorSlider,
                max: (Colors.primaries).length.ceilToDouble() - 1.0,
                divisions: Colors.primaries.length - 1,
                onChanged: onChangedPrimarySlider,
                activeColor: td.accentColor,
              ),
            ]),
            new Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              new Text(NSSLStrings.of(context).changeAccentColor(), style: textColorTheme),
              new Slider(
                  value: accentColorSlider,
                  max: Colors.accents.length.ceilToDouble() - 1.0,
                  divisions: Colors.accents.length - 1,
                  onChanged: onChangedSecondarySlider,
                  activeColor: td.accentColor),
            ]),
            new Row(children: [
              new Text(NSSLStrings.of(context).changeDarkTheme(), style: textColorTheme),
              new Checkbox(
                  value: primaryColorCheckbox, onChanged: primaryBrightnessChange, activeColor: td.accentColor),
            ]),
            new Row(children: [
              new Text(NSSLStrings.of(context).changeAccentTextColor(), style: textColorTheme),
              new Checkbox(
                  value: accentColorCheckbox, onChanged: secondaryBrightnessChange, activeColor: td.accentColor),
            ]),
            new Row(children: [
              new Text('Demo', style: textColorTheme),
              new Checkbox(value: true, onChanged: (v) {}, activeColor: td.accentColor),
            ]),
            // ColorPicker(
            //   pickerColor: pickerColor,
            //   onColorChanged: changeColor,
            //   enableLabel: true,
            //   pickerAreaHeightPercent: 0.8,
            // ),
          ])),
    );
  }

  void onChangedPrimarySlider(double value) {
    int index = value.floor();
    primaryColorSlider = value;
    primary = Colors.primaries[index];
    setColors();
  }

  void onChangedSecondarySlider(double value) {
    int index = value.floor();
    accentColorSlider = value;
    accent = Colors.accents[index];
    setColors();
  }

  void setColors() => setState(() {
        _saveNeeded = true;
        td = new ThemeData(
            primarySwatch: primary,
            accentColor: accent,
            brightness: primaryBrightness,
            accentColorBrightness: accentBrightness);
      });

  void primaryBrightnessChange(bool value) {
    primaryColorCheckbox = value;
    primaryBrightness = value ? Brightness.dark : Brightness.light;
    setColors();
  }

  void secondaryBrightnessChange(bool value) {
    accentColorCheckbox = value;
    accentBrightness = value ? Brightness.dark : Brightness.light;
    setColors();
  }

  buildBody() {
    return new Scaffold(
        appBar: new AppBar(
          title: const Text("Theme"),
        ),
        floatingActionButton: new FloatingActionButton(
          onPressed: () => {},
          child: new IconButton(
            icon: new Icon(Icons.search),
            onPressed: () {},
          ),
        ),
        body: new ListView(
          children: <Widget>[
            new RaisedButton(
              onPressed: () {},
              child: const Text("Theme"),
            ),
            new Divider(),
            new FlatButton(
              onPressed: () {},
              child: const Text("Theme"),
            ),
            new Divider(),
            new TextField(
              controller: tec,
            ),
            
          ],
        ),
        persistentFooterButtons: [new FlatButton(child: const Text("Theme"), onPressed: () {})]);
  }
}
