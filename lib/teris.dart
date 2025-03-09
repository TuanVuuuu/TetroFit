import 'dart:async';
import 'dart:math';

import 'package:aa_teris/base/widgets/background_image.dart';
import 'package:aa_teris/piece.dart';
import 'package:aa_teris/pixel.dart';
import 'package:aa_teris/utils/extensions/gesture_detector_extensions.dart';
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
  Piece currentPiece = Piece(type: Tetromino.L);

  int currentScore = 0;

  bool gameOver = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // showDialogStartGame();
    });
  }

  void startGame() {
    currentPiece.initializePiece();

    Duration fameRate = const Duration(milliseconds: 1000);
    _gameLoop(fameRate);
  }

  void _gameLoop(Duration fameRate) {
    Timer.periodic(fameRate, (timer) {
      setState(() {
        clearLines();
        checkLanding();

        if (gameOver) {
          timer.cancel();
          showDialogGameOver();
        }
        currentPiece.movePiece(Direction.down);
      });
    });
  }

  void showDialogGameOver() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Game Over"),
          content: Text("Your Score is: $currentScore"),
          actions: [
            TextButton(
              onPressed: () {
                resetGame();
                Navigator.pop(context);
              },
              child: Text("Play Again"),
            ),
          ],
        );
      },
    );
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
    gameOver = false;
    currentScore = 0;
    createNewPiece();
    startGame();
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
      gameOver = true;
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

        currentScore++;
      }
    }
  }

  bool isGameOver() {
    for (int col = 0; col < rowLength; col++) {
      if (gameBoard[0][col] != null) {
        return true;
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: [BackGroundImage(), _buildBody()]),
    );
  }

  Widget _buildBody() {
    return GestureDetectorExtensions.detectContinuousDrag(
      onDragUpdate: (direction, _) {
        switch (direction) {
          case SwipeDirection.left:
            moveLeft();
            break;
          case SwipeDirection.right:
            moveRight();
            break;
          default:
        }
      },
      child: Column(
        children: [
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                "Score: $currentScore",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
          Expanded(
            flex: 9,
            child: Center(
              child: Column(
                children: [
                  _buildBoardGame(),
                  _buildControlGame(),
                  _buildButtonPlayGame(),
                ],
              ),
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
        width: 80,
        height: 80,
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.green),
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
      child: FractionallySizedBox(
        widthFactor: 0.6,
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
                return Pixel(color: currentPiece.color, child: index);
              } else if (gameBoard[row][col] != null) {
                final Tetromino? tetrominoType = gameBoard[row][col];

                return Pixel(
                  color: tetrominoType?.color ?? Colors.white,
                  child: index,
                );
              } else {
                return Pixel(color: Colors.grey.shade900, child: index);
              }
            } catch (e) {
              return Pixel(color: Colors.grey.shade900, child: index);
            }
          },
        ),
      ),
    );
  }

  Widget _buildButtonPlayGame() {
    return InkWell(
      onTap: startGame,
      child: FractionallySizedBox(
        widthFactor: 0.8,
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.amber[100],
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Center(
                  child: Text(
                    "Play",
                    style: TextStyle(
                      color: Colors.amber[1000],
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
