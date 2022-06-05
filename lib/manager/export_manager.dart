import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart' as fm;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:nssl/models/model_export.dart';

class ExportManager {
  static Future<Null> exportAsPDF(ShoppingList list, List<ShoppingItem> shoppingItems,
      [fm.BuildContext? context]) async {
    // if (!await PermissionRequestManager.requestPermission(PermissionGroup.storage)) {
    //   return;
    // }

    var paragraphs = shoppingItems.map((f) => Paragraph(text: "${f.amount}x ${f.name}"));
    final pdf = Document();
    pdf.addPage(MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (Context context) {
          return Container(
              alignment: Alignment.center,
              child: Text(list.name, style: Theme.of(context).header0.copyWith(color: PdfColors.black)));
        },
        build: (Context c) => paragraphs.toList()));

    var dir = await (getExternalStorageDirectory() as FutureOr<Directory>);
    var newDir = Directory(dir.path + '/NSSL Exports');
    if (!newDir.existsSync()) newDir.create();
    var fileName = '/NSSL Exports/${list.name}_${DateTime.now()}.pdf';
    var file = File(dir.path + fileName);
    file.writeAsBytesSync(await pdf.save());
    if (context != null)
      fm.ScaffoldMessenger.of(context).showSnackBar(fm.SnackBar(
          content: fm.Text("Successfully exported to ${dir.path + fileName}"),
          duration: Duration(
            seconds: 15,
          )));
  }
}
