import 'dart:math' as math;

import '../domain/saga_node.dart';
import '../domain/saga_node_state.dart';

/// Pure, stateless generator for the saga path layout.
///
/// Every value is derived purely from [index] (and [currentLevel] for
/// state) — no cached history, no randomness, no side effects. Calling
/// [nodeAt] twice with the same arguments always yields an identical node.
const double _amplitude = 80;
const double _frequency = 0.6;
const int _depthSpacing = 140;

enum SagaPathPreset { gentle, dramatic }

enum SagaPropKind { chest, orb, crystal }

class SagaPathFrame {
  const SagaPathFrame({
    required this.tangentX,
    required this.tangentDepth,
    required this.normalX,
    required this.normalDepth,
    required this.curvature,
  });

  final double tangentX;
  final double tangentDepth;
  final double normalX;
  final double normalDepth;
  final double curvature;
}

double _amplitudeFor(SagaPathPreset preset) {
  switch (preset) {
    case SagaPathPreset.gentle:
      return _amplitude;
    case SagaPathPreset.dramatic:
      return 120;
  }
}

double _frequencyFor(SagaPathPreset preset) {
  switch (preset) {
    case SagaPathPreset.gentle:
      return _frequency;
    case SagaPathPreset.dramatic:
      return 0.82;
  }
}

/// Deterministic sinusoidal horizontal offset for node [i].
double x(int i, {SagaPathPreset preset = SagaPathPreset.gentle}) =>
    math.sin(i * _frequencyFor(preset)) * _amplitudeFor(preset);

/// Monotonically increasing vertical depth for node [i].
int depth(int i) => i * _depthSpacing;

SagaPropKind? propAt(int index) {
  if (index <= 0) return null;
  if (index % 7 == 3) return SagaPropKind.chest;
  if (index % 11 == 5) return SagaPropKind.orb;
  if (index % 13 == 8) return SagaPropKind.crystal;
  return null;
}

SagaPathFrame frameAt(
  int index, {
  SagaPathPreset preset = SagaPathPreset.gentle,
}) {
  final previousX = x(index - 1, preset: preset);
  final nextX = x(index + 1, preset: preset);
  final dx = nextX - previousX;
  final dz = (depth(index + 1) - depth(index - 1)).toDouble();
  final length = math.sqrt(dx * dx + dz * dz);
  final tangentX = length == 0 ? 0.0 : dx / length;
  final tangentDepth = length == 0 ? 1.0 : dz / length;
  final secondDifference =
      x(index + 1, preset: preset) -
      2 * x(index, preset: preset) +
      x(index - 1, preset: preset);
  final curvature = (secondDifference / _depthSpacing).clamp(-1.0, 1.0);

  return SagaPathFrame(
    tangentX: tangentX,
    tangentDepth: tangentDepth,
    normalX: -tangentDepth,
    normalDepth: tangentX,
    curvature: curvature,
  );
}

/// Canonical inverse of [depth] for deriving the current level from absolute
/// map progress. Progress is clamped at the origin and never resets.
int levelForProgress(double progress) {
  if (progress <= 0) return 0;
  return progress ~/ _depthSpacing;
}

SagaNodeState _stateAt(int index, int currentLevel) {
  if (index < currentLevel) return SagaNodeState.completed;
  if (index == currentLevel) return SagaNodeState.current;
  return SagaNodeState.upcoming;
}

/// Returns the [SagaNode] for [index], purely derived from [index] and
/// [currentLevel]. Deterministic: identical arguments always produce an
/// identical node.
SagaNode nodeAt(
  int index, {
  required int currentLevel,
  SagaPathPreset preset = SagaPathPreset.gentle,
}) {
  return SagaNode(
    index: index,
    x: x(index, preset: preset),
    depth: depth(index),
    state: _stateAt(index, currentLevel),
  );
}
