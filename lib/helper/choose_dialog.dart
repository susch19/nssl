import 'package:flutter/material.dart';
import 'package:nssl/localization/nssl_strings.dart';

class ChooseDialog {
  static AlertDialog create(
      {String title = "",
      String titleOption1 = "",
      Function? onOption1,
      String titleOption2 = "",
      Function? onOption2,
      required BuildContext context}) {
    return AlertDialog(
      title: Text(NSSLStrings.of(context).chooseListToAddTitle()),
      content: Container(
        width: 80,
        child: ListView(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          children: [
            ListTile(
              title: Text(titleOption1),
              onTap: () {
                Navigator.pop(context, "");
                onOption1?.call();
              },
            ),
            ListTile(
              title: Text(titleOption2),
              onTap: () {
                Navigator.pop(context, "");
                onOption2?.call();
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(child: Text(NSSLStrings.of(context).cancelButton()), onPressed: () => Navigator.pop(context, "")),
      ],
    );
  }
}
