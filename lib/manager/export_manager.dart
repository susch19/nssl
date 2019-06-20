import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:nssl/manager/permission_request_manager.dart';
import 'package:nssl/models/model_export.dart';

class ExportManager
{


  static Future<Null> exportAsPDF(ShoppingList list, [BuildContext context]) async 
  {
     if(!await PermissionRequestManager.requestPermission(PermissionGroup.storage)){
       return;
     }

    final pdf = new PDFDocument();
    final page = new PDFPage(pdf, pageFormat: PDFPageFormat.A4);
    final g = page.getGraphics();
    final font = new PDFFont(pdf);

    g.setColor(new PDFColor(0.0,0.0,0.0));
    g.drawString(font, 18.0, list.name, 10.0, PDFPageFormat.A4.height-20);
    double posY = PDFPageFormat.A4.height-50;
    for(var item in list.shoppingItems){
      g.drawString(font, 13.0, "${item.amount}x  ${item.name}\r\n", 10.0, posY);
      posY -= 20.0;
    }
    
    var dir = await getExternalStorageDirectory();
    var newDir = new Directory(dir.path +'/NSSL Exports');
    if(!newDir.existsSync())
      newDir.create();
      var fileName = '/NSSL Exports/${list.name}_${DateTime.now()}.pdf';
    var file = new File(dir.path + fileName);
    file.writeAsBytesSync(pdf.save());

    if(context != null)
      Scaffold.of(context).showSnackBar(SnackBar(content: Text("Successfully exported as $fileName"), duration: Duration(seconds: 15,)));
  } 
}