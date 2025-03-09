import 'dart:async';
import 'package:flutter/material.dart';

typedef DragUpdateCallback =
    void Function(SwipeDirection direction, Offset position);

enum SwipeDirection { left, right, up, down }

extension GestureDetectorExtensions on GestureDetector {
  static GestureDetector detectContinuousDrag({
    required Widget child,
    required DragUpdateCallback onDragUpdate,
    VoidCallback? onDragEnd,
    Duration throttleDuration = const Duration(milliseconds: 200),
  }) {
    Timer? throttleTimer;
    Timer? inactivityTimer;
    Offset? lastPosition; // Lưu vị trí cuối cùng

    void resetInactivityTimer() {
      inactivityTimer?.cancel();
      inactivityTimer = Timer(throttleDuration * 1.5, () {
        // Nếu sau khoảng thời gian mà không có di chuyển, coi như đã dừng
        throttleTimer?.cancel();
      });
    }

    return GestureDetector(
      onPanUpdate: (details) {
        final dx = details.delta.dx;
        final dy = details.delta.dy;

        SwipeDirection direction;
        if (dx.abs() > dy.abs()) {
          direction = dx > 0 ? SwipeDirection.right : SwipeDirection.left;
        } else {
          direction = dy > 0 ? SwipeDirection.down : SwipeDirection.up;
        }

        // Kiểm tra nếu vị trí không thay đổi, tránh bắn callback thừa
        if (lastPosition == details.globalPosition) return;
        lastPosition = details.globalPosition;

        // Hủy và khởi tạo lại timer throttle để tránh callback dồn dập
        throttleTimer?.cancel();
        throttleTimer = Timer(throttleDuration, () {
          onDragUpdate(direction, details.globalPosition);
        });

        // Reset bộ đếm thời gian để phát hiện khi dừng kéo
        resetInactivityTimer();
      },
      onPanEnd: (details) {
        // Hủy ngay lập tức để ngăn callback tiếp tục bắn khi đã thả tay
        throttleTimer?.cancel();
        throttleTimer = null;
        onDragEnd?.call();
      },
      child: child,
    );
  }
}
