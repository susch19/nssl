import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:nssl/localization/nssl_strings.dart';

class SimpleDialogAcceptDeny {
static Widget createHookSingleState<T>({
    String title = "",
    required Widget Function(BuildContext context, ValueNotifier<T> state)
    builder,
    required T initialValue,
    void Function(bool result, T value)? onSubmitted,
    bool showCancel = true,
    String acceptName = "Akzeptieren",
    String denyName = "Abbrechen",
    required BuildContext context,
  }) {
    return HookBuilder(
      builder: (context) {
        final val = useState<T>(initialValue);
        return AlertDialog(
          title: title == "" ? null : Text(title),
          content: builder(context, val),
          actions: <Widget>[
            showCancel
                ? TextButton(
                    child: Text(denyName),
                    onPressed: () {
                      Navigator.pop(context, "");
                      if (onSubmitted != null) onSubmitted(false, val.value);
                    },
                  )
                : Container(),
            TextButton(
              child: Text(acceptName),
              onPressed: () {
                Navigator.pop(context, "");
                if (onSubmitted != null) onSubmitted(true, val.value);
              },
            ),
          ],
        );
      },
    );
  }
  
  static AlertDialog create(
      {String title = "",
      String text = "",
      ValueChanged<String>? onSubmitted,
      required BuildContext context}) {
    return AlertDialog(
            title: title == "" ? null : Text(title),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[Text(text)],
              ),
            ),
            actions: <Widget>[
          TextButton(
              child: Text(NSSLStrings.of(context).cancelButton()),
              onPressed: () => Navigator.pop(context, "")),
          TextButton(
              child: Text(NSSLStrings.of(context).acceptButton()),
              onPressed: () {
                Navigator.pop(context, "");
                onSubmitted!("");
              })
        ]);
  }
}
