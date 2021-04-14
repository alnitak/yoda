/*
 * Copyright (c) 2021 Marco Bavagnoli [marcobavagnolidev@gmail.com]. All rights reserved.
 */

import 'dart:math';

import 'package:flutter/animation.dart';
import 'package:flutter/rendering.dart';
import 'package:yoda/src/defines.dart';

class YodaVortex extends CustomPainter {
  final AnimObject animObject;
  final double controllerValue;

  YodaVortex({
    required this.animObject,
    required this.controllerValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();
    Cubic opacityCurve = Curves.easeInOutCubic;
    Curve velocityCurve = Curves.decelerate;

    for (int i = 0; i < animObject.tileUiImages.length; i++) {
      double newDistance =
          -animObject.distance[i] * (velocityCurve.transform(controllerValue));

      // randomize the new distance
      if (animObject.animParameters.randomness > 0)
        newDistance +=
        (Random(i).nextDouble() * animObject.animParameters.randomness );

      double dy = (controllerValue) *
          animObject.distance[i] *
          animObject.animParameters.gravity;
      double newAngle = animObject.angle[i] +
          (newDistance /
              animObject.maxDistance *
              animObject.animParameters.effectPower);

      double newX = animObject.offset[i].dx + cos(newAngle) * newDistance;
      double newY = animObject.offset[i].dy + sin(newAngle) * newDistance + dy;

      if (animObject.animParameters.yodaBarrier.right && newX > size.width)
        newX = size.width;
      if (animObject.animParameters.yodaBarrier.left && newX < 0) newX = 0;
      if (animObject.animParameters.yodaBarrier.bottom && newY > size.height)
        newY = size.height;
      if (animObject.animParameters.yodaBarrier.top && newY < 0) newY = 0;

      Offset offset = Offset(newX, newY);

      // opacity
      paint.color =
          Color.fromRGBO(0, 0, 0, 1 - opacityCurve.transform(controllerValue));

      // blur
      if (animObject.animParameters.blurPower > 0)
        paint.maskFilter = MaskFilter.blur(
            BlurStyle.normal,
            (velocityCurve.transform(controllerValue)) *
                animObject.animParameters.blurPower);

      canvas.drawImage(
          animObject.tileUiImages[i],
          offset -
              Offset(
                  animObject.size[i].width / 2, animObject.size[i].height / 2),
          paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
