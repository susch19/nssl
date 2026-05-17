/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2020- Scandit AG. All rights reserved.
 */

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerScreen extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final controller = useMobileScannerController(
      autoStart: false,
      detectionSpeed: DetectionSpeed.unrestricted,
      formats: [
        BarcodeFormat.ean13,
        BarcodeFormat.ean8,
        BarcodeFormat.upcA,
        BarcodeFormat.upcE,
      ],
      cameraResolution: Size(1280, 720),
    );
    useMemoized(() {
      Future.delayed(
        Duration(milliseconds: 400),
        () => unawaited(controller.start()),
      );
    });

    return MobileScanner(
      controller: controller,
      onDetect: (barcodes) {
        if (barcodes.barcodes.length == 0)
          return;
        else if (barcodes.barcodes.length > 1) {
          return;
        }
        final barcode = barcodes.barcodes.first;
        Navigator.pop(context, barcode.rawValue);
      },
    );
  }

}

MobileScannerController useMobileScannerController({
  bool autoStart = true,
  Size? cameraResolution,
  CameraLensType lensType = CameraLensType.any,
  DetectionSpeed detectionSpeed = DetectionSpeed.normal,
  CameraFacing facing = CameraFacing.back,
  List<BarcodeFormat> formats = const <BarcodeFormat>[],
  bool returnImage = false,
  bool torchEnabled = false,
  bool invertImage = false,
  bool autoZoom = false,
  double? initialZoom,
}) {
  return use(
    _MobileScannerControllerHook(
      autoStart: autoStart,
      cameraResolution: cameraResolution,
      lensType: lensType,
      detectionSpeed: detectionSpeed,
      facing: facing,
      formats: formats,
      returnImage: returnImage,
      torchEnabled: torchEnabled,
      invertImage: invertImage,
      autoZoom: autoZoom,
      initialZoom: initialZoom,
    ),
  );
}

class _MobileScannerControllerHook extends Hook<MobileScannerController> {
  const _MobileScannerControllerHook({
    this.autoStart = true,
    this.cameraResolution,
    this.lensType = CameraLensType.any,
    this.detectionSpeed = DetectionSpeed.normal,
    this.facing = CameraFacing.back,
    this.formats = const <BarcodeFormat>[],
    this.returnImage = false,
    this.torchEnabled = false,
    this.invertImage = false,
    this.autoZoom = false,
    this.initialZoom,
  });

  final bool autoStart;
  final Size? cameraResolution;
  final CameraLensType lensType;
  final DetectionSpeed detectionSpeed;
  final CameraFacing facing;
  final List<BarcodeFormat> formats;
  final bool returnImage;
  final bool torchEnabled;
  final bool invertImage;
  final bool autoZoom;
  final double? initialZoom;

  @override
  HookState<MobileScannerController, Hook<MobileScannerController>>
  createState() => _MobileScannerControllerHookState();
}

class _MobileScannerControllerHookState
    extends HookState<MobileScannerController, _MobileScannerControllerHook> {
  late MobileScannerController controller = MobileScannerController(
    autoStart: hook.autoStart,
    cameraResolution: hook.cameraResolution,
    lensType: hook.lensType,
    detectionSpeed: hook.detectionSpeed,
    facing: hook.facing,
    formats: hook.formats,
    returnImage: hook.returnImage,
    torchEnabled: hook.torchEnabled,
    invertImage: hook.invertImage,
    autoZoom: hook.autoZoom,
    initialZoom: hook.initialZoom,
  );

  @override
  void didUpdateHook(_MobileScannerControllerHook oldHook) {
    super.didUpdateHook(oldHook);
    controller = MobileScannerController(
      autoStart: hook.autoStart,
      cameraResolution: hook.cameraResolution,
      lensType: hook.lensType,
      detectionSpeed: hook.detectionSpeed,
      facing: hook.facing,
      formats: hook.formats,
      returnImage: hook.returnImage,
      torchEnabled: hook.torchEnabled,
      invertImage: hook.invertImage,
      autoZoom: hook.autoZoom,
      initialZoom: hook.initialZoom,
    );
  }

  @override
  MobileScannerController build(BuildContext context) => controller;

  @override
  void dispose() => controller.dispose();

  @override
  String get debugLabel => 'useMobileScannerController';
}
