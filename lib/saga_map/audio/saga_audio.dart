import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';

/// Minimal saga sound bank. Files live in `assets/audio/` and are fired at the
/// matching animation moments from [SagaMapGame] and `SagaMapScreen`.
///
/// Short SFX play through pre-warmed [AudioPool]s so there is no
/// create-player / decode latency on each hit (the plain `FlameAudio.play`
/// path re-prepares a player every call — audibly late for rapid taps). The
/// long ambient loop stays on `FlameAudio.bgm`, where latency doesn't matter.
///
/// Missing files degrade silently so the game runs before the assets land.
class SagaAudio {
  SagaAudio._();

  // Per-clip playback volume. See the mix table in the sounds spec.
  static const _volumes = <String, double>{
    'ui_tap.mp3': 0.45,
    'ui_disabled.mp3': 0.35,
    'node_select.mp3': 0.55,
    'node_arrive.mp3': 0.50,
    'node_complete.mp3': 0.70,
    'reward_spawn.mp3': 0.60,
    'reward_collect.mp3': 0.70,
    'combo_lightning.mp3': 0.95,
    'combo_number_pop.mp3': 0.60,
    'chest_open.mp3': 0.70,
    'crystal_shimmer.mp3': 0.50,
  };
  static const _ambient = 'ambient_magic_loop.mp3';
  static const _ambientVolume = 0.14;

  static bool muted = false;
  static final _pools = <String, AudioPool>{};
  static bool _ambientReady = false;
  static bool _ambientPlaying = false;

  /// Warm every pool + the ambient cache once (during game load). Each file is
  /// loaded independently so one missing clip never blocks the rest.
  static Future<void> preload() async {
    for (final file in _volumes.keys) {
      try {
        // 4 players covers overlapping bursts (e.g. rapid taps, combo stack).
        _pools[file] = await FlameAudio.createPool(file, maxPlayers: 4);
      } catch (error) {
        if (kDebugMode) debugPrint('Saga audio unavailable: $file ($error)');
      }
    }
    try {
      await FlameAudio.audioCache.load(_ambient);
      _ambientReady = true;
    } catch (error) {
      if (kDebugMode) debugPrint('Saga audio unavailable: $_ambient ($error)');
    }
  }

  static void _play(String file) {
    if (muted) return;
    // Fire-and-forget: the pool's players are already prepared, so start()
    // returns near-instantly.
    _pools[file]?.start(volume: _volumes[file] ?? 0.5);
  }

  static void uiTap() => _play('ui_tap.mp3');
  static void uiDisabled() => _play('ui_disabled.mp3');
  static void nodeSelect() => _play('node_select.mp3');
  static void nodeArrive() => _play('node_arrive.mp3');
  static void nodeComplete() => _play('node_complete.mp3');
  static void rewardSpawn() => _play('reward_spawn.mp3');
  static void rewardCollect() => _play('reward_collect.mp3');
  static void comboLightning() => _play('combo_lightning.mp3');
  static void comboNumberPop() => _play('combo_number_pop.mp3');
  static void chestOpen() => _play('chest_open.mp3');
  static void crystalShimmer() => _play('crystal_shimmer.mp3');

  static Future<void> startAmbient() async {
    if (muted || !_ambientReady) return;
    _ambientPlaying = true;
    await FlameAudio.bgm.play(_ambient, volume: _ambientVolume);
  }

  static Future<void> stopAmbient() async {
    _ambientPlaying = false;
    await FlameAudio.bgm.stop();
  }

  /// Pause everything audible when the app leaves the foreground / screen off.
  static Future<void> pauseAmbient() async {
    if (_ambientPlaying) await FlameAudio.bgm.pause();
  }

  /// Resume the loop on return to foreground (only if it was playing).
  static Future<void> resumeAmbient() async {
    if (_ambientPlaying && !muted) await FlameAudio.bgm.resume();
  }
}
