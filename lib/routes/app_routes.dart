// ignore_for_file: constant_identifier_names

import 'package:aa_teris/controllers/game_controller.dart';
import 'package:aa_teris/views/board_game_screen.dart';
import 'package:aa_teris/views/start_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum AppRoute {
  HOME,
  GAME,
}

extension AppRouteExt on AppRoute {
  String get name {
    switch (this) {
      case AppRoute.HOME:
        return '/home';
      case AppRoute.GAME:
        return '/game';
    }
  }

  Widget get page {
    switch (this) {
      case AppRoute.HOME:
        return StartGame();
      case AppRoute.GAME:
        return GameBoardView();
    }
  }

  Bindings get binding {
    switch (this) {
      case AppRoute.HOME:
        return BindingsBuilder(() {});
      case AppRoute.GAME:
        return BindingsBuilder(() {
          Get.put(BoardGameController());
        });
    }
  }

  static AppRoute? from(String? name) {
    for (final item in AppRoute.values) {
      if (item.name == name) {
        return item;
      }
    }
    return null;
  }

  static Route generateRoute(RouteSettings settings) {
    final route = AppRouteExt.from(settings.name) ?? AppRoute.HOME;
    return GetPageRoute(
      settings: settings,
      page: () => route.page,
      transition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 200),
      curve: Curves.easeIn,
      bindings: [route.binding],
    );
  }

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static Route<dynamic> bindingRoute(RouteSettings settings) {
    return AppRouteExt.generateRoute(settings);
  }
}
