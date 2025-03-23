import 'dart:ui';

import 'package:flutter/material.dart';

final rowLength = 10;
final colLength = 15;

enum Direction { left, right, down }

enum Tetromino {
  L(Color(0xFFFFA500)),
  J(Color.fromARGB(255, 0, 102, 255)),
  I(Color.fromARGB(255, 242, 0, 255)),
  O(Color(0xFFFFFF00)),
  S(Color(0xFF008000)),
  Z(Color(0xFFFF0000)),
  T(Color.fromARGB(255, 144, 0, 255));

  const Tetromino(this.color);
  final Color color;
}
