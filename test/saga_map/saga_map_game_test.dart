import 'package:flutter_test/flutter_test.dart';
import 'package:flame/events.dart';
import 'package:flutter/gestures.dart';
import 'package:learn_english_flutter/saga_map/projection/perspective_projector.dart';
import 'package:learn_english_flutter/saga_map/rendering/saga_fx.dart';
import 'package:learn_english_flutter/saga_map/rendering/saga_scene_builder.dart';
import 'package:learn_english_flutter/saga_map/saga_map_game.dart';
import 'package:learn_english_flutter/saga_map/world/saga_path.dart';

void main() {
  group('SagaMapGame drag movement', () {
    test('keeps progress absolute and non-negative through drag updates', () {
      // Pin a snappy camera so level activation is deterministic and not tied
      // to the cosmetic default response.
      final game = SagaMapGame()..setCameraTuning(response: 14);

      game.applyDragDelta(1000);
      final forwardProgress = game.state.progress;
      expect(forwardProgress, greaterThan(0));

      game.applyDragDelta(-1000000);
      expect(game.state.progress, 0);
      expect(game.state.currentLevel, 0);
    });

    test('derives currentLevel from animated camera progress', () {
      // Pin a snappy camera so level activation is deterministic and not tied
      // to the cosmetic default response.
      final game = SagaMapGame()..setCameraTuning(response: 14);

      for (final deltaY in <double>[1000, 56000, 281000, -112000, 70000]) {
        game.applyDragDelta(deltaY);
        game.update(1);
        game.update(1);
        expect(
          game.state.currentLevel,
          closeTo(levelForProgress(game.state.progress), 1),
        );
      }
    });

    test('large drag can advance several levels in a single transition', () {
      final game = SagaMapGame();

      game.applyDragDelta(depth(6) / 0.0025);
      game.update(1);

      expect(game.state.currentLevel, greaterThan(1));
      expect(
        game.state.currentLevel,
        closeTo(levelForProgress(game.state.progress), 1),
      );
    });

    test('glides to the next step and activates it', () {
      // Pin a snappy camera so level activation is deterministic and not tied
      // to the cosmetic default response.
      final game = SagaMapGame()..setCameraTuning(response: 14);

      // moveToLevel now glides progress over time, so pump until it settles.
      game.moveToLevel(1);
      for (var i = 0; i < 40; i++) {
        game.update(1 / 60);
      }

      expect(game.state.currentLevel, 1);
      expect(game.state.progress, depth(1).toDouble());
    });

    test('defaults to 100 finite steps', () {
      // Pin a snappy camera so level activation is deterministic and not tied
      // to the cosmetic default response.
      final game = SagaMapGame()..setCameraTuning(response: 14);

      game.moveToLevel(1000);
      for (var i = 0; i < 60; i++) {
        game.update(1 / 60);
      }

      expect(game.state.progress, depth(99).toDouble());
    });

    test('can switch to endless steps for testing', () {
      // Pin a snappy camera so level activation is deterministic and not tied
      // to the cosmetic default response.
      final game = SagaMapGame()..setCameraTuning(response: 14);

      game.setStepLimit(stepCount: null);
      game.moveToLevel(1000);
      for (var i = 0; i < 60; i++) {
        game.update(1 / 60);
      }

      expect(game.state.progress, depth(1000).toDouble());
    });

    test('release inertia advances progress through the same state source', () {
      // Pin a snappy camera so level activation is deterministic and not tied
      // to the cosmetic default response.
      final game = SagaMapGame()..setCameraTuning(response: 14);

      game.onDragEnd(
        DragEndEvent(
          1,
          DragEndDetails(velocity: Velocity(pixelsPerSecond: Offset(0, 900))),
        ),
      );
      game.update(1 / 60);

      expect(game.state.progress, greaterThan(0));
    });

    test('long traversal still builds a non-empty scene', () {
      final game = SagaMapGame();
      game.setStepLimit(stepCount: null);
      game.applyDragDelta(depth(1000) / 0.0025);
      game.update(1);

      final scene = buildSagaScene(
        game.state,
        const PerspectiveProjector(
          viewportCenterX: 200,
          horizonY: 100,
          baseY: 600,
        ),
      );

      expect(scene.nodes, isNotEmpty);
    });

    test('credits reward once when its flight reaches the HUD', () {
      // Pin a snappy camera so level activation is deterministic and not tied
      // to the cosmetic default response.
      final game = SagaMapGame()..setCameraTuning(response: 14);

      game.moveToLevel(1);
      for (var i = 0; i < 260; i++) {
        game.update(1 / 60);
      }

      expect(
        game.state.stars,
        39 + const SagaFxState(completedLevel: 1).rewardStarCount,
      );
      expect(game.state.energy, 30);

      for (var i = 0; i < 180; i++) {
        game.update(1 / 60);
      }
      expect(
        game.state.stars,
        39 + const SagaFxState(completedLevel: 1).rewardStarCount,
      );
      expect(game.state.energy, 30);
    });

    test('cleans up completion VFX after its bounded lifetime', () {
      // Pin a snappy camera so level activation is deterministic and not tied
      // to the cosmetic default response.
      final game = SagaMapGame()..setCameraTuning(response: 14);

      game.moveToLevel(1);
      // The celebration only fires once the step's bars finish filling.
      for (var i = 0; i < 180; i++) {
        game.update(1 / 60);
      }
      expect(game.fxState.isActive, isTrue);

      game.update(5);
      expect(game.fxState.isActive, isFalse);
      expect(game.fxState.activeAnimationCount, 0);
    });

    test('credits each completed step stars (per bar) and energy', () {
      // Pin a snappy camera so level activation is deterministic and not tied
      // to the cosmetic default response.
      final game = SagaMapGame()..setCameraTuning(response: 14);

      game.moveToLevel(1);
      for (var i = 0; i < 220; i++) {
        game.update(1 / 60);
      }
      game.moveToLevel(2);
      for (var i = 0; i < 260; i++) {
        game.update(1 / 60);
      }

      // Each step's stars are distributed across its 3 bars and credited as
      // they land, summing to the step's reward; energy is +1 per completion.
      final expectedStars =
          39 +
          const SagaFxState(completedLevel: 1).rewardStarCount +
          const SagaFxState(completedLevel: 2).rewardStarCount;
      expect(game.state.stars, expectedStars);
      expect(game.state.energy, 31);
    });

    test('major combo remains single and clears after completion', () {
      // Pin a snappy camera so level activation is deterministic and not tied
      // to the cosmetic default response.
      final game = SagaMapGame()..setCameraTuning(response: 14);

      game.moveToLevel(4);
      for (var i = 0; i < 200; i++) {
        game.update(1 / 60);
      }
      expect(game.fxState.comboNumber, 3);
      expect(game.fxState.activeAnimationCount, lessThanOrEqualTo(9));

      game.update(7); // combo finale holds longer before clearing
      expect(game.fxState.isActive, isFalse);
      expect(game.fxState.activeAnimationCount, 0);
    });
  });
}
