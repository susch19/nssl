import 'dart:async';
import 'package:permission_handler/permission_handler.dart';

class PermissionRequestManager {
  static Future<bool> requestPermission(PermissionGroup permission) async {
    var permissionStat = await PermissionHandler.checkPermissionStatus(permission);
    if (permissionStat != PermissionStatus.granted) {
      if (permissionStat == PermissionStatus.unknown) {
        var permissionStats = await PermissionHandler.requestPermissions(<PermissionGroup>[permission]);
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
