import 'package:flutter/material.dart';

final rowLength = 10;
final colLength = 15;

enum Direction { left, right, down }

enum Difficulty {
  easy(1000),
  medium(700),
  hard(400);

  const Difficulty(this.initialFrameRate);
  final int initialFrameRate;

  Color getColor() {
    switch (this) {
      case Difficulty.easy:
        return Colors.green;
      case Difficulty.medium:
        return Colors.amber;
      case Difficulty.hard:
        return Colors.red;
    }
  }
}

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

enum SfxType {
  blockPlace("block_place"),
  lineClear("line_clear"),
  gameOver("game_over"),
  combo("combo"),
  buttonClick("button_click"),
  invalidMove("invalid_move"),
  highScore("high_score");

  const SfxType(this.value);
  final String value;
}
