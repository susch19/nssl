import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scandit_flutter_datacapture_barcode/scandit_flutter_datacapture_barcode.dart';
import 'package:scandit_flutter_datacapture_barcode/scandit_flutter_datacapture_barcode_capture.dart';
import 'package:scandit_flutter_datacapture_core/scandit_flutter_datacapture_core.dart';
import 'package:nssl/.license.dart'; //If this import is missing, go into tools folder, open env.dart and start debbing process. After that this file should be created

class ScanditBarcodeScannerScreen extends StatefulWidget {
  final DataCaptureContext _dataCaptureContext = kReleaseMode
      ? DataCaptureContext.forLicenseKey(scanditLicenseKey)
      : DataCaptureContext.forLicenseKey(scanditLicenseKeyDebug);
  @override
  State<StatefulWidget> createState() =>
      _ScanditBarcodeScannerScreenState(_dataCaptureContext);
}

class _ScanditBarcodeScannerScreenState
    extends State<ScanditBarcodeScannerScreen>
    with WidgetsBindingObserver
    implements BarcodeCaptureListener {
  final DataCaptureContext _context;

  // Use the world-facing (back) camera.
  Camera? _camera = Camera.defaultCamera;
  late BarcodeCapture _barcodeCapture;
  late DataCaptureView _captureView;

  bool _isPermissionMessageVisible = false;

  _ScanditBarcodeScannerScreenState(this._context);

  void _checkPermission() {
    Permission.camera.request().then((status) {
      if (!mounted) return;

      final isGranted = status.isGranted;
      setState(() {
        _isPermissionMessageVisible = !isGranted;
      });

      if (isGranted && _camera != null) {
        _camera!.switchToDesiredState(FrameSourceState.on);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Use the recommended camera settings for the BarcodeCapture mode.
    _camera?.applySettings(BarcodeCapture.createRecommendedCameraSettings());

    // Switch camera on to start streaming frames and enable the barcode batch mode.
    // The camera is started asynchronously and will take some time to completely turn on.
    _checkPermission();

    // The barcode capture process is configured through barcode capture settings
    // which are then applied to the barcode capture instance that manages barcode capture.
    var captureSettings = BarcodeCaptureSettings();

    // The settings instance initially has all types of barcodes (symbologies) disabled. For the purpose of this
    // sample we enable a very generous set of symbologies. In your own app ensure that you only enable the
    // symbologies that your app requires as every additional enabled symbology has an impact on processing times.
    captureSettings.enableSymbologies({
      Symbology.ean8,
      Symbology.ean13Upca,
      Symbology.upce,
    });

    // Create new barcode capture mode with the settings from above.
    _barcodeCapture = BarcodeCapture(captureSettings)
      // Register self as a listener to get informed whenever a new barcode got recognized.
      ..addListener(this);

    // To visualize the on-going barcode capturing process on screen, setup a data capture view that renders the
    // camera preview. The view must be connected to the data capture context.
    _captureView = DataCaptureView.forContext(_context);

    // Add a barcode capture overlay to the data capture view to render the location of captured barcodes on top of
    // the video preview. This is optional, but recommended for better visual feedback.
    var overlay = BarcodeCaptureOverlay(_barcodeCapture)
      ..viewfinder = RectangularViewfinder.withStyleAndLineStyle(
        RectangularViewfinderStyle.square,
        RectangularViewfinderLineStyle.light,
      )
      ;

    // Adjust the overlay's barcode highlighting to match the new viewfinder styles and improve the visibility of feedback.
    // With 6.10 we will introduce this visual treatment as a new style for the overlay.
    overlay.brush = Brush(
      Color.fromARGB(0, 0, 0, 0),
      Color.fromARGB(0, 255, 255, 255),
      3,
    );

    _captureView.addOverlay(overlay);

    // Set the barcode capture mode as the current mode of the data capture context.
    _context.setMode(_barcodeCapture);

    // Set the default camera as the frame source of the context. The camera is off by
    // default and must be turned on to start streaming frames to the data capture context for recognition.
    if (_camera != null) {
      _context.setFrameSource(_camera!);
    }
    _barcodeCapture.isEnabled = true;
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (_isPermissionMessageVisible) {
      child = Text(
        'No permission to access the camera!',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      );
    } else {
      child = _captureView;
    }
    return Center(child: child);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _checkPermission();
        break;
      default:
        if (_camera != null) {
          _camera!.switchToDesiredState(FrameSourceState.off);
        }
        break;
    }
  }

  @override
  Future<void> didScan(
    BarcodeCapture barcodeCapture,
    BarcodeCaptureSession session,
    Future<FrameData> getFrameData(),
  ) async {
    var code = session.newlyRecognizedBarcode;
    if (code == null) return;
    var data = (code.data == null || code.data?.isEmpty == true)
        ? code.rawData
        : code.data;
    _cleanup();
    Navigator.pop(context, data);
  }

  @override
  Future<void> didUpdateSession(
    BarcodeCapture barcodeCapture,
    BarcodeCaptureSession session,
    Future<FrameData> getFrameData(),
  ) async {}

  void _cleanup() {
    WidgetsBinding.instance.removeObserver(this);
    _barcodeCapture.removeListener(this);
    _barcodeCapture.isEnabled = false;
    _camera?.switchToDesiredState(FrameSourceState.off);
    _context.removeCurrentMode();
  }
}

// class BarcodeScannerScreen extends StatefulWidget {
//   // Create data capture context using your license key.
//   @override
//   State<StatefulWidget> createState() {
//     return _BarcodeScannerScreenState();
//   }
// }

// class _BarcodeScannerScreenState extends State<BarcodeScannerScreen>
//     with WidgetsBindingObserver
//     implements BarcodeCaptureListener {
//   final DataCaptureContext _context;

//   // Use the world-facing (back) camera.
//   Camera? _camera = Camera.defaultCamera;
//   late BarcodeCapture _barcodeCapture;
//   late DataCaptureView _captureView;

//   bool _isPermissionMessageVisible = false;

//   _BarcodeScannerScreenState()
//     : _context = kReleaseMode
//           ? DataCaptureContext.forLicenseKey(scanditLicenseKey)
//           : DataCaptureContext.forLicenseKey(scanditLicenseKeyDebug);

//   void _checkPermission() {
//     Permission.camera.request().isGranted.then(
//       (value) => setState(() {
//         _isPermissionMessageVisible = !value;
//         if (value) {
//           _camera?.switchToDesiredState(FrameSourceState.on);
//         }
//       }),
//     );
//   }

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);

//     // Use the recommended camera settings for the BarcodeCapture mode.
//     _camera?.applySettings(BarcodeCapture.createRecommendedCameraSettings());

//     // Switch camera on to start streaming frames and enable the barcode tracking mode.
//     // The camera is started asynchronously and will take some time to completely turn on.
//     _checkPermission();

//     // The barcode capture process is configured through barcode capture settings
//     // which are then applied to the barcode capture instance that manages barcode capture.
//     var captureSettings = BarcodeCaptureSettings();

//     // The settings instance initially has all types of barcodes (symbologies) disabled. For the purpose of this
//     // sample we enable a very generous set of symbologies. In your own app ensure that you only enable the
//     // symbologies that your app requires as every additional enabled symbology has an impact on processing times.
//     captureSettings.enableSymbologies({
//       Symbology.ean8,
//       Symbology.ean13Upca,
//       // Symbology.upce,
//       // Symbology.qr,
//     });

//     // Some linear/1d barcode symbologies allow you to encode variable-length data. By default, the Scandit
//     // Data Capture SDK only scans barcodes in a certain length range. If your application requires scanning of one
//     // of these symbologies, and the length is falling outside the default range, you may need to adjust the "active
//     // symbol counts" for this symbology. This is shown in the following few lines of code for one of the
//     // variable-length symbologies.
//     captureSettings.settingsForSymbology(Symbology.code39).activeSymbolCounts =
//         [for (var i = 7; i <= 20; i++) i].toSet();

//     // Create new barcode capture mode with the settings from above.
//     _barcodeCapture = BarcodeCapture(captureSettings)

//       // Register self as a listener to get informed whenever a new barcode got recognized.
//       ..addListener(this);

//     // To visualize the on-going barcode capturing process on screen, setup a data capture view that renders the
//     // camera preview. The view must be connected to the data capture context.
//     _captureView = DataCaptureView.forContext(_context);

//     // Add a barcode capture overlay to the data capture view to render the location of captured barcodes on top of
//     // the video preview. This is optional, but recommended for better visual feedback.
//     var overlay =
//         BarcodeCaptureOverlay(
//             _barcodeCapture,
//           )
//           ..viewfinder = RectangularViewfinder.withStyleAndLineStyle(
//             RectangularViewfinderStyle.square,
//             RectangularViewfinderLineStyle.light,
//           );

//     // Adjust the overlay's barcode highlighting to match the new viewfinder styles and improve the visibility of feedback.
//     // With 6.10 we will introduce this visual treatment as a new style for the overlay.
//     overlay.brush = Brush(
//       Color.fromARGB(0, 0, 0, 0),
//       Color.fromARGB(255, 255, 255, 255),
//       3,
//     );

//     _captureView.addOverlay(overlay);

//     // Set the default camera as the frame source of the context. The camera is off by
//     // default and must be turned on to start streaming frames to the data capture context for recognition.
//     if (_camera != null) {
//       _context.setFrameSource(_camera!);
//     }
//     _camera?.switchToDesiredState(FrameSourceState.on);
//     _barcodeCapture.isEnabled = true;
//   }

//   @override
//   Widget build(BuildContext context) {
//     Widget child;
//     if (_isPermissionMessageVisible) {
//       child = Text(
//         'No permission to access the camera!',
//         style: TextStyle(
//           fontSize: 14,
//           fontWeight: FontWeight.bold,
//           color: Colors.black,
//         ),
//       );
//     } else {
//       child = _captureView;
//     }
//     return Center(child: child);
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       _checkPermission();
//     } else if (state == AppLifecycleState.paused) {
//       _camera?.switchToDesiredState(FrameSourceState.off);
//     }
//   }

//   @override
//   Future<void> didScan(
//     BarcodeCapture barcodeCapture,
//     BarcodeCaptureSession session,
//     Future<FrameData> getFrameData(),
//   ) async {
//     _barcodeCapture.isEnabled = false;
//     var code = session.newlyRecognizedBarcode;
//     if (code == null) return;
//     var data = (code.data == null || code.data?.isEmpty == true)
//         ? code.rawData
//         : code.data;
//     Navigator.pop(context, data);
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     _barcodeCapture.removeListener(this);
//     _barcodeCapture.isEnabled = false;
//     _camera?.switchToDesiredState(FrameSourceState.off);
//     _context.removeAllModes();
//     super.dispose();
//   }

//   @override
//   Future<void> didUpdateSession(
//     BarcodeCapture barcodeCapture,
//     BarcodeCaptureSession session,
//     Future<FrameData> Function() getFrameData,
//   ) async {}
// }
