import 'dart:async';
import 'dart:math';

import 'package:aa_teris/base/widgets/background_image.dart';
import 'package:aa_teris/piece.dart';
import 'package:aa_teris/pixel.dart';
import 'package:aa_teris/values.dart';
import 'package:flutter/material.dart';

List<List<Tetromino?>> gameBoard = List.generate(
  colLength,
  (i) => List.generate(rowLength, (j) => null),
);

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  late ValueNotifier<int> countdown;
  Timer? countdownTimer;
  Piece currentPiece = Piece(type: Tetromino.L);

  int currentScore = 0;

  Timer? gameTimer;
  Duration frameRate = const Duration(milliseconds: 1500);

  late ValueNotifier<bool> isPaused;
  late ValueNotifier<bool> gameOverNotifier;

  @override
  void initState() {
    super.initState();
    countdown = ValueNotifier<int>(3);
    isPaused = ValueNotifier<bool>(false);
    gameOverNotifier = ValueNotifier<bool>(false);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      _startCountdown();
    });
  }

  @override
  void dispose() {
    resetGame();
    countdownTimer?.cancel();
    countdown.dispose();
    super.dispose();
  }

  void _startCountdown() {
    countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (countdown.value > 0) {
        countdown.value--;
      } else {
        timer.cancel();
        startGame();
      }
    });
  }

  void startGame() {
    currentPiece.initializePiece();
    _gameLoop();
  }

  void restartGame() {
    setState(() {
      isPaused.value = false;
      countdown.value = 3;
      resetGame();
      _startCountdown();
    });
  }

  void pauseGame() {
    if (gameTimer != null && gameTimer!.isActive) {
      gameTimer!.cancel();
      isPaused.value = true;
    }
  }

  void resumeGame() {
    if (isPaused.value) {
      _gameLoop();
      isPaused.value = false;
    }
  }

  void _gameLoop() {
    gameTimer = Timer.periodic(frameRate, (timer) {
      if (isPaused.value) {
        timer.cancel();
        return;
      }

      setState(() {
        clearLines();
        checkLanding();

        if (gameOverNotifier.value) {
          timer.cancel();
        }

        currentPiece.movePiece(Direction.down);
        // Cập nhật tốc độ game sau mỗi lần clear line
        updateFrameRate();
      });
    });
  }

  void updateFrameRate() {
    const int minFrameRate = 100; // Giới hạn tối thiểu (ms)
    const int initialFrameRate = 1500; // Frame rate ban đầu (ms)
    const double k = 0.00005; // Hệ số giảm tốc

    int newFrameRate = (initialFrameRate * exp(-k * currentScore)).toInt();
    newFrameRate = newFrameRate.clamp(minFrameRate, initialFrameRate);

    if (newFrameRate != frameRate.inMilliseconds) {
      frameRate = Duration(milliseconds: newFrameRate);
      gameTimer?.cancel();
      _gameLoop();
    }
  }

  void backToHome() {
    Navigator.pop(context);
  }

  void showDialogStartGame() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Teris Game"),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await Future.delayed(Duration(seconds: 1));
                startGame();
              },
              child: Text("Start game"),
            ),
          ],
        );
      },
    );
  }

  void resetGame() {
    gameBoard = List.generate(
      colLength,
      (i) => List.generate(rowLength, (j) => null),
    );
    gameOverNotifier.value = false;
    currentScore = 0;
    createNewPiece();
  }

  bool checkCollision(Direction direction) {
    for (int i = 0; i < currentPiece.position.length; i++) {
      int row = (currentPiece.position[i] / rowLength).floor();
      int col = currentPiece.position[i] % rowLength;

      if (direction == Direction.left) {
        col -= 1;
      } else if (direction == Direction.right) {
        col += 1;
      } else if (direction == Direction.down) {
        row += 1;
      }

      if (row >= colLength || col < 0 || col >= rowLength) {
        return true;
      }

      if (row >= 0 && gameBoard[row][col] != null) {
        return true;
      }
    }
    return false;
  }

  void checkLanding() {
    if (checkCollision(Direction.down)) {
      for (int i = 0; i < currentPiece.position.length; i++) {
        int row = (currentPiece.position[i] / rowLength).floor();
        int col = currentPiece.position[i] % rowLength;
        if (row >= 0 && col >= 0) {
          gameBoard[row][col] = currentPiece.type;
        }
      }

      createNewPiece();
    }
  }

  void createNewPiece() {
    Random random = Random();

    Tetromino randomType =
        Tetromino.values[random.nextInt(Tetromino.values.length)];

    currentPiece = Piece(type: randomType);
    currentPiece.initializePiece();

    if (isGameOver()) {
      gameOverNotifier.value = true;
    }
  }

  void moveLeft() {
    if (!checkCollision(Direction.left)) {
      setState(() {
        currentPiece.movePiece(Direction.left);
      });
    }
  }

  void moveRight() {
    if (!checkCollision(Direction.right)) {
      setState(() {
        currentPiece.movePiece(Direction.right);
      });
    }
  }

  void rotatePeice() {
    setState(() {
      currentPiece.rotatePeice();
    });
  }

  void clearLines() {
    for (int row = colLength - 1; row >= 0; row--) {
      bool rowIsFull = true;

      for (int col = 0; col < rowLength; col++) {
        if (gameBoard[row][col] == null) {
          rowIsFull = false;
          break;
        }
      }

      if (rowIsFull) {
        for (int r = row; r > 0; r--) {
          gameBoard[r] = List.from(gameBoard[r - 1]);
        }
        gameBoard[0] = List.generate(row, (index) => null);

        currentScore = currentScore + 100;
      }
    }
  }

  bool isGameOver() {
    if (gameBoard.isEmpty || gameBoard[0].length < rowLength) {
      return false;
    }

    for (int col = 0; col < rowLength; col++) {
      if (col < gameBoard[0].length && gameBoard[0][col] != null) {
        return true;
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.home),
          color: Colors.amber[100],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ValueListenableBuilder<bool>(
                valueListenable: isPaused,
                builder: (context, paused, child) {
                  return ValueListenableBuilder<int>(
                    valueListenable: countdown,
                    builder: (context, value, child) {
                      final textStyle = TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[100]);
                      if (value == 0 && !paused) {
                        return InkWell(
                            onTap: () => pauseGame(),
                            child: Icon(
                              Icons.pause,
                              color: Colors.amber[100],
                            ));
                      } else if (!paused) {
                        return Text(
                          "$value",
                          style: textStyle,
                        );
                      } else {
                        return SizedBox.shrink();
                      }
                    },
                  );
                }),
          ),
        ],
        title: Text(
          "Score: $currentScore",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Stack(children: [
        BackGroundImage(),
        _buildBody(),
        _buildOverlayPauseGame(),
      ]),
    );
  }

  Widget _buildOverlayPauseGame() {
    return ValueListenableBuilder<bool>(
        valueListenable: isPaused,
        builder: (context, pause, child) {
          return ValueListenableBuilder(
            valueListenable: gameOverNotifier,
            builder: (context, gameOver, child) {
              if (pause || gameOver) {
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
                            if (pause)
                              _buildButtonOverlay(
                                label: "Continue",
                                ontap: () => resumeGame(),
                              ),
                            if (gameOver) ...[
                              Text("Score",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18)),
                              Text(currentScore.toString(),
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 24)),
                            ],
                            _buildButtonOverlay(
                              label: "Restart",
                              ontap: () => restartGame(),
                            ),
                            _buildButtonOverlay(
                              label: "Home",
                              ontap: () => backToHome(),
                            ),
                            Spacer(),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                return SizedBox.shrink();
              }
            },
          );
        });
  }

  FractionallySizedBox _buildButtonOverlay({
    required String label,
    required VoidCallback ontap,
  }) {
    return FractionallySizedBox(
      widthFactor: 0.5,
      child: InkWell(
        onTap: ontap,
        child: Container(
          margin: EdgeInsets.only(top: 24),
          decoration: BoxDecoration(
            color: Colors.amber[100],
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.brown[600],
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
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
                SizedBox(),
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
              onTap: moveLeft,
              icon: Icons.arrow_back_ios_new,
            ),
            _buildButtonControl(onTap: rotatePeice, icon: Icons.rotate_right),
            _buildButtonControl(
              onTap: moveRight,
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

  void downSpeed() {
    while (!checkCollision(Direction.down)) {
      currentPiece.movePiece(Direction.down);
    }
    checkLanding(); // Khi rơi xong, kiểm tra và cập nhật game board
  }

  Widget _buildBoardGame() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.brown, width: 1),
      ),
      child: GestureDetector(
        onTap: () {
          downSpeed();
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
              try {
                final int row = (index / rowLength).floor();
                final int col = (index % rowLength);
                if (currentPiece.position.contains(index)) {
                  return Pixel(color: Colors.amber[100], child: index);
                } else if (gameBoard[row][col] != null) {
                  // final Tetromino? tetrominoType = gameBoard[row][col];

                  return Pixel(
                    color: Colors.amber[100],
                    child: index,
                  );
                } else {
                  return Pixel(color: Colors.grey.shade900, child: index);
                }
              } catch (e) {
                print('============= LOG check bug level $e');

                return Pixel(color: Colors.grey.shade900, child: index);
              }
            },
          ),
        ),
      ),
    );
  }
}
