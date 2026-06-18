import 'package:audioplayers/audioplayers.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bloot/core/logger/app_logger.dart';
import 'package:bloot/core/network/cache_keys.dart';

@lazySingleton
class AudioService {
  AudioService({required SharedPreferences prefs}) : _prefs = prefs;

  final SharedPreferences _prefs;

  AudioPlayer? _cardPlayer;
  AudioPlayer? _trickWinPlayer;
  AudioPlayer? _roundEndPlayer;
  AudioPlayer? _gameWinPlayer;
  AudioPlayer? _gameLosePlayer;

  bool get _soundEnabled {
    return _prefs.getBool(CacheKeys.soundEffectsEnabled) ?? true;
  }

  Future<void> initialize() async {
    try {
      _cardPlayer = AudioPlayer();
      _trickWinPlayer = AudioPlayer();
      _roundEndPlayer = AudioPlayer();
      _gameWinPlayer = AudioPlayer();
      _gameLosePlayer = AudioPlayer();

      await _cardPlayer!.setSource(AssetSource('sounds/card_play.wav'));
      await _trickWinPlayer!.setSource(AssetSource('sounds/trick_win.wav'));
      await _roundEndPlayer!.setSource(AssetSource('sounds/round_end.wav'));
      await _gameWinPlayer!.setSource(AssetSource('sounds/game_win.wav'));
      await _gameLosePlayer!.setSource(AssetSource('sounds/game_lose.wav'));

      // Set low latency for card play
      await _cardPlayer!.setReleaseMode(ReleaseMode.stop);
    } catch (e) {
      AppLogger.error('Failed to initialize audio', error: e, tag: 'Audio');
    }
  }

  void playCardSound() => _play(_cardPlayer);
  void playTrickWinSound() => _play(_trickWinPlayer);
  void playRoundEndSound() => _play(_roundEndPlayer);
  void playGameWinSound() => _play(_gameWinPlayer);
  void playGameLoseSound() => _play(_gameLosePlayer);

  void _play(AudioPlayer? player) {
    if (!_soundEnabled) return;
    if (player == null) return;
    try {
      player.stop();
      player.resume();
    } catch (e) {
      AppLogger.error('Failed to play sound', error: e, tag: 'Audio');
    }
  }

  void dispose() {
    _cardPlayer?.dispose();
    _trickWinPlayer?.dispose();
    _roundEndPlayer?.dispose();
    _gameWinPlayer?.dispose();
    _gameLosePlayer?.dispose();
  }
}
