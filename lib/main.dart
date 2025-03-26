import 'package:aa_teris/services/sound_manager.dart';
import 'package:flutter/material.dart';

import 'app.dart';

RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

late final SoundManager soundManager;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  soundManager = SoundManager();

  runApp(const MyApp());
}
