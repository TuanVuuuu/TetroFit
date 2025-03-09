import 'dart:io';

import 'package:aa_teris/teris.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StartGame extends StatefulWidget {
  const StartGame({super.key});

  @override
  State<StartGame> createState() => _StartGameState();
}

class _StartGameState extends State<StartGame> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setSystemUIMode();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _setSystemUIMode() {
    final isIos = Platform.isIOS;
    if (isIos) {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.immersiveSticky,
        overlays: [], // Ẩn bottom navigation bar
      );
    } else {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: [SystemUiOverlay.top], // Ẩn bottom navigation bar
      );
    }
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();

    // Kiểm tra nếu bottom navigation bar vừa hiển thị
    // final viewInsets = WidgetsBinding.instance.window.viewInsets.bottom;
    // if (viewInsets > 0) {
    // Nếu người dùng vuốt lên, hiển thị bottom navigation bar trong 3s
    Future.delayed(const Duration(seconds: 2), () {
      _setSystemUIMode();
    });
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber,
      extendBodyBehindAppBar: true,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Stack(
      children: [
        _buildBackgroundImage(),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                _buildHeader(),
                Spacer(),
                Text(
                  "Teris Game",
                  style: TextStyle(color: Colors.amber[100], fontSize: 40),
                ),
                Text(
                  "Score: 100",
                  style: TextStyle(color: Colors.amber[100], fontSize: 20),
                ),
                Spacer(),
                _buildButtonPlayGame(),
                Spacer(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Column _buildBackgroundImage() {
    return Column(
      children: [
        Expanded(
          child: Image.asset("assets/images/bg_app.jpg", fit: BoxFit.fitHeight),
        ),
      ],
    );
  }

  Widget _buildButtonPlayGame() {
    return InkWell(
      onTap:
          () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => GameBoard())),
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

  Row _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Icon(Icons.star_border, color: Colors.amber[100]),
        SizedBox(width: 12),
        Icon(Icons.volume_up, color: Colors.amber[100]),
      ],
    );
  }
}
