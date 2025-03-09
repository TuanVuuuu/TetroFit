import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// EXAMPLE

// Controller

// @override
// void onReady() {
//   super.onReady();
//   StatusBarExt.setInitializeSystemOverlayLightStyle(isLight: true);
// }

// View

// @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     backgroundColor: OHColor.bluePrimary,
//     appBar: AppBar(
//       toolbarHeight: 0,
//       systemOverlayStyle: StatusBarExt.systemUiOverlayLightStyle,
//     ),
//     body: Column(
//       children: [
//         _buildHeader(),
//         _buildListHistory(),
//       ],
//     ),
//   );
// }

extension StatusBarExt on BuildContext {
  /*
    Flutter không cập nhật ngay lập tức màu statusBarColor khi không có sự thay đổi nào
    Gây ra vấn đề khi chuyển giữa các màn hình mà statusBarColor giống nhau => xác suất gây ra màu nền statusbar chuyển về màu xám
    Giải pháp: Khi vào onReady => đặt cho nó một màu default khác với màu để trong SystemUiOverlayStyle của AppBar 
    => Flutter sẽ nhận ra sự thay đổi và cập nhật lại màu bg statusbar
  */
  static void setInitializeSystemOverlayLightStyle({required bool isLight}) {
    final lightStyle = systemUiOverlayLightStyle.copyWith(
      statusBarColor: Colors.brown,
    );
    final darkStyle = systemUiOverlayDarkStyle.copyWith(
      statusBarColor: Colors.brown,
    );
    if (isLight) {
      SystemChrome.setSystemUIOverlayStyle(lightStyle);
    } else {
      SystemChrome.setSystemUIOverlayStyle(darkStyle);
    }
  }

  // Status bar background trong suốt, nội dung màu đen
  static SystemUiOverlayStyle get systemUiOverlayDarkStyle {
    return SystemUiOverlayStyle(
      // Status bar color
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
      statusBarBrightness: Brightness.light, // For iOS (dark icons)
    );
  }

  // Status bar background trong suốt, nội dung màu trắng
  static SystemUiOverlayStyle get systemUiOverlayLightStyle {
    return SystemUiOverlayStyle(
      // Status bar color
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light, // For Android (light icons)
      statusBarBrightness: Brightness.dark, // For iOS (light icons)
    );
  }

  static void setStatusBarColor({Color? color, bool? isLight}) {
    final lightStyle = systemUiOverlayLightStyle.copyWith(
      statusBarColor: color ?? Colors.transparent,
    );

    final darkStyle = systemUiOverlayDarkStyle.copyWith(
      statusBarColor: color ?? Colors.transparent,
    );
    if (isLight ?? true) {
      SystemChrome.setSystemUIOverlayStyle(lightStyle);
    } else {
      SystemChrome.setSystemUIOverlayStyle(darkStyle);
    }
  }

  // Ẩn hoàn toàn status bar
  static void hideStatusBar() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky, overlays: []);
  }

  // Hiển thị lại status bar
  static void showStatusBar() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }
}
