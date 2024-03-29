/*
 * Copyright (c) 2021 Marco Bavagnoli [marcobavagnolidev@gmail.com]. All rights reserved.
 */

import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:yoda/src/defines.dart';
import 'package:yoda/src/yoda_explode.dart';
import 'package:yoda/src/yoda_flakes.dart';
import 'package:yoda/src/yoda_vortex.dart';

typedef YodaStatusListener = void Function(
    AnimationStatus status, BuildContext context);

class YodaController {
  _YodaState? _yodaState;
  YodaStatusListener? _yodaStatusListener;

  void _addState(_YodaState yodaState) {
    this._yodaState = yodaState;
  }

  /// Determine if the CustomWidgetController is attached to an instance
  /// of the CustomWidget (this property must return true before any other
  /// functions can be used)
  bool get isAttached => _yodaState != null;

  void addStatusListener(YodaStatusListener listener) {
    _yodaStatusListener = listener;
  }

  /// exposed methods
  void start({Offset? center}) {
    assert(isAttached, "YodaController must be attached to a Yoda widget");
    _yodaState?.start(center: center);
  }

  void reset() {
    assert(isAttached, "YodaController must be attached to a Yoda widget");
    _yodaState?.reset();
  }

  Key? getKey() {
    assert(isAttached, "YodaController must be attached to a Yoda widget");
    return _yodaState?.getKey();
  }
}

class Yoda extends StatefulWidget {
  // Effect to use
  final YodaEffect yodaEffect;

  // Animation controller
  final YodaController? controller;

  // Duration of the animation
  final Duration duration;

  // widget to slice
  final Widget child;

  // Animation parameters
  final AnimParameters? animParameters;

  // Enable the animation by tapping the child widget and use
  // the tapping position as the center of the force
  final bool startWhenTapped;

  Yoda({
    required this.yodaEffect,
    this.controller,
    this.duration = const Duration(milliseconds: 1000),
    required this.child,
    this.animParameters,
    this.startWhenTapped = false,
  }) : super(key: UniqueKey()) {
    assert(
        !(yodaEffect == YodaEffect.Flakes &&
            animParameters != null &&
            animParameters!.gravity <= 0),
        "Please, provide a gravity > 0 with Flocks effect");
    assert(animParameters != null && animParameters!.blurPower >= 0,
        "blurPower must be >= 0");
  }

  @override
  _YodaState createState() => _YodaState(controller);
}

class _YodaState extends State<Yoda> with TickerProviderStateMixin {
  YodaController? yodaController;
  late AnimationController controller;
  // late void Function(AnimationStatus) statusListener;
  // late void Function() listener;
  late GlobalKey gk;
  final Completer<bool> completer = Completer<bool>();
  int retryCount = 0;
  CapturedWidged captured = CapturedWidged();
  AnimObject animObject = AnimObject();
  final int rgba32HeaderSize = 122;

  _YodaState(this.yodaController) {
    if (yodaController != null) yodaController?._addState(this);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    gk = GlobalKey();

    init();
  }

  init() {
    controller = AnimationController(vsync: this, duration: widget.duration)
      ..addStatusListener(statusListener)
      ..addListener(listener);

    if (widget.animParameters != null)
      animObject.animParameters = widget.animParameters!;
  }

  void listener() {
    setState(() {});
  }

  void statusListener(AnimationStatus status) {
    if (yodaController != null && yodaController!._yodaStatusListener != null) {
      yodaController!._yodaStatusListener!(status, context);
    }
  }

  // TODO: When changing Yoda widget parameters, 2 hot reloads are needed to make it to work!
  //hot reload?
  @override
  void reassemble() {
    super.reassemble();
    controller.reset();
    controller.removeStatusListener(statusListener);
    controller.removeListener(listener);
    controller.dispose();
    init();
  }

  @override
  Widget build(BuildContext context) {
    CustomPainter? painter;
    if (widget.yodaEffect == YodaEffect.Explosion)
      painter = YodaExplode(
        animObject: animObject,
        controllerValue: controller.value,
      );
    else if (widget.yodaEffect == YodaEffect.Vortex)
      painter = YodaVortex(
        animObject: animObject,
        controllerValue: controller.value,
      );
    else if (widget.yodaEffect == YodaEffect.Flakes)
      painter = YodaFlakes(
        animObject: animObject,
        controllerValue: controller.value,
      );

    return GestureDetector(
      onTapDown: !widget.startWhenTapped
          ? null
          : (TapDownDetails details) {
              start(center: details.localPosition);
            },
      child: RepaintBoundary(
        key: gk,
        child: Stack(
          children: [
            Opacity(
              opacity: controller.value > 0 && captured.size != null ? 0.0 : 1,
              child: widget.child,
            ),
            if (controller.value > 0 && captured.size != null)
              CustomPaint(
                size: captured.size!,
                painter: painter,
              ),
          ],
        ),
      ),
    );
  }

  void start({Offset? center}) {
    if (gk.currentContext == null) return;
    if (controller.isAnimating) {
      controller.reset();
      controller.forward(from: 0);
      return;
    }

    if (center == null) {
      animObject.center = Offset(
          (captured.size?.width ?? 0) *
              animObject.animParameters.fractionalCenter.dx,
          (captured.size?.height ?? 0) *
              animObject.animParameters.fractionalCenter.dy);
    } else {
      animObject.center = center;
    }

    startCapture().then((value) {
      if (value) {
        calcObjectParams();
        controller.forward(from: 0);
      }
    });
  }

  Future<bool> startCapture() async {
    retryCount = 0;
    captured.byteData = null;
    captured.size = null;
    var success = await captureWidget(gk);
    if (success && widget.animParameters != null) {
      await makeTiles();
    }
    return success;
  }

  void reset() {
    controller.reset();
  }

  Key? getKey() {
    return widget.key;
  }

  // TODO: find a better way to capture the widget
  Future<bool> captureWidget(GlobalKey widgetKey) async {
    ui.Image? image;

    try {
      RenderRepaintBoundary? boundary = widgetKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;

      if (retryCount > 30) {
        // how many times to try? 150ms max (15*10ms)
        completer.complete(false);
      }

      if (boundary != null) {
        image = await boundary.toImage();

        captured.byteData =
            await image.toByteData(format: ui.ImageByteFormat.rawRgba);
        captured.size = Size(image.width.toDouble(), image.height.toDouble());
      }

      if (image != null) {
        completer.complete(true);
      } else {
        // with a child like:
        //   SizedBox(
        //       width: 250,
        //       height: 200,
        //       child: Image.asset('assets/dash.png', fit: BoxFit.fill)
        //   )
        // the first 2 boundary acquired are empty
        Timer(Duration(milliseconds: 20), () {
          captureWidget(widgetKey);
        });
        retryCount++;
      }
    } catch (exception) {
      retryCount++;
      //Delay is required. See Issue https://github.com/flutter/flutter/issues/22308
      Timer(Duration(milliseconds: 20), () {
        captureWidget(widgetKey);
      });
    }
    return completer.future;
  }

  // calculate object parameters based on the center of each tiles
  // and the center of the force
  void calcObjectParams() {
    double distance = 0;
    animObject.maxDistance = 0;
    animObject.angle.clear();
    animObject.distance.clear();
    animObject.velocity.clear();
    for (int i = 0; i < animObject.tileUiImages.length; i++) {
      animObject.angle.add(atan2(animObject.offset[i].dy - animObject.center.dy,
          animObject.offset[i].dx - animObject.center.dx));

      distance = sqrt(pow(animObject.offset[i].dx - animObject.center.dx, 2) +
          pow(animObject.offset[i].dy - animObject.center.dy, 2));
      animObject.distance.add(distance);

      if (distance > animObject.maxDistance) animObject.maxDistance = distance;
    }

    // based on maxDistance, calculate the velocity.
    // 0..1   0 at max distance, 1 near the center
    for (int i = 0; i < animObject.tileUiImages.length; i++) {
      animObject.velocity.add(animObject.animParameters.effectPower /
          (animObject.distance[i] / animObject.maxDistance));
    }
  }

  Future<void> makeTiles() async {
    animObject.offset.clear();
    animObject.size.clear();
    animObject.distance.clear();
    animObject.angle.clear();
    animObject.velocity.clear();
    animObject.tileUiImages.clear();
    int xStep = (captured.size?.width ?? 0) ~/ animObject.animParameters.hTiles;
    int yStep =
        (captured.size?.height ?? 0) ~/ animObject.animParameters.vTiles;

    int y1 = 0;
    int y2 = yStep;
    while (y1 <= (captured.size?.height ?? 0) - yStep) {
      // TODO
      // if (y1+yStep>captured.size.height)
      //   y2 = captured.size.height.toInt();
      // else
      y2 = y1 + yStep;

      int x1 = 0;
      int x2 = xStep;
      while (x1 <= (captured.size?.width ?? 0) - xStep) {
        // TODO
        // if (x1+xStep>captured.size.height)
        //   x2 = captured.size.height.toInt();
        // else
        x2 = x1 + xStep;
        await makeTile(x1, y1, x2, y2);
        x1 += xStep;
      }

      y1 += yStep;
    }
  }

  Future<void> makeTile(int x1, int y1, int x2, int y2) async {
    int bytes = 4;
    Uint8List header = bmpHeader(x2 - x1, y2 - y1);
    Uint8List tile =
        Uint8List(rgba32HeaderSize + (x2 - x1) * bytes * (y2 - y1) * bytes);
    ByteData data =
        ByteData(rgba32HeaderSize + (x2 - x1) * bytes * (y2 - y1) * bytes);
    int i = 0;
    for (i = 0; i < rgba32HeaderSize; i++) {
      tile[i] = header[i];
      data.setInt8(i, header[i]);
    }
    int rowBytes = (captured.size?.width ?? 0).toInt() * bytes;
    for (int y = y1; y < y2; y++) {
      for (int x = x1 * bytes; x < x2 * bytes; x++) {
        tile[i] = captured.byteData!.getInt8(y * rowBytes + x);
        data.setInt8(i, captured.byteData!.getInt8(y * rowBytes + x));
        i++;
      }
    }

    // copy from decodeImageFromList of package:flutter/painting.dart
    final ui.Codec codec =
        await ui.instantiateImageCodec(Uint8List.fromList(tile));
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    animObject.tileUiImages.add(frameInfo.image);

    Size size = Size(x2.toDouble() - x1, y2.toDouble() - y1);
    Offset offset =
        Offset(x1.toDouble() + size.width / 2, y1.toDouble() + size.height / 2);
    animObject.size.add(size);
    animObject.offset.add(offset);

    // if not tappable, calculate now the distance from center. Else calculate it at tapping time
    if (!widget.startWhenTapped) {
      animObject.angle.add(atan2(
          offset.dy - animObject.center.dy, offset.dx - animObject.center.dx));

      animObject.distance.add(sqrt(pow(offset.dx - animObject.center.dx, 2) +
          pow(offset.dy - animObject.center.dy, 2)));
    }
  }

  Uint8List bmpHeader(int width, int height) {
    int contentSize = width * height;
    Uint8List ret = Uint8List(rgba32HeaderSize);

    final ByteData bd = ret.buffer.asByteData();
    bd.setUint8(0x0, 0x42);
    bd.setUint8(0x1, 0x4d);
    bd.setInt32(0x2, contentSize + rgba32HeaderSize, Endian.little);
    bd.setInt32(0xa, rgba32HeaderSize, Endian.little);
    bd.setUint32(0xe, 108, Endian.little);
    bd.setUint32(0x12, width, Endian.little);
    bd.setUint32(0x16, -height, Endian.little);
    bd.setUint16(0x1a, 1, Endian.little);
    bd.setUint32(0x1c, 32, Endian.little); // pixel size
    bd.setUint32(0x1e, 3, Endian.little); //BI_BITFIELDS
    bd.setUint32(0x22, contentSize, Endian.little);
    bd.setUint32(0x36, 0x000000ff, Endian.little);
    bd.setUint32(0x3a, 0x0000ff00, Endian.little);
    bd.setUint32(0x3e, 0x00ff0000, Endian.little);
    bd.setUint32(0x42, 0xff000000, Endian.little);

    return bd.buffer.asUint8List();
  }
}
