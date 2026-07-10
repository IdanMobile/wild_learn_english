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
      final game = SagaMapGame();

      game.applyDragDelta(1000);
      final forwardProgress = game.state.progress;
      expect(forwardProgress, greaterThan(0));

      game.applyDragDelta(-1000000);
      expect(game.state.progress, 0);
      expect(game.state.currentLevel, 0);
    });

    test('derives currentLevel from animated camera progress', () {
      final game = SagaMapGame();

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

    test('activates the next step before camera fully reaches it', () {
      final game = SagaMapGame();

      game.moveToLevel(1);
      game.update(1 / 15);

      expect(game.state.currentLevel, 1);
      expect(game.state.progress, depth(1).toDouble());
    });

    test('defaults to 100 finite steps', () {
      final game = SagaMapGame();

      game.moveToLevel(1000);

      expect(game.state.progress, depth(99).toDouble());
    });

    test('can switch to endless steps for testing', () {
      final game = SagaMapGame();

      game.setStepLimit(stepCount: null);
      game.moveToLevel(1000);

      expect(game.state.progress, depth(1000).toDouble());
    });

    test('release inertia advances progress through the same state source', () {
      final game = SagaMapGame();

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
      final game = SagaMapGame();

      game.moveToLevel(1);
      for (var i = 0; i < 180; i++) {
        game.update(1 / 60);
      }

      expect(
        game.state.stars,
        39 + const SagaFxState(completedLevel: 0).rewardStarCount,
      );
      expect(game.state.energy, 30);

      for (var i = 0; i < 180; i++) {
        game.update(1 / 60);
      }
      expect(
        game.state.stars,
        39 + const SagaFxState(completedLevel: 0).rewardStarCount,
      );
      expect(game.state.energy, 30);
    });

    test('cleans up completion VFX after its bounded lifetime', () {
      final game = SagaMapGame();

      game.moveToLevel(1);
      game.update(1 / 15);
      expect(game.fxState.isActive, isTrue);

      game.update(4);
      expect(game.fxState.isActive, isFalse);
      expect(game.fxState.activeAnimationCount, 0);
    });

    test('defers interrupted rewards until the next visible arrival', () {
      final game = SagaMapGame();

      game.moveToLevel(1);
      for (var i = 0; i < 8; i++) {
        game.update(1 / 60);
      }
      expect(game.state.currentLevel, 1);

      game.moveToLevel(2);
      for (var i = 0; i < 16; i++) {
        game.update(1 / 60);
      }
      expect(game.state.currentLevel, 2);
      expect(game.state.stars, 39);
      expect(game.state.energy, 29);

      for (var i = 0; i < 80; i++) {
        game.update(1 / 60);
      }
      final expectedStars =
          39 +
          const SagaFxState(completedLevel: 0).rewardStarCount +
          const SagaFxState(completedLevel: 1).rewardStarCount;
      expect(game.state.stars, expectedStars);
      expect(game.state.energy, 31);
    });

    test('major combo remains single and clears after completion', () {
      final game = SagaMapGame();

      game.moveToLevel(5);
      game.update(1);
      expect(game.fxState.comboNumber, 3);
      expect(game.fxState.activeAnimationCount, lessThanOrEqualTo(9));

      game.update(4);
      expect(game.fxState.isActive, isFalse);
      expect(game.fxState.activeAnimationCount, 0);
    });
  });
}
