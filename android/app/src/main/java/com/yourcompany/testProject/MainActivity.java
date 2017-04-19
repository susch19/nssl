package com.yourcompany.testProject;
import android.Manifest;
import android.annotation.TargetApi;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.widget.FrameLayout;

import com.scandit.barcodepicker.ScanditLicense;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.view.FlutterView;

public class MainActivity extends FlutterActivity {
    public static final String CHANNEL = "com.yourcompany.testProject/Scandit";
    public static final String sScanditSdkAppKey = "***REMOVED***";

    private final int CAMERA_PERMISSION_REQUEST = 0;
    FrameLayout layout;

    //The main object for recognizing and displaying barcodes.
    private boolean mDeniedCameraAccess = false;
    private String ean;
    public static FlutterView flutterView;
    public static Context cont;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        ScanditLicense.setAppKey(sScanditSdkAppKey);
        // Initialize and start the bar code recognition.

        flutterView = getFlutterView();

        cont = this;

        new MethodChannel(flutterView, CHANNEL).setMethodCallHandler(
                new MethodCallHandler() {
                    @Override
                    public void onMethodCall(MethodCall call, Result result) {
                        if (call.method.equals("getEAN")) {
                            startActivity(new Intent(cont, ScanActivity.class));

                            //String ean = getEAN();

                            if (ean != "") {
                                result.success(ean);
                            } else {
                                result.error("ERROR", "Something went wrong.", null);
                            }
                        } else {
                            result.notImplemented();
                        }
                    }
                });
    }

    @TargetApi(Build.VERSION_CODES.M)
    private void grantCameraPermissionsThenStartScanning() {
        if (this.checkSelfPermission(Manifest.permission.CAMERA)
                != PackageManager.PERMISSION_GRANTED) {
            if (mDeniedCameraAccess == false) {
                // It's pretty clear for why the camera is required. We don't need to give a
                // detailed reason.
                this.requestPermissions(new String[]{ Manifest.permission.CAMERA },
                        CAMERA_PERMISSION_REQUEST);
            }

        }
    }
    @Override
    public void onRequestPermissionsResult(int requestCode,
                                           String permissions[], int[] grantResults) {
        if (requestCode == CAMERA_PERMISSION_REQUEST) {
            if (grantResults.length > 0
                    && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                mDeniedCameraAccess = false;
            } else {
                mDeniedCameraAccess = true;
            }
            return;
        }
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
    }

}

