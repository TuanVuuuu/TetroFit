import 'dart:async';

import 'package:aa_teris/values/values.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:aa_teris/services/share_preference_manager.dart';
import 'package:flutter/foundation.dart';

class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() {
    if (_instance.isDisposed) {
      _instance.reset(); // Nếu đã dispose thì khởi tạo lại
    }
    return _instance;
  }

  late AudioPlayer _bgmPlayer;
  final Map<SfxType, AudioPlayer> _sfxPlayers = {};
  final Map<SfxType, bool> _isPlaying = {};
  final Map<SfxType, Timer?> _soundTimers = {};

  // Duration in milliseconds for each sound effect
  final Map<SfxType, int> _soundDurations = {
    SfxType.blockPlace: 300,
    SfxType.lineClear: 500,
    SfxType.gameOver: 1000,
    SfxType.combo: 700,
    SfxType.buttonClick: 200,
    SfxType.invalidMove: 300,
    SfxType.highScore: 800,
  };

  bool isBgmPlaying = false;
  bool isMuted = false;
  bool isDisposed = false;

  SoundManager._internal() {
    reset(); // Khởi tạo ngay khi instance được tạo
    _loadMuteState(); // Load mute state from SharedPreferences
  }

  Future<void> _loadMuteState() async {
    isMuted = await SharedPreferenceManager.getMuted();
  }

  void reset() {
    isBgmPlaying = false;
    isMuted = false;
    isDisposed = false;

    // Initialize or reset audio players
    _bgmPlayer = AudioPlayer();

    // Cancel all timers
    _cancelAllTimers();

    // Reset players and state for each sound type
    for (var type in SfxType.values) {
      // Dispose existing player if any
      _sfxPlayers[type]?.dispose();
      // Create new player
      _sfxPlayers[type] = AudioPlayer();
      // Reset state
      _isPlaying[type] = false;
      _soundTimers[type] = null;
    }
  }

  void _cancelAllTimers() {
    for (var timer in _soundTimers.values) {
      timer?.cancel();
    }
  }

  Future<void> playBgm(String filePath, {bool loop = true}) async {
    if (isMuted || isBgmPlaying) return;
    await _bgmPlayer.setReleaseMode(
      loop ? ReleaseMode.loop : ReleaseMode.release,
    );
    await _bgmPlayer.play(AssetSource(filePath));
    isBgmPlaying = true;
  }

  Future<void> stopBgm() async {
    await _bgmPlayer.stop();
    isBgmPlaying = false;
  }

  Future<void> playSfx(SfxType type) async {
    // Don't play if muted, disposed or already playing this sound
    if (isMuted || isDisposed || _isPlaying[type] == true) {
      return;
    }

    try {
      String filePath = _getSfxFilePath(type);

      if (filePath.isEmpty) {
        return;
      }

      // Mark this sound type as currently playing
      _isPlaying[type] = true;

      // Set a timer to mark when this sound is done playing
      _soundTimers[type]?.cancel();
      _soundTimers[type] = Timer(
        Duration(milliseconds: _soundDurations[type] ?? 500),
        () {
          _isPlaying[type] = false;
          _soundTimers[type] = null;
        },
      );

      // Use the dedicated player for this sound type
      final player = _sfxPlayers[type];
      if (player != null) {
        await player.play(AssetSource(filePath));
      }
    } catch (e) {
      // Reset the playing status if there was an error
      _isPlaying[type] = false;
      _soundTimers[type]?.cancel();
      _soundTimers[type] = null;

      if (kDebugMode) {
        print('============= LOG lỗi playSfx: $e');
      }
    }
  }

  String _getSfxFilePath(SfxType type) {
    return 'audio/${type.value}.wav';
  }

  Future<void> mute(bool mute) async {
    isMuted = mute;
    await SharedPreferenceManager.setMuted(mute);
    if (mute) {
      // Stop all audio
      _bgmPlayer.stop();
      for (var player in _sfxPlayers.values) {
        player.stop();
      }
      isBgmPlaying = false;
    }
  }

  void dispose() {
    if (isDisposed) return;
    isDisposed = true;

    // Reset playing state
    for (var type in SfxType.values) {
      _isPlaying[type] = false;
    }

    _cancelAllTimers();

    // Make sure to cancel and dispose all audio players
    _bgmPlayer.stop();
    _bgmPlayer.dispose();

    for (var player in _sfxPlayers.values) {
      player.stop();
      player.dispose();
    }
    _sfxPlayers.clear();

    isBgmPlaying = false;
  }

  // Add a static method to access from anywhere
  static void disposeAll() {
    _instance.dispose();
  }
}
