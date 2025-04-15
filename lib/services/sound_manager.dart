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
  late AudioPlayer _sfxPlayer;

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

    _bgmPlayer = AudioPlayer(); // Khởi tạo lại
    _sfxPlayer = AudioPlayer(); // Khởi tạo lại
  }

  Future<void> playBgm(String filePath, {bool loop = true}) async {
    if (isMuted || isBgmPlaying) return;
    await _bgmPlayer
        .setReleaseMode(loop ? ReleaseMode.loop : ReleaseMode.release);
    await _bgmPlayer.play(AssetSource(filePath));
    isBgmPlaying = true;
  }

  Future<void> stopBgm() async {
    await _bgmPlayer.stop();
    isBgmPlaying = false;
  }

  Future<void> playSfx(String type) async {
    if (isMuted || isDisposed) {
      return;
    }

    try {
      String filePath = _getSfxFilePath(type);

      if (filePath.isEmpty) {
        return;
      }

      await _sfxPlayer.play(AssetSource(filePath));
    } catch (e) {
      if (kDebugMode) {
        print('============= LOG lỗi playSfx: $e');
      }
    }
  }

  String _getSfxFilePath(String type) {
    switch (type) {
      case 'block_place':
        return 'audio/block_place.wav';
      case 'line_clear':
        return 'audio/line_clear.wav';
      case 'game_over':
        return 'audio/game_over.wav';
      case 'combo':
        return 'audio/combo.wav';
      case 'button_click':
        return 'audio/button_click.wav';
      case 'invalid_move':
        return 'audio/invalid_move.wav';
      case 'high_score':
        return 'audio/high_score.wav';
      default:
        return 'audio/block_place.wav';
    }
  }

  Future<void> mute(bool mute) async {
    isMuted = mute;
    await SharedPreferenceManager.setMuted(mute);
    if (mute) {
      _bgmPlayer.stop();
      isBgmPlaying = false;
    }
  }

  void dispose() {
    if (isDisposed) return;
    isDisposed = true;

    _bgmPlayer.dispose();
    _sfxPlayer.dispose();
  }
}
