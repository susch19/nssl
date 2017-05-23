package io.flutter.plugins;

import android.app.Activity;
import android.os.Environment;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.util.PathUtils;


/**
 * Generated file. Do not edit.
 */

public class PluginRegistry implements MethodChannel.MethodCallHandler {
    private final Activity activity;


    public void registerAll(FlutterActivity activity) {
    }

    private PluginRegistry(Activity activity) {
        this.activity = activity;
    }

    @Override
    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        switch (call.method) {
            case "getTemporaryDirectory":
                result.success(getPathProviderTemporaryDirectory());
                break;
            case "getApplicationDocumentsDirectory":
                result.success(getPathProviderApplicationDocumentsDirectory());
                break;
            case "getStorageDirectory":
                result.success(getPathProviderStorageDirectory());
                break;
            default:
                result.notImplemented();
        }
    }

    private String getPathProviderTemporaryDirectory() {
        return activity.getCacheDir().getPath();
    }

    private String getPathProviderApplicationDocumentsDirectory() {
        return PathUtils.getDataDirectory(activity);
    }

    private String getPathProviderStorageDirectory() {
        return Environment.getExternalStorageDirectory().getAbsolutePath();
    }
}
