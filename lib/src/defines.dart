/*
 * Copyright (c) 2021 Marco Bavagnoli [marcobavagnolidev@gmail.com]. All rights reserved.
 */

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

enum YodaEffect {
  Explosion,
  Vortex,
}

/// Tiles barriers
class YodaBarrier {
  // block tiles moving over the left edge
  final bool left;

  // block tiles moving over the right edge
  final bool right;

  // block tiles moving over the top edge
  final bool top;

  // block tiles moving over the bottom edge
  final bool bottom;

  const YodaBarrier({
    this.left: false,
    this.right: false,
    this.top: false,
    this.bottom: false,
  });
}

class AnimParameters {
  // define which edges are barraged
  final YodaBarrier yodaBarrier;

  // number of horizontal tiles to divide the child widget
  final int hTiles;

  // number of vertical tiles to divide the child widget
  final int vTiles;

  // default center where force is given
  Offset fractionalCenter;

  // vertical force
  double gravity;

  // strength of the effect
  double power;

  AnimParameters({
    this.yodaBarrier: const YodaBarrier(),
    this.hTiles: 0,
    this.vTiles: 0,
    this.fractionalCenter: const Offset(0.5, 0.5),
    this.gravity: 9.81,
    this.power: 1.0,
  });
}


class AnimObject {
  // Animation parameters (see above)
  AnimParameters animParameters = AnimParameters();

  // Position where the force act inside the widget
  Offset center = Offset.zero;

  // Calculated max distance of a tile from the center
  double maxDistance = 0;

  // Calculated offsets of each tiles
  List<Offset> offset = [];

  // Calculated sizes of each tiles
  List<Size> size = [];

  // Calculated distance of each tiles
  List<double> distance = [];

  // Calculated angles of each tiles relative to center
  List<double> angle = [];

  // Calculated velocity of each tiles based on the nearness from the center
  // 0 is when the tile is at the maxDistance, 1 when it is in the center
  List<double> velocity = [];

  // Tiles images
  List<ui.Image> tileUiImages = [];
}


class CapturedWidged {
  ByteData? byteData;   // uncompressed 32bit RGBA image data
  late Size size;
}

