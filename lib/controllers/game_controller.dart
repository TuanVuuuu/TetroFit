import 'dart:async';
import 'dart:math';

import 'package:aa_teris/main.dart';
import 'package:aa_teris/services/share_preference_manager.dart';
import 'package:aa_teris/models/piece.dart';
import 'package:aa_teris/values/values.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

int initializeFrameRate = 1000;

class BoardGameController extends GetxController {
  Rx<Timer> countdownTimer = Timer(Duration.zero, () {}).obs;
  Rx<Piece> currentPiece = Piece(type: Tetromino.L).obs;

  Rx<int> currentScore = 0.obs;

  Rx<Timer> gameTimer = Timer(Duration.zero, () {}).obs;
  Rx<Duration> frameRate = Duration(milliseconds: initializeFrameRate).obs;

  Rx<int> countdown = 3.obs;
  Rx<bool> isPaused = false.obs;
  Rx<bool> gameOver = false.obs;

  RxList<List<Tetromino?>> gameBoard = <List<Tetromino?>>[].obs;

  @override
  void onInit() {
    super.onInit();
    resetGame();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      startCountdown();
    });
  }

  @override
  void onClose() {
    super.onClose();
    resetGame();
    countdownTimer.value.cancel();
    super.dispose();
  }

  void startCountdown() {
    countdownTimer.value = Timer.periodic(Duration(seconds: 1), (timer) {
      if (countdown.value > 0) {
        countdown.value--;
      } else {
        timer.cancel();
        startGame();
      }
    });
  }

  void startGame() {
    currentPiece.value.position = currentPiece.value.initializePiece();
    currentPiece.refresh();
    refresh();
    gameLoop();
  }

  void resetGame() {
    gameBoard.clear();
    gameBoard.assignAll(
      List.generate(colLength, (i) => List.generate(rowLength, (j) => null)),
    );
    gameOver.value = false;
    isPaused.value = false;
    currentScore.value = 0;
    createNewPiece();
  }

  void createNewPiece() {
    Random random = Random();

    Tetromino randomType =
        Tetromino.values[random.nextInt(Tetromino.values.length)];

    currentPiece.value = Piece(type: randomType);
    currentPiece.value.position = currentPiece.value.initializePiece();
    currentPiece.refresh();

    if (isGameOver()) {
      setGameOver();
    }
  }

  void setGameOver() {
    soundManager.playSfx('game_over');
    gameOver.value = true;
    setHighScore();
  }

  Future<void> setHighScore() async {
    await SharedPreferenceManager.setHighScore(currentScore.value);
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

  void gameLoop() {
    gameTimer.value.cancel();
    gameTimer.value = Timer.periodic(frameRate.value, (timer) {
      if (isPaused.value) {
        timer.cancel();
        return;
      }

      clearLines();
      checkLanding();

      if (gameOver.value) {
        timer.cancel();
      }
      movePiece(Direction.down);

      // Cập nhật tốc độ game sau mỗi lần clear line
      updateFrameRate();
    });
  }

  void movePiece(Direction direction) {
    currentPiece.value.movePiece(direction);
    currentPiece.refresh();
  }

  void updateFrameRate() {
    const int minFrameRate = 100; // Giới hạn tối thiểu (ms)
    int initialFrameRate = initializeFrameRate; // Frame rate ban đầu (ms)
    const double k = 0.00005; // Hệ số giảm tốc

    int newFrameRate =
        (initialFrameRate * exp(-k * currentScore.value)).toInt();
    newFrameRate = newFrameRate.clamp(minFrameRate, initialFrameRate);

    if (newFrameRate != frameRate.value.inMilliseconds) {
      frameRate.value = Duration(milliseconds: newFrameRate);
      gameLoop();
    }
  }

  void checkLanding() {
    if (checkCollision(Direction.down)) {
      for (int i = 0; i < currentPiece.value.position.length; i++) {
        int row = (currentPiece.value.position[i] / rowLength).floor();
        int col = currentPiece.value.position[i] % rowLength;
        if (row >= 0 && col >= 0) {
          gameBoard[row][col] = currentPiece.value.type;
        }
      }

      createNewPiece();
    }
  }

  bool checkCollision(Direction direction) {
    for (int i = 0; i < currentPiece.value.position.length; i++) {
      int row = (currentPiece.value.position[i] / rowLength).floor();
      int col = currentPiece.value.position[i] % rowLength;

      if (direction == Direction.left) {
        col -= 1;
      } else if (direction == Direction.right) {
        col += 1;
      } else if (direction == Direction.down) {
        row += 1;
      }

      // Chạm đáy
      if (row >= colLength) {
        // soundManager.playSfx('block_place');
        return true;
      }

      // Chạm hai bên tường
      if (col < 0 || col >= rowLength) {
        return true;
      }

      // chạm các khối khác
      if (row >= 0 && gameBoard[row][col] != null) {
        // soundManager.playSfx('block_place');
        return true;
      }
    }
    return false;
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
        // Dịch tất cả hàng phía trên xuống
        for (int r = row; r > 0; r--) {
          gameBoard[r] = List.from(gameBoard[r - 1]);
        }

        // Đặt hàng trên cùng thành hàng trống
        gameBoard[0] = List.generate(rowLength, (index) => null);

        // Cập nhật điểm số
        currentScore.value += 100;
        soundManager.playSfx('line_clear');
      }
    }
  }

  void pauseGame() {
    if (gameTimer.value.isActive) {
      gameTimer.value.cancel();
      isPaused.value = true;
    }
  }

  void resumeGame() {
    if (isPaused.value) {
      gameLoop();
      isPaused.value = false;
    }
  }

  void restartGame() {
    isPaused.value = false;
    countdown.value = 3;
    resetGame();
    startCountdown();
  }

  void backToHome() {
    resetGame();
    Get.back();
  }

  void downSpeed() {
    if (countdown.value > 0) return;
    while (!checkCollision(Direction.down)) {
      movePiece(Direction.down);
    }
    soundManager.playSfx('block_place');
    checkLanding(); // Khi rơi xong, kiểm tra và cập nhật game board
  }

  void moveLeft() {
    if (!checkCollision(Direction.left)) {
      movePiece(Direction.left);
    }
  }

  void moveRight() {
    if (!checkCollision(Direction.right)) {
      movePiece(Direction.right);
    }
  }

  void rotatePeice() {
    currentPiece.value.rotatePeice();
    currentPiece.refresh();
  }
}
