/// Single source of truth for saga map movement.
///
/// This is the only movement state in the app — no duplicate scroll,
/// camera, or world position fields anywhere else. Derive any view
/// position from [progress] instead of storing it separately.
class SagaMapState {
  const SagaMapState({required this.progress, required this.currentLevel});

  final double progress;
  final int currentLevel;

  SagaMapState copyWith({double? progress, int? currentLevel}) {
    return SagaMapState(
      progress: progress ?? this.progress,
      currentLevel: currentLevel ?? this.currentLevel,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SagaMapState &&
          runtimeType == other.runtimeType &&
          progress == other.progress &&
          currentLevel == other.currentLevel;

  @override
  int get hashCode => Object.hash(progress, currentLevel);
}
