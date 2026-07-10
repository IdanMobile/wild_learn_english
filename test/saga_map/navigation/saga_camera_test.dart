import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_flutter/saga_map/navigation/saga_camera.dart';
import 'package:learn_english_flutter/saga_map/world/saga_path.dart';

void main() {
  group('SagaCamera', () {
    test('defaults to tuned camera height and angle', () {
      final camera = SagaCamera();

      expect(camera.height, 0.48);
      expect(camera.angle, 0.17);
    });

    test('smoothly approaches target without jumping immediately', () {
      final camera = SagaCamera();
      camera.setTarget(depth(4).toDouble());

      camera.update(1 / 60, SagaPathPreset.gentle);

      expect(camera.visualProgress, greaterThan(0));
      expect(camera.visualProgress, lessThan(camera.targetProgress));
    });

    test('look-ahead moves cameraX before reaching a turn', () {
      final camera = SagaCamera();
      camera.setTarget(depth(3).toDouble());

      camera.update(1 / 10, SagaPathPreset.dramatic);

      expect(camera.cameraX.isFinite, isTrue);
      expect(camera.yaw.abs(), lessThanOrEqualTo(0.16));
    });

    test('nearestLevel activates around the midpoint between steps', () {
      final camera = SagaCamera();
      camera.visualProgress = depth(1) * 0.51;

      expect(camera.nearestLevel(null), 1);
    });

    test('nearestLevel respects finite max level', () {
      final camera = SagaCamera();
      camera.visualProgress = depth(1000).toDouble();

      expect(camera.nearestLevel(99), 99);
    });
  });
}
