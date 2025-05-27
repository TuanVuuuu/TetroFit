import 'package:aa_teris/controllers/game_controller.dart';
import 'package:aa_teris/models/piece.dart';
import 'package:aa_teris/widgets/aa_button.dart';
import 'package:aa_teris/widgets/board_game_header.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:aa_teris/widgets/background_image.dart';
import 'package:aa_teris/models/pixel.dart';
import 'package:aa_teris/values/values.dart';

/// A safer version of Obx that handles controller not found errors
class SafeObx extends StatelessWidget {
  final Widget Function() builder;

  const SafeObx(this.builder, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check if controller is registered before building Obx
    if (!Get.isRegistered<BoardGameController>()) {
      return SizedBox.shrink(); // Return empty widget if controller not found
    }

    try {
      return Obx(builder);
    } catch (e) {
      if (kDebugMode) {
        print('SafeObx caught error: $e');
      }
      return SizedBox.shrink();
    }
  }
}

class GameBoardView extends GetView<BoardGameController> {
  const GameBoardView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is properly initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Get difficulty from arguments if available
      final args = Get.arguments;
      if (args != null &&
          args is Map<String, dynamic> &&
          args.containsKey("difficulty")) {
        final difficulty = args["difficulty"] as Difficulty;
        controller.setDifficulty(difficulty);
      }
    });

    return WillPopScope(
      // Intercept back button to properly clean up
      onWillPop: () async {
        controller.backToHome();
        return false; // We handle navigation ourselves
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.amber[100]),
            onPressed: () => controller.backToHome(),
          ),
          actions: [_buildAction()],
          title: SafeObx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Score: ${controller.currentScore.value}",
                  style: BoardGameHeader.dfTitleStyle,
                ),
                Text(
                  "Difficulty: ${controller.currentDifficulty.value.name.capitalize}",
                  style: TextStyle(color: Colors.amber[100], fontSize: 12),
                ),
              ],
            ),
          ),
          centerTitle: true,
        ),
        backgroundColor: Colors.black,
        body: Stack(
          children: [BackGroundImage(), _buildBody(), _buildOverlayPauseGame()],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 9,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Spacer(),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 40.0, bottom: 20),
                    child: _buildNextPiecePreview(),
                  ),
                ),
                _buildBoardGame(),
                Spacer(),
                _buildControlGame(),
                Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextPiecePreview() {
    return Container(
      width: 80,
      height: 80,
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.amber[100]!, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.amber[100]!.withOpacity(0.3),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: SafeObx(() {
          return _buildNextPieceGrid(controller.nextPiece.value);
        }),
      ),
    );
  }

  Widget _buildNextPieceGrid(Piece nextPiece) {
    // Define a mini grid to show next piece
    const int gridSize = 4; // 4x4 grid

    // Get the pattern and calculate offsets to center it
    List<int> showPattern = _getTetrominoPattern(nextPiece.type);

    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: gridSize * gridSize,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: gridSize,
        mainAxisSpacing: 1,
        crossAxisSpacing: 1,
      ),
      itemBuilder: (context, index) {
        // Check if this position is part of the tetromino pattern
        if (showPattern.contains(index)) {
          // This is part of the tetromino
          return Container(
            decoration: BoxDecoration(
              color: Colors.amber[100],
              borderRadius: BorderRadius.circular(1),
            ),
          );
        } else {
          // Empty cell
          return Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(1),
            ),
          );
        }
      },
    );
  }

  List<int> _getTetrominoPattern(Tetromino type) {
    // Patterns centered in a 4x4 grid (indices 0-15)
    switch (type) {
      case Tetromino.L:
        return [5, 9, 13, 14]; // L shape
      case Tetromino.J:
        return [6, 10, 14, 13]; // J shape
      case Tetromino.I:
        // Center I horizontally
        return [4, 5, 6, 7]; // I shape (horizontal)
      case Tetromino.O:
        // Center O in a 4x4 grid
        return [5, 6, 9, 10]; // O shape
      case Tetromino.S:
        // Center S in a 4x4 grid
        return [5, 6, 8, 9]; // S shape
      case Tetromino.Z:
        // Center Z in a 4x4 grid
        return [4, 5, 9, 10]; // Z shape
      case Tetromino.T:
        // Center T in a 4x4 grid
        return [5, 8, 9, 10]; // T shape
    }
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
              onTap: controller.rotatePeice,
              icon: Icons.rotate_right,
            ),
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
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.2),
        ),
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
          if (Get.isRegistered<BoardGameController>()) {
            controller.downSpeed();
          }
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
              return SafeObx(() {
                final currentPiece = controller.currentPiece.value;
                try {
                  final int row = (index / rowLength).floor();
                  final int col = (index % rowLength);
                  if (currentPiece.position.contains(index)) {
                    return Pixel(color: Colors.amber[100], child: index);
                  } else if (controller.gameBoard[row][col] != null) {
                    return Pixel(color: Colors.amber[100], child: index);
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
    return SafeObx(() {
      final isPaused = controller.isPaused.value;
      final gameOver = controller.gameOver.value;
      final currentScore = controller.currentScore.value;
      final difficulty = controller.currentDifficulty.value;
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
                      label: gameOver ? "Game Over!" : "Paused!",
                    ),
                    SizedBox(height: 50),
                    if (isPaused)
                      AAButton(
                        label: "Continue",
                        ontap: () => controller.resumeGame(),
                      ),
                    if (gameOver) ...[
                      Text(
                        "Score",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      Text(
                        currentScore.toString(),
                        style: TextStyle(color: Colors.white, fontSize: 24),
                      ),
                      Text(
                        "Difficulty: ${difficulty.name.capitalize}",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
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
      child: Text(label, style: TextStyle(fontSize: 30, color: Colors.white)),
    );
  }

  Widget _buildAction() {
    return SafeObx(() {
      final countDown = controller.countdown.value;
      final isPaused = controller.isPaused.value;

      return Padding(
        padding: const EdgeInsets.all(10.0),
        child:
            (countDown == 0 && !isPaused)
                ? InkWell(
                  onTap: () => controller.pauseGame(),
                  child: Icon(Icons.pause, color: Colors.amber[100]),
                )
                : !isPaused
                ? Text("$countDown", style: BoardGameHeader.dfActionTextStyle)
                : SizedBox.shrink(),
      );
    });
  }
}
