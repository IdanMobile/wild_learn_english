# Saga Map Architecture

## Runtime Flow

```text
SagaMapScreen
  -> GameWidget<SagaMapGame>
  -> SagaScrollPhysics
  -> SagaMapState(progress, currentLevel, pathPreset, energy, stars)
  -> buildSagaScene
     -> windowFor(currentLevel)
     -> nodeAt(index, currentLevel, preset)
     -> PerspectiveProjector.project(node, progress)
  -> SagaMapPainter.paint(scene)
```

Flutter owns app chrome: HUD buttons, debug overlay, and toggle state. Flame owns the game loop and canvas render callback. The world, projection, and rendering modules stay independent of Flutter widget state.

## Module Boundaries

- `domain/`: `SagaMapState`, `SagaNode`, and `SagaNodeState`.
- `world/`: deterministic index-based path generation, `levelForProgress`, path presets, and bounded visible windows.
- `navigation/`: drag-to-progress and inertia math only.
- `projection/`: pure depth projection and culling.
- `rendering/`: immutable `SagaScene`, scene assembly, and canvas painting.
- `debug/`: Flutter debug overlay.
- `ui/`: lightweight HUD.

Reward counters are real fields in `SagaMapState`, but they do not influence movement. `SagaMapGame` owns one bounded transient `SagaFxState`; it credits each FX serial once when the visible star/energy flight reaches the HUD. Interrupted rewards are accumulated into the next visible arrival so fast navigation cannot lose or duplicate rewards.

The Flutter HUD measures the energy/star chip centers after responsive layout and passes those screen-space targets to the Flame painter. No device coordinates are hardcoded for the normal runtime path.

## Key Decisions

- Use Flame for lifecycle and input, while keeping the world and projection independent of Flame components.
- Use a custom 2.5D projection instead of a general 3D engine; the required movement has one controlled camera path and no mesh-heavy scene.
- Generate nodes by index and render only a bounded window instead of retaining traversal history.
- Keep Flutter responsible for accessible application chrome and Canvas responsible for the continuously animated world.
- Add dependencies only when they replace meaningful lifecycle or platform work; the project currently needs only Flame and its audio bridge.

## Movement Invariant

`SagaMapState.progress` is the only primary movement value. `currentLevel` is derived from progress in the same state transition after every drag update:

```text
currentLevel = max(0, floor(progress / levelDepthSpacing))
```

The depth spacing value is owned by `saga_path.dart`; callers use `levelForProgress` instead of duplicating it.

## Bounded Infinity

The map never stores traversed history. Each frame derives a small `VisibleNodeWindow` around `currentLevel`, generates those indices deterministically, projects them, and paints only the resulting bounded scene.

## Scope Boundaries

This POC deliberately excludes backend services, persistence, authentication, analytics, authored lesson content, and a general 3D asset pipeline. The debug overlay reports FPS as unavailable rather than inventing a runtime measurement; measured profile results live in [performance/results.md](performance/results.md).
