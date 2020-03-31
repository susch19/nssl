import 'dart:async';
import 'package:permission_handler/permission_handler.dart';

class PermissionRequestManager {
  static Future<bool> requestPermission(PermissionGroup permission) async {
    var ph = new PermissionHandler();
    var permissionStat = await ph.checkPermissionStatus(permission);
    if (permissionStat != PermissionStatus.granted) {
      if (permissionStat == PermissionStatus.unknown) {
        var permissionStats = await ph.requestPermissions(<PermissionGroup>[permission]);
        if (permissionStats[permission] == PermissionStatus.granted)
          return true;
        else
          return false;
      } else {
        return false;
      }
    } else
      return true;
  }
}
