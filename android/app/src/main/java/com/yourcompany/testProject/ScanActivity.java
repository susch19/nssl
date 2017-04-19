package com.yourcompany.testProject;

import android.app.Activity;
import android.content.pm.ActivityInfo;
import android.os.Bundle;
import android.view.Window;
import android.view.WindowManager;

import com.scandit.barcodepicker.BarcodePicker;
import com.scandit.barcodepicker.OnScanListener;
import com.scandit.barcodepicker.ScanSession;
import com.scandit.barcodepicker.ScanSettings;
import com.scandit.recognition.Barcode;
import com.scandit.recognition.SymbologySettings;

import io.flutter.plugin.common.MethodChannel;

/**
 * Created by susch on 16.04.2017.
 */

public class ScanActivity extends Activity implements OnScanListener {
    private BarcodePicker mBarcodePicker;
    public static boolean mPaused =true;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        initializeBarcodeScanning();
        StartScan();
    }


    @Override
    protected void onPause() {
        super.onPause();

        mBarcodePicker.stopScanning();
        mPaused = true;
    }

    public void initializeBarcodeScanning() {
        // Switch to full screen.
            getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
                    WindowManager.LayoutParams.FLAG_FULLSCREEN);
            requestWindowFeature(Window.FEATURE_NO_TITLE);


        ScanSettings settings = ScanSettings.create();
        int[] symbologiesToEnable = new int[] {
                Barcode.SYMBOLOGY_EAN13,
                Barcode.SYMBOLOGY_EAN8,
                Barcode.SYMBOLOGY_UPCA,
                Barcode.SYMBOLOGY_DATA_MATRIX,
                Barcode.SYMBOLOGY_QR,
                Barcode.SYMBOLOGY_CODE39,
                Barcode.SYMBOLOGY_CODE128,
                Barcode.SYMBOLOGY_INTERLEAVED_2_OF_5,
                Barcode.SYMBOLOGY_UPCE
        };
        for (int sym : symbologiesToEnable) {
            settings.setSymbologyEnabled(sym, true);
        }

        // Some 1d barcode symbologies allow you to encode variable-length data. By default, the
        // Scandit BarcodeScanner SDK only scans barcodes in a certain length range. If your
        // application requires scanning of one of these symbologies, and the length is falling
        // outside the default range, you may need to adjust the "active symbol counts" for this
        // symbology. This is shown in the following few lines of code.

        SymbologySettings symSettings = settings.getSymbologySettings(Barcode.SYMBOLOGY_CODE39);
        short[] activeSymbolCounts = new short[] {
                7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20
        };
        symSettings.setActiveSymbolCounts(activeSymbolCounts);
        // For details on defaults and how to calculate the symbol counts for each symbology, take
        // a look at http://docs.scandit.com/stable/c_api/symbologies.html.



        // Prefer the back-facing camera, is there is any.
        settings.setCameraFacingPreference(ScanSettings.CAMERA_FACING_BACK);


        // Some Android 2.3+ devices do not support rotated camera feeds. On these devices, the
        // barcode picker emulates portrait mode by rotating the scan UI.
        boolean emulatePortraitMode = !BarcodePicker.canRunPortraitPicker();
        if (emulatePortraitMode) {
            setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
        }

        BarcodePicker picker = new BarcodePicker(this, settings);
        mBarcodePicker = picker;
        mBarcodePicker.setOnScanListener(this);
    }

    public void StartScan(){
        setContentView(mBarcodePicker);
        mBarcodePicker.startScanning();
    }


    @Override
    public void onBackPressed() {
        mBarcodePicker.stopScanning();
        this.finish();
    }

    @Override
    public void didScan(ScanSession session) {
        String message = "";
        for (Barcode code : session.getNewlyRecognizedCodes()) {
            String data = code.getData();
            // Truncate code to certain length.
            String cleanData = data;
            if (data.length() > 30) {
                cleanData = data.substring(0, 25) + "[...]";
            }
            message = cleanData;
        }

        new MethodChannel(MainActivity.flutterView, MainActivity.CHANNEL).invokeMethod("setEAN", message);
        this.finish();
    }
}
