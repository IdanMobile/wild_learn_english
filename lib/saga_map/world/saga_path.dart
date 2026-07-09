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

/// Deterministic sinusoidal horizontal offset for node [i].
double x(int i) => math.sin(i * _frequency) * _amplitude;

/// Monotonically increasing vertical depth for node [i].
int depth(int i) => i * _depthSpacing;

SagaNodeState _stateAt(int index, int currentLevel) {
  if (index < currentLevel) return SagaNodeState.completed;
  if (index == currentLevel) return SagaNodeState.current;
  return SagaNodeState.upcoming;
}

/// Returns the [SagaNode] for [index], purely derived from [index] and
/// [currentLevel]. Deterministic: identical arguments always produce an
/// identical node.
SagaNode nodeAt(int index, {required int currentLevel}) {
  return SagaNode(
    index: index,
    x: x(index),
    depth: depth(index),
    state: _stateAt(index, currentLevel),
  );
}
