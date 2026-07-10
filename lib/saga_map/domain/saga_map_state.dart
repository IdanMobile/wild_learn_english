import '../world/saga_path.dart';

/// Single source of truth for saga map movement.
///
/// This is the only movement state in the app — no duplicate scroll,
/// camera, or world position fields anywhere else. Derive any view
/// position from [progress] instead of storing it separately.
class SagaMapState {
  const SagaMapState({
    required this.progress,
    required this.currentLevel,
    this.pathPreset = SagaPathPreset.gentle,
    this.energy = 29,
    this.stars = 39,
  });

  final double progress;
  final int currentLevel;
  final SagaPathPreset pathPreset;
  final int energy;
  final int stars;

  SagaMapState copyWith({
    double? progress,
    int? currentLevel,
    SagaPathPreset? pathPreset,
    int? energy,
    int? stars,
  }) {
    return SagaMapState(
      progress: progress ?? this.progress,
      currentLevel: currentLevel ?? this.currentLevel,
      pathPreset: pathPreset ?? this.pathPreset,
      energy: energy ?? this.energy,
      stars: stars ?? this.stars,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SagaMapState &&
          runtimeType == other.runtimeType &&
          progress == other.progress &&
          currentLevel == other.currentLevel &&
          pathPreset == other.pathPreset &&
          energy == other.energy &&
          stars == other.stars;

  @override
  int get hashCode =>
      Object.hash(progress, currentLevel, pathPreset, energy, stars);
}
