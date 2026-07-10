/// Pure, stateless derivation of which node indices should currently exist
/// in the scene, given only [currentLevel]. No cached history, no
/// accumulation across calls — every call recomputes the window from
/// scratch, so it stays bounded no matter how large [currentLevel] grows.
const int _behind = 2;
const int _ahead = 14;

/// Inclusive bounded range of node indices to render.
class VisibleNodeWindow {
  const VisibleNodeWindow({required this.start, required this.end});

  final int start;
  final int end;

  /// Number of indices in the window.
  int get length => end - start + 1;

  /// Indices in the window, in ascending order, with no duplicates.
  List<int> get indices => List<int>.generate(length, (i) => start + i);
}

/// Returns the bounded [VisibleNodeWindow] for [currentLevel]: a small
/// number of indices behind it and a constant number ahead. The result
/// never grows regardless of how large [currentLevel] is.
VisibleNodeWindow windowFor(int currentLevel) {
  final start = currentLevel - _behind < 0 ? 0 : currentLevel - _behind;
  final end = currentLevel + _ahead;
  return VisibleNodeWindow(start: start, end: end);
}
