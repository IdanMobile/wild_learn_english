# Saga Map Flutter POC

Flutter/Flame proof of concept for a depth-rich saga map: drag through an apparently infinite path of projected stones, keep runtime work bounded, show a distant castle anchor, and expose debug proof for progress, visible count, projection, and path presets.

## Run

```sh
flutter pub get
flutter run -d <android-device-id>
```

Useful checks:

```sh
flutter analyze
flutter test
flutter build apk --debug
```

## Architecture

```text
User drag
  -> SagaScrollPhysics
  -> SagaMapState.progress
  -> levelForProgress(progress)
  -> VisibleNodeWindow
  -> SagaPath.nodeAt(index)
  -> PerspectiveProjector
  -> SagaScene
  -> SagaMapPainter
  -> Flame GameWidget + Flutter HUD
```

`SagaMapState.progress` is the single movement source of truth. `currentLevel` is derived from it through `levelForProgress`, so long traversal advances the bounded visible window instead of accumulating rendered nodes or going blank.

Flame is used for the game/render lifecycle and input delivery. The infinite-world math, projection, scene assembly, and rendering remain small app-owned modules because they are specific to this POC. See [ARCHITECTURE_DECISIONS.md](ARCHITECTURE_DECISIONS.md) for rationale.

## Features

- deterministic infinite logical path
- bounded visible-node window
- perspective-style projection with horizon compression
- fog, shadows, current/completed/upcoming node styling
- distant castle asset rendered as a horizon anchor
- drag movement with inertia math covered by tests
- debug overlay with progress, current index, visible count, preset, and projection line
- live gentle/dramatic path preset toggle
- camera damping, look-ahead, yaw, pitch, foreshortening, and ground-plane pass-by behavior
- animated node arrival/completion, sequential progress arcs, checkmark reveal, and bounded particles
- stars and energy fly to measured responsive HUD targets before counters update
- generated chest, orb, and crystal props with deterministic bounded spawning
- large supplied lightning/combo sequence with dynamic number and residual streak
- responsive HUD controls, side tools, bottom navigation, and map nodes with contextual panels

## Performance

Current local verification on 2026-07-10:

- `flutter analyze`: passed
- `flutter test`: 70/70 passed
- `flutter build apk --debug`: passed
- Android emulator profile build/install/run: passed on API 35 and API 37 AVDs
- physical Android profile run: passed on a Pixel 7 Pro running Android 16
- controlled 30-second traversal: 120 FPS average with three isolated slow frames and no persistent jank or crash
- API 37 emulator profile timings were invalid because the virtual device was severely overloaded; API 35 exposed no frames to DevTools

Details are recorded in [docs/performance/results.md](docs/performance/results.md).

## Limitations

Audio polish was skipped because no approved audio assets are present and it is optional to the core map proof. Three isolated slow frames in the physical stress scenario remain available for later micro-optimization.

## Future Work

- tune visual constants from broader physical-device screenshots
- inspect the three isolated physical-profile slow frames if stricter 120 Hz consistency is required
- add optional audio after approved sound assets are available
