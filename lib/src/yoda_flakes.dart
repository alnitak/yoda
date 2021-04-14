/*
 * Copyright (c) 2021 Marco Bavagnoli [marcobavagnolidev@gmail.com]. All rights reserved.
 */

import 'dart:math';

import 'package:flutter/animation.dart';
import 'package:flutter/rendering.dart';
import 'package:yoda/src/defines.dart';

class YodaFlakes extends CustomPainter {
  final AnimObject animObject;
  final double controllerValue;

  YodaFlakes({
    required this.animObject,
    required this.controllerValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();
    Cubic opacityCurve = Curves.easeInOutCubic;
    Curve velocityCurve = Curves.easeInQuad;

    for (int y = 0; y < animObject.animParameters.vTiles; y++) {
      for (int x = 0; x < animObject.animParameters.hTiles; x++) {
        int tileID = y * animObject.animParameters.vTiles + x;

        double newX = animObject.offset[tileID].dx +
            sin(velocityCurve.transform(1 - controllerValue) *
                    animObject.animParameters.effectPower) *
                y;

        double newY = animObject.offset[tileID].dy +
            y *
                velocityCurve.transform(controllerValue) *
                Random(tileID).nextDouble() *
                animObject.animParameters.randomness;

        if (animObject.animParameters.yodaBarrier.right && newX > size.width)
          newX = size.width;
        if (animObject.animParameters.yodaBarrier.left && newX < 0) newX = 0;
        if (animObject.animParameters.yodaBarrier.bottom && newY > size.height)
          newY = size.height;
        if (animObject.animParameters.yodaBarrier.top && newY < 0) newY = 0;

        Offset offset = Offset(newX, newY);

        // opacity
        paint.color = Color.fromRGBO(
            0, 0, 0, 1 - opacityCurve.transformInternal(controllerValue));

        // blur
        if (animObject.animParameters.blurPower > 0)
          paint.maskFilter = MaskFilter.blur(
              BlurStyle.normal,
              (velocityCurve.transform(controllerValue)) *
                  animObject.animParameters.blurPower);

        canvas.drawImage(
            animObject.tileUiImages[tileID],
            offset -
                Offset(animObject.size[tileID].width / 2,
                    animObject.size[tileID].height / 2),
            paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
