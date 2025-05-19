import 'package:aa_teris/main.dart';
import 'package:aa_teris/routes/app_routes.dart';
import 'package:aa_teris/services/share_preference_manager.dart';
import 'package:aa_teris/services/sound_manager.dart';
import 'package:aa_teris/values/values.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StartGame extends StatefulWidget {
  const StartGame({super.key});

  @override
  State<StartGame> createState() => _StartGameState();
}

class _StartGameState extends State<StartGame>
    with RouteAware, WidgetsBindingObserver {
  late ValueNotifier<Map<Difficulty, int>> highScores;
  late ValueNotifier<Difficulty> selectedDifficulty;
  late ValueNotifier<bool> isMuted;
  late SoundManager soundManager;

  @override
  void initState() {
    super.initState();
    highScores = ValueNotifier<Map<Difficulty, int>>({});
    selectedDifficulty = ValueNotifier<Difficulty>(Difficulty.medium);
    isMuted = ValueNotifier<bool>(false); // Default value
    soundManager = SoundManager();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await SharedPreferenceManager.migrateLegacyHighScore();
      await _loadHighScores();
      await _loadDifficulty();
      await _loadMuteState();
    });
  }

  Future<void> _loadHighScores() async {
    highScores.value = await SharedPreferenceManager.getAllHighScores();
  }

  Future<void> _loadDifficulty() async {
    selectedDifficulty.value =
        await SharedPreferenceManager.getCurrentDifficulty();
  }

  Future<void> _loadMuteState() async {
    isMuted.value = await SharedPreferenceManager.getMuted();
  }

  void effectButton() {
    soundManager.playSfx(SfxType.buttonClick);
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
    _loadHighScores();
    _loadDifficulty();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(extendBodyBehindAppBar: true, body: _buildBody());
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
                SizedBox(height: 20),
                _buildDifficultySelector(),
                SizedBox(height: 20),
                _buildHighScores(),
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

  Widget _buildDifficultySelector() {
    return ValueListenableBuilder(
      valueListenable: selectedDifficulty,
      builder:
          (context, value, child) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final difficulty in Difficulty.values)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      effectButton();
                      selectedDifficulty.value = difficulty;
                      await SharedPreferenceManager.setCurrentDifficulty(
                        difficulty,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          value == difficulty
                              ? difficulty.getColor()
                              : Colors.amber[200]?.withValues(alpha: 0.5),
                      foregroundColor: Colors.amber[800],
                    ),
                    child: Text(
                      difficulty.name.capitalize!,
                      style: TextStyle(
                        fontWeight:
                            value == difficulty
                                ? FontWeight.bold
                                : FontWeight.normal,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
    );
  }

  Widget _buildHighScores() {
    return ValueListenableBuilder(
      valueListenable: highScores,
      builder: (context, scores, child) {
        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                "High Scores",
                style: TextStyle(
                  color: Colors.amber[100],
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              ...Difficulty.values.map(
                (difficulty) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: difficulty.getColor(),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            difficulty.name.capitalize!,
                            style: TextStyle(
                              color: Colors.amber[100],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "${scores[difficulty] ?? 0}",
                        style: TextStyle(
                          color: Colors.amber[100],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
    return ValueListenableBuilder(
      valueListenable: selectedDifficulty,
      builder:
          (context, difficulty, child) => InkWell(
            onTap: () {
              soundManager.playSfx(SfxType.buttonClick);
              Get.toNamed(
                AppRoute.GAME.name,
                arguments: {"difficulty": difficulty},
              );
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
          ),
    );
  }

  Row _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(width: 12),
        ValueListenableBuilder(
          valueListenable: isMuted,
          builder:
              (context, value, child) => InkWell(
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
