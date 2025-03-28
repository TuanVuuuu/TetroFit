import 'package:aa_teris/main.dart';
import 'package:aa_teris/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'flavors.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
      ),
    );
    return GetMaterialApp(
      title: F.title,
      theme: ThemeData(primarySwatch: Colors.blue),

      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.cupertino,
      initialRoute: AppRoute.HOME.name,
      initialBinding: AppRoute.HOME.binding,
      onGenerateInitialRoutes: (initialRoute) {
        final settings = RouteSettings(
          name: initialRoute,
          arguments: Get.arguments,
        );
        return [AppRouteExt.bindingRoute(settings)];
      },
      onGenerateRoute: AppRouteExt.bindingRoute,
      navigatorObservers: <NavigatorObserver>[routeObserver],
    );
  }
}
