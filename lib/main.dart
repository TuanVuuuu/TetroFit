import 'package:aa_teris/services/sound_manager.dart';
import 'package:flutter/material.dart';

import 'app.dart';

RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

// Use the singleton sound manager instance
final SoundManager soundManager = SoundManager();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // No need to initialize soundManager here as it's a singleton and already initialized above

  runApp(const MyApp());
}
