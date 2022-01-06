import 'dart:io';

Future<void> main() async {
  var content =
      'final String scanditLicenseKey = "${Platform.environment['Scandit']}";';
  content +=
      '\r\nfinal String scanditLicenseKeyDebug = "${Platform.environment['ScanditDebug']}";';

  final filename = 'lib/.license.dart';
  File(filename).writeAsString(content);
}
