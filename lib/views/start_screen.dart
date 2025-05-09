import 'package:aa_teris/main.dart';
import 'package:aa_teris/routes/app_routes.dart';
import 'package:aa_teris/services/share_preference_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StartGame extends StatefulWidget {
  const StartGame({super.key});

  @override
  State<StartGame> createState() => _StartGameState();
}

class _StartGameState extends State<StartGame>
    with RouteAware, WidgetsBindingObserver {
  late ValueNotifier<int> hightScore;
  late ValueNotifier<bool> isMuted;

  @override
  void initState() {
    super.initState();
    hightScore = ValueNotifier<int>(0);
    isMuted = ValueNotifier<bool>(false); // Default value
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _setHightScore();
      await _loadMuteState();
    });
  }

  Future<void> _loadMuteState() async {
    isMuted.value = await SharedPreferenceManager.getMuted();
  }

  @override
  void didChangeDependencies() {
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    _setHightScore();
  }

  Future<void> _setHightScore() async {
    hightScore.value = await SharedPreferenceManager.getHighScore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                ValueListenableBuilder(
                  valueListenable: hightScore,
                  builder: (context, value, child) => Text(
                    "Score: $value",
                    style: TextStyle(color: Colors.amber[100], fontSize: 20),
                  ),
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
      onTap: () {
        soundManager.playSfx("button_click");
        Get.toNamed(AppRoute.GAME.name);
      },
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
        ValueListenableBuilder(
          valueListenable: isMuted,
          builder: (context, value, child) => InkWell(
            onTap: () async {
              isMuted.value = !isMuted.value;
              await soundManager.mute(isMuted.value);
            },
            child: Icon(
              value ? Icons.volume_off : Icons.volume_up,
              color: Colors.amber[100],
            ),
          ),
        ),
      ],
    );
  }
}
