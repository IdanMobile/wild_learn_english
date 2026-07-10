import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_flutter/saga_map/domain/saga_map_state.dart';
import 'package:learn_english_flutter/saga_map/world/saga_path.dart';

void main() {
  test('defaults to the gentle path preset', () {
    const state = SagaMapState(progress: 0, currentLevel: 0);
    expect(state.pathPreset, SagaPathPreset.gentle);
  });

  test('copyWith can change preset without changing movement fields', () {
    const state = SagaMapState(progress: 12, currentLevel: 3);
    final next = state.copyWith(pathPreset: SagaPathPreset.dramatic);

    expect(next.progress, state.progress);
    expect(next.currentLevel, state.currentLevel);
    expect(next.pathPreset, SagaPathPreset.dramatic);
  });

  test('reward counters are real state and copy independently of progress', () {
    const state = SagaMapState(progress: 12, currentLevel: 0);
    final next = state.copyWith(energy: 30, stars: 44);

    expect(next.progress, state.progress);
    expect(next.currentLevel, state.currentLevel);
    expect(next.energy, 30);
    expect(next.stars, 44);
  });
}
