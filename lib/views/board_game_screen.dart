import 'package:aa_teris/controllers/game_controller.dart';
import 'package:aa_teris/widgets/aa_button.dart';
import 'package:aa_teris/widgets/board_game_header.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:aa_teris/widgets/background_image.dart';
import 'package:aa_teris/models/pixel.dart';
import 'package:aa_teris/values/values.dart';

class GameBoardView extends GetView<BoardGameController> {
  const GameBoardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: BoardGameHeader(
        title: Obx(
          () => Text(
            "Score: ${controller.currentScore.value}",
            style: BoardGameHeader.dfTitleStyle,
          ),
        ),
        actions: [
          _buildAction(),
        ],
      ),
      backgroundColor: Colors.black,
      body: Stack(children: [
        BackGroundImage(),
        _buildBody(),
        _buildOverlayPauseGame(),
      ]),
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            flex: 9,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Spacer(),
                _buildBoardGame(),
                Spacer(),
                _buildControlGame(),
                Spacer()
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlGame() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildButtonControl(
              onTap: controller.moveLeft,
              icon: Icons.arrow_back_ios_new,
            ),
            _buildButtonControl(
                onTap: controller.rotatePeice, icon: Icons.rotate_right),
            _buildButtonControl(
              onTap: controller.moveRight,
              icon: Icons.arrow_forward_ios,
            ),
          ],
        ),
      ),
    );
  }

  InkWell _buildButtonControl({Function()? onTap, IconData? icon}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
            shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.2)),
        child: Center(
          child: Icon(icon ?? Icons.arrow_back_ios_new, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildBoardGame() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.brown, width: 1),
      ),
      child: GestureDetector(
        onTap: () {
          controller.downSpeed();
        },
        child: FractionallySizedBox(
          widthFactor: 0.8,
          child: GridView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rowLength * colLength,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: rowLength,
            ),
            itemBuilder: (context, index) {
              return Obx(() {
                final currentPiece = controller.currentPiece.value;
                try {
                  final int row = (index / rowLength).floor();
                  final int col = (index % rowLength);
                  if (currentPiece.position.contains(index)) {
                    return Pixel(color: Colors.amber[100], child: index);
                  } else if (controller.gameBoard[row][col] != null) {
                    // final Tetromino? tetrominoType = gameBoard[row][col];

                    return Pixel(
                      color: Colors.amber[100],
                      child: index,
                    );
                  } else {
                    return Pixel(color: Colors.grey.shade900, child: index);
                  }
                } catch (e) {
                  if (kDebugMode) {
                    print('============= LOG check bug level $e');
                  }
                  return Pixel(color: Colors.grey.shade900, child: index);
                }
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildOverlayPauseGame() {
    return Obx(() {
      final isPaused = controller.isPaused.value;
      final gameOver = controller.gameOver.value;
      final currentScore = controller.currentScore.value;
      if (isPaused || gameOver) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                color: Colors.black.withValues(alpha: 0.7),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Spacer(),
                    _buildTextOverlay(
                        label: gameOver ? "Game Over!" : "Paused!"),
                    SizedBox(height: 50),
                    if (isPaused)
                      AAButton(
                        label: "Continue",
                        ontap: () => controller.resumeGame(),
                      ),
                    if (gameOver) ...[
                      Text("Score",
                          style: TextStyle(color: Colors.white, fontSize: 18)),
                      Text(currentScore.toString(),
                          style: TextStyle(color: Colors.white, fontSize: 24)),
                    ],
                    AAButton(
                      label: "Restart",
                      ontap: () => controller.restartGame(),
                    ),
                    AAButton(
                      label: "Home",
                      ontap: () => controller.backToHome(),
                    ),
                    Spacer(),
                  ],
                ),
              ),
            ),
          ],
        );
      }
      return SizedBox.shrink();
    });
  }

  Center _buildTextOverlay({required String label}) {
    return Center(
      child: Text(
        label,
        style: TextStyle(
          fontSize: 30,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildAction() {
    return Obx(() {
      final countDown = controller.countdown.value;
      final isPaused = controller.isPaused.value;
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: (countDown == 0 && !isPaused)
            ? InkWell(
                onTap: () => controller.pauseGame(),
                child: Icon(
                  Icons.pause,
                  color: Colors.amber[100],
                ),
              )
            : !isPaused
                ? Text(
                    "$countDown",
                    style: BoardGameHeader.dfActionTextStyle,
                  )
                : SizedBox.shrink(),
      );
    });
  }
}
