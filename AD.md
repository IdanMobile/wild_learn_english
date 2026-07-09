# Saga Map Flutter POC — Architecture & Delivery Directive

> **Status:** Authoritative implementation source of truth (SSOT)
> **Target:** 2-day interview POC
> **Platform:** Android presentation target
> **Primary framework:** Flutter
> **Approved game/render lifecycle package:** Flame
> **Core rendering strategy:** Custom 2.5D perspective projection over a deterministic infinite logical world
> **Date locked:** 2026-07-08

> **Decision rationale companion:** `ARCHITECTURE_DECISIONS.md`
> This file is normative execution guidance. The companion file records why decisions were made, alternatives compared, evidence, tradeoffs, and re-evaluation triggers. Coding agents must not reinterpret locked decisions from the companion file unless `AD.md` is deliberately amended.

---

# 0. EXECUTE THIS FILE — DO NOT REINTERPRET THE PROJECT

This document is the single authoritative implementation source of truth for the Saga Map interview POC.

All coding agents, reviewers, planners, and subagents must:

1. Read this file in full before changing code.
2. Follow the architecture and boundaries defined here.
3. Treat decisions marked **LOCKED** as immutable unless a documented blocker proves the decision invalid.
4. Never create a competing architecture document or hidden progress tracker.
5. Record implementation progress only in the progress section of this file.
6. Update this file when a decision materially changes.
7. Prefer deletion over speculative abstraction.
8. Stop feature work when a mandatory gate fails.
9. Never claim performance, visual fidelity, or correctness without evidence.
10. Keep the implementation small enough that one senior Flutter developer can explain nearly all of it in an interview.

If code and this document disagree, this document wins until it is deliberately amended.

---

# 1. NORTH STAR

## 1.1 Interview assignment intent

Implement a Flutter saga-map experience whose essential behavior is:

- scrolling through a depth-rich 3D-feeling saga map;
- apparently infinite stepping stones/nodes;
- a castle visible on the horizon;
- smooth, convincing movement through the map.

Other demo details are bonuses.

## 1.2 North Star outcome

Deliver the strongest two-day Flutter interview POC by demonstrating:

1. a visually convincing saga-map experience;
2. intentional architecture decisions;
3. infinite logical progression with bounded runtime work;
4. clean Flutter/package boundaries;
5. measurable Android performance;
6. low redundancy and explainable code;
7. an obvious path for future product development.

## 1.3 Success definition

The POC succeeds when an interviewer can quickly see and verify:

- the map feels three-dimensional;
- the user can continuously drag/scroll through the journey;
- stones continue indefinitely;
- the visible/rendered workload remains bounded;
- the castle remains a convincing distant horizon anchor;
- the app runs smoothly on the chosen Android presentation device;
- architecture responsibilities are obvious;
- package choices are deliberate;
- future features can be added without rewriting the core world model.

## 1.4 Failure definition

The POC fails if any of these happen:

- true-3D experimentation consumes the delivery window;
- the map is visually flat or obviously just a vertical list;
- infinite progression creates unbounded widgets/components/objects;
- multiple progress/camera/scroll values drift independently;
- AI agents create duplicated architectures or boilerplate;
- the app cannot be explained clearly;
- bonus features are polished while the core map remains weak;
- performance is claimed without physical-device profile evidence.

---

# 2. LOCKED SCOPE

## 2.1 Must ship

- [ ] Android-runnable Flutter app
- [ ] one primary Saga Map screen
- [ ] vertical drag interaction
- [ ] inertia/friction after release
- [ ] one progression SSOT
- [ ] deterministic infinite logical node sequence
- [ ] bounded visible-node window
- [ ] depth projection
- [ ] near/far scale variation
- [ ] horizon compression
- [ ] depth-aware draw ordering
- [ ] atmosphere/fog treatment
- [ ] distant castle anchor
- [ ] current/completed/upcoming node states
- [ ] simple Flutter HUD
- [ ] debug/architecture overlay
- [ ] unit tests for core mathematical/domain invariants
- [ ] physical Android profile-mode verification
- [ ] architecture and decision documentation

## 2.2 Should ship if core gates are green

- [ ] subtle current-node animation
- [ ] one node tap/selection interaction
- [ ] path preset/config variation proving separation of world generation from rendering
- [ ] small celebration/particle effect
- [ ] simple demo-like top counters
- [ ] simple bottom navigation shell
- [ ] minimal event-driven sound feedback using `flame_audio`

## 2.3 Optional only after all mandatory gates

- [ ] custom fragment shader for haze/vignette
- [ ] additional reward icons
- [ ] richer castle artwork
- [ ] extra transitions
- [ ] advanced particles
- [ ] optional low-volume ambient/background loop

## 2.4 Explicit non-goals

Do not build:

- backend;
- authentication;
- persistence;
- production analytics;
- networking;
- iOS-specific polish;
- web support;
- desktop support;
- full design system;
- full navigation architecture;
- production CMS;
- Unity integration;
- Filament bridge;
- custom Flutter GPU renderer;
- glTF pipeline;
- real 3D engine in the critical path;
- Forge2D physics;
- generic plugin architecture;
- enterprise clean-architecture ceremony.

---

# 3. LOCKED TECHNICAL DECISIONS

Detailed rationale, alternatives, evidence, and re-evaluation triggers live in `ARCHITECTURE_DECISIONS.md`. This section contains only the normative decisions the implementation must follow.

## ADR summary

| ID | Decision | Status | Rationale reference |
|---|---|---|---|
| ADR-001 | Flutter + Flame lifecycle, custom 2.5D map projection | LOCKED | `ARCHITECTURE_DECISIONS.md#adr-001` |
| ADR-002 | Infinite logical indexing + bounded visible window | LOCKED | `ARCHITECTURE_DECISIONS.md#adr-002` |
| ADR-003 | One progression value as movement SSOT | LOCKED | `ARCHITECTURE_DECISIONS.md#adr-003` |
| ADR-004 | Flutter owns app UI; map engine owns world rendering | LOCKED | `ARCHITECTURE_DECISIONS.md#adr-004` |
| ADR-005 | Android physical-device profile evidence required | LOCKED | `ARCHITECTURE_DECISIONS.md#adr-005` |
| ADR-006 | True-3D packages excluded from critical path | LOCKED | `ARCHITECTURE_DECISIONS.md#adr-006` |
| ADR-007 | Bounded derived window before explicit object pooling | LOCKED | `ARCHITECTURE_DECISIONS.md#adr-007` |
| ADR-008 | Minimal dependency set; add packages only for demonstrated need | LOCKED | `ARCHITECTURE_DECISIONS.md#adr-008` |
| ADR-009 | Minimal event-driven audio via `flame_audio`; audio never owns gameplay state | LOCKED | `ARCHITECTURE_DECISIONS.md#adr-009` |
| ADR-010 | Hybrid asset strategy: procedural repeated geometry, generated signature art, curated licensed support assets | LOCKED | `ARCHITECTURE_DECISIONS.md#adr-010` |

---

# 4. PACKAGE POLICY

## 4.1 Approved core dependency

### Flame

Use Flame only for capabilities it genuinely earns:

- game/update lifecycle;
- render lifecycle integration;
- input integration where useful;
- optional effects/particles;
- optional debug/FPS support.

Do not turn every domain object into a Flame component.

Official references to verify at implementation time:

- Flame docs: https://docs.flame-engine.org/
- Flame game lifecycle: https://docs.flame-engine.org/latest/flame/game.html
- Flame performance guidance: https://docs.flame-engine.org/latest/flame/other/performance.html
- Flame debug features: https://docs.flame-engine.org/latest/flame/other/debug.html
- Flame particles: https://docs.flame-engine.org/latest/flame/rendering/particles.html
- pub.dev package: https://pub.dev/packages/flame

### flame_audio

Approved for minimal POC audio only. Use it because it is Flame's official audio bridge and already fits the selected runtime boundary.

Allowed uses:

- short preloaded SFX for node select/tap;
- short completion/checkmark SFX;
- optional celebration SFX;
- optional low-volume ambient/background loop only after core gates are green.

Rules:

- gameplay/domain state emits or exposes meaningful events; audio reacts to them;
- audio must never become a source of truth for progression, selection, or completion;
- no generic `AudioManager`, `SoundService`, event bus, or audio abstraction unless a second concrete backend/use case proves the need;
- preload/cached short SFX before presentation use;
- use `AudioPool` only for a short effect that is proven to fire rapidly/overlap and benefits from preloaded players;
- missing or failed audio playback must degrade silently or log in debug mode; it must not block scrolling, rendering, or app startup;
- do not trigger a sound every frame or for every tiny drag delta;
- all audio is optional to the core map experience.

Official references to verify at implementation time:

- Flame Audio docs: https://docs.flame-engine.org/latest/bridge_packages/flame_audio/audio.html
- Flame AudioPool docs: https://docs.flame-engine.org/latest/bridge_packages/flame_audio/audio_pool.html
- Flame BGM docs: https://docs.flame-engine.org/latest/bridge_packages/flame_audio/bgm.html
- pub.dev package: https://pub.dev/packages/flame_audio

## 4.2 Asset strategy — LOCKED

Use a hybrid asset pipeline. The asset source depends on the object's runtime responsibility, not convenience.

### A. Procedural/code-generated assets — default for repeated world geometry

Create in code/rendering logic:

- saga stones/platforms;
- stone shadows;
- current-node rings and progress circles;
- fog/horizon fading;
- simple path decorations when cheap;
- particles where Flame/native drawing is sufficient.

Rules:

- repeated infinite-world geometry must not depend on dozens of unique raster files;
- depth, state, scale, fog, and theme variations should derive from runtime rendering where practical;
- prefer one reusable procedural renderer or at most a few deterministic variants;
- never generate one asset per logical stone/node;
- procedural visuals must remain deterministic where visual continuity depends on node index.

### B. Generated signature art — preferred for unique atmospheric elements

AI-generated or manually illustrated transparent/layered assets are allowed for:

- distant castle;
- far mountains/landscape silhouette;
- one or two cloud/haze layers;
- optional unique reward/hero object.

Rules:

- generate/export environment art as separate composable layers, not one baked screenshot of the whole scene;
- prefer transparent PNG/WebP where compositing requires alpha;
- castle and background layers must not own gameplay state;
- world movement/parallax remains code-controlled;
- generated art must visually match the chosen POC style and be reviewed on the target Android device;
- signature environment art must support **distance-aware presentation**: apparent scale, atmospheric wash, color intensity, contrast, opacity, and clarity may change as relative depth changes;
- do not assume a generated image remains visually identical at all distances. The renderer owns how depth alters its appearance;
- use dynamic blur only after profiling proves it safe. Prefer scale, fog/haze blending, opacity, tint/desaturation, and contrast-like treatment first;
- optional detail overlays or near/far LOD variants are allowed only when a single high-resolution asset becomes visibly insufficient on the target device.

#### Distance-aware signature asset behavior — LOCKED

For assets such as the castle, derive presentation from relative depth:

```text
relative depth
→ projected scale
→ atmospheric haze/fog amount
→ opacity/contrast treatment
→ color intensity/saturation-like treatment
→ optional detail-layer/LOD blend
```

Expected behavior:

- **far:** small, pale/gray-blue, low contrast, heavily atmospheric, details subdued;
- **mid:** larger, less haze, stronger color separation, more readable silhouette;
- **near:** larger, minimal haze, stronger color/contrast, maximum available detail.

Default implementation order:

1. one high-quality source asset;
2. depth-based scale;
3. depth-based haze/fog blend;
4. depth-based opacity/tint/color-intensity treatment;
5. only then consider a second detail overlay or near/far LOD asset if visually necessary.

The first POC implementation must not require multiple castle assets. LOD is an optional escalation path, not a default dependency.

Recommended environment layering:

```text
sky/background
→ far landscape
→ distant castle
→ haze/fog
→ projected saga nodes
→ world-linked effects
→ Flutter HUD
```

### C. Curated existing assets — only for generic supporting UI/content

Downloaded/reused assets are appropriate for common supporting elements such as:

- heart;
- coin;
- gem;
- gift;
- trophy;
- other generic HUD icons.

Rules:

- prefer Flutter/material/vector icons when they fit visually;
- otherwise use a coherent SVG/PNG icon set rather than mixing unrelated styles;
- do not browse asset marketplaces indefinitely; implementation time takes priority;
- third-party assets require explicit provenance and license compatibility before inclusion.

### D. Asset provenance and licensing

For every non-procedural asset committed to the repository, record at minimum:

- file path;
- source type: generated / first-party / third-party;
- original source or generation method;
- license/usage status when third-party;
- any material edits.

Recommended file:

```text
docs/assets.md
```

Do not include an asset whose usage rights are unknown.

### E. 2.5D rule

Do not search for a special "2.5D asset format." The 2.5D effect is primarily created by runtime behavior:

```text
2D visual
→ logical depth
→ projection
→ screen position
→ scale
→ fog/opacity
→ ordered draw
```

Ordinary 2D procedural shapes, PNG/WebP, or SVG assets may participate in the 2.5D scene.

### F. Explicit prohibitions

Do not:

- generate or download a unique image for every stone;
- bake the complete saga map into one background image;
- introduce a 3D asset pipeline only to place the distant castle;
- let AI agents add unrelated asset packs without review;
- mix many icon styles;
- make the core infinite path depend on a finite asset list;
- add an asset-management framework for this POC.

## 4.3 Flutter official tooling

Use official Flutter performance tooling for proof:

- profile mode;
- physical Android device;
- DevTools Performance view;
- performance overlay where useful.

Official references:

- https://docs.flutter.dev/perf/ui-performance
- https://docs.flutter.dev/tools/devtools/performance
- https://docs.flutter.dev/testing/build-modes

## 4.4 Conditionally allowed

### vector_math

Allowed only if actual vector/matrix operations reduce code or improve clarity.

Do not add it for simple scalar projection arithmetic.

### Fragment shader

Allowed only as an isolated optional enhancement after all mandatory gates are green.

The core experience must still work when the shader is removed.

## 4.4 Explicitly rejected dependencies for this POC

Do not add without amending this SSOT with evidence:

- Riverpod
- Bloc
- GetIt
- Provider solely for this screen
- Freezed
- GoRouter
- Flame Forge2D
- flutter_scene
- flame_3d
- Unity bridge packages
- Filament wrappers
- generic service locators
- DI frameworks

Reason: no demonstrated need relative to the two-day scope.

## 4.5 Version rule

Do not hardcode a dependency version from memory or from this document.

At implementation start:

1. resolve current compatible stable versions;
2. record them in `pubspec.yaml` and the progress log;
3. confirm official docs match the selected version where material;
4. do not perform opportunistic major upgrades during the POC.

---

# 5. ARCHITECTURE

## 5.1 System flow

```text
User drag
   ↓
SagaScrollPhysics
   ↓
SagaMapState.progress  ← single movement SSOT
   ↓
VisibleNodeWindow
   ↓
SagaPath.nodeAt(index)
   ↓
Logical SagaNode list (bounded)
   ↓
PerspectiveProjector
   ↓
Projected SagaScene
   ↓
Depth-aware renderer
   ↓
Canvas / Flame render lifecycle
```

Flutter UI remains outside this world pipeline:

```text
Flutter app shell
├── top HUD
├── buttons / overlays
├── optional debug controls
└── GameWidget<SagaMapGame>
```

## 5.2 Responsibility boundaries

### `SagaMapGame`

Owns:

- lifecycle orchestration;
- dependency wiring;
- update ordering;
- render invocation;
- no domain math that belongs elsewhere.

Must not become a god class.

### `SagaMapState`

Owns only minimal mutable runtime state.

Initial target:

```dart
final class SagaMapState {
  double progress;
  int currentLevel;
}
```

`progress` is the sole source of truth for movement through the map.

### `SagaScrollPhysics`

Owns:

- drag delta conversion;
- release velocity;
- inertia;
- friction/decay;
- optional clamping only if product behavior requires it.

Produces progression change. It does not render.

### `SagaPath`

Owns:

- deterministic logical position for node index;
- path preset/config variation;
- no screen coordinates;
- no Canvas/Flutter/Flame dependency unless unavoidable.

Primary API target:

```dart
SagaNode nodeAt(int index, {required int currentLevel});
```

### `VisibleNodeWindow`

Owns:

- deriving which integer node indices should currently exist in the scene;
- constant bounded count;
- ahead/behind policy.

It must not append forever.

### `PerspectiveProjector`

Owns pure world-to-screen projection:

- relative depth;
- perspective-like scale;
- screen X;
- screen Y/horizon curve;
- fog factor;
- culling flag where appropriate.

No input physics. No world generation. No HUD.

### `SagaScene`

A small bounded render-ready representation.

It exists to prevent the renderer from owning world generation.

Do not turn it into a generic scene graph.

### `SagaMapPainter` / renderer

Owns:

- far-to-near ordering;
- drawing stones;
- shadows;
- fog application;
- castle rendering;
- visual node states.

It must not mutate map progress.

### Flutter HUD

Owns:

- top counters;
- bottom navigation shell;
- simple buttons;
- debug toggle where appropriate.

Do not redraw ordinary application UI in the game canvas without a measured reason.

---

# 6. DATA MODEL

## 6.1 Node state

```dart
enum SagaNodeState {
  completed,
  current,
  upcoming,
}
```

Do not add overlapping booleans such as:

- `isCompleted`
- `isCurrent`
- `isUpcoming`
- `isActive`
- `isSelected`
- `isLocked`

unless a demonstrated product state requires a distinct concept.

## 6.2 Logical node

Target shape:

```dart
final class SagaNode {
  const SagaNode({
    required this.index,
    required this.x,
    required this.depth,
    required this.state,
  });

  final int index;
  final double x;
  final double depth;
  final SagaNodeState state;
}
```

Keep renderer-specific fields out of this model.

## 6.3 Projected node

A separate small render representation may hold:

- screen position;
- scale;
- fog;
- logical index;
- visual state;
- relative depth.

Do not persist projected data beyond its usefulness.

---

# 7. INFINITE WORLD MODEL

## 7.1 Core invariant

The world is logically unbounded but runtime work is bounded.

Never create all traversed stones.

Never append stones forever.

Never represent the map as an infinite widget list.

## 7.2 Index-based generation

For every integer index `i`, `SagaPath` must deterministically produce the same logical node location.

Initial path formula may use a simple combination of sinusoidal terms, e.g. conceptually:

```text
x(i) = sin(i * a) * A + sin(i * b) * B
```

Exact constants are visual tuning parameters, not architectural state.

Properties required:

- same index → same path position;
- very large index → finite valid values;
- no stored history required;
- no random result changes between frames.

## 7.3 Visible window

Initial target range:

- small number behind current progress;
- approximately 18–30 ahead;
- exact number selected through visual/performance testing.

The visible count must stay bounded after arbitrarily long simulated travel.

## 7.4 Pooling decision

Do not prematurely create a complex object pool.

Preferred order:

1. derive a bounded integer range each frame/update;
2. reuse small structures where profiling supports it;
3. introduce explicit pooling only if allocation evidence justifies it.

The architectural invariant is bounded work, not “must use an object-pool class.”

---

# 8. PROJECTION MODEL

## 8.1 Purpose

Create a convincing 3D depth illusion without a general-purpose 3D engine.

## 8.2 Relative depth

Conceptually:

```text
relativeDepth = node.depth - progress
```

## 8.3 Perspective-like scale

Initial candidate:

```text
scale = focalLength / (focalLength + relativeDepth)
```

This is a starting model, not a sacred equation.

Tune for visual similarity to the reference experience.

## 8.4 Screen X

Conceptually:

```text
screenX = viewportCenterX + worldX * scale
```

## 8.5 Screen Y

Use a tuned monotonic depth curve toward a horizon position.

Requirements:

- far nodes compress toward horizon;
- near nodes move more dramatically;
- no discontinuity during drag;
- visually convincing beats mathematically “pure” perspective.

## 8.6 Fog

Compute a normalized fog factor from depth.

Apply by blending toward background atmosphere and/or reducing contrast/opacity.

Avoid expensive blur until profiling proves it safe.

## 8.7 Culling

Cull nodes that are:

- materially behind the camera/near plane;
- beyond useful visibility/fog;
- invalid/non-finite due to a bug.

Invalid projection must fail safely, never crash the render loop.

---

# 9. CASTLE / HORIZON MODEL

The castle is a distant scene anchor, not a normal saga node.

Requirements:

- remains near horizon;
- moves substantially less than foreground stones;
- participates in atmospheric depth;
- apparent scale increases as relative depth decreases;
- far presentation is more washed out / haze-blended / lower contrast;
- closer presentation reveals stronger color separation, clarity, and available detail;
- default implementation uses one high-quality lightweight asset with distance-aware rendering;
- optional detail overlay or near/far LOD asset may be introduced only if target-device review proves one asset insufficient;
- dynamic blur is not required and must not be added before cheaper atmospheric treatments are exhausted;
- may be simple custom-painted geometry or one lightweight asset;
- must not require a 3D model pipeline.

Fallback hierarchy:

1. simple attractive silhouette asset;
2. procedural/custom painted silhouette;
3. minimal placeholder with strong atmospheric treatment.

Do not block core delivery on castle asset perfection.

---

# 10. INPUT & PHYSICS

## 10.1 Input

Vertical drag controls world progression.

Expected flow:

```text
pointer drag
  ↓
deltaY
  ↓
sensitivity mapping
  ↓
progress delta
```

## 10.2 Release inertia

On release:

- derive/receive velocity;
- continue movement;
- decay velocity by deterministic friction;
- settle cleanly.

Use `dt`-aware update logic.

Do not bind the world to a Flutter `ListView` scroll offset.

## 10.3 Optional snapping

Snapping to a node is optional.

Only add if:

- core continuous motion is already excellent;
- snapping improves the reference experience;
- it does not create a second movement SSOT.

---

# 11. RENDERING

## 11.1 Draw order

Render far-to-near.

Typical order:

1. background gradient/atmosphere;
2. castle/horizon;
3. far nodes;
4. mid nodes;
5. near nodes;
6. current-node accents;
7. world-space effects.

Flutter HUD is composited separately.

## 11.2 Hot-path rules

Avoid in `update`/`render` hot paths unless proven necessary:

- asset decoding;
- JSON parsing;
- unbounded list growth;
- huge sorting operations;
- repeated creation of heavy Paint/Path objects;
- network calls;
- logging every frame;
- large temporary allocations.

## 11.3 Premature optimization ban

Do not add batching, custom shaders, retained scene graphs, ECS extensions, or explicit object pools solely because they sound performant.

Profile first.

---

# 12. DEBUG / ARCHITECTURE PROOF MODE

A toggleable debug overlay is a mandatory POC feature.

Display useful truth, not fake metrics:

```text
Progress:       <actual>
Current index:  <actual>
Visible nodes:  <actual bounded count>
Path preset:    <actual>
Renderer:       2.5D projection
FPS:            <actual available measurement>
```

## 12.1 Projection debug mode

Should visually help explain:

- horizon;
- node index;
- relative depth;
- scale;
- near/mid/far behavior.

Keep it optional and non-invasive.

## 12.2 No fake performance display

Never hardcode `60 FPS`.

If an FPS value is unavailable or unreliable, display nothing or label it appropriately.

---

# 13. EXTENSIBILITY PROOF

The POC must demonstrate one real extension without generic overarchitecture.

Preferred proof: two path presets/configurations.

Example:

```dart
enum SagaPathPreset {
  gentle,
  dramatic,
}
```

Both presets must use the same:

- visible-window mechanism;
- projector;
- renderer;
- interaction physics.

This proves that world generation is separate from rendering.

Do not create a plugin system.

---

# 13.5 AUDIO / SOUND MODEL

Audio is a small presentation/runtime concern, not a gameplay subsystem.

## 13.5.1 Event flow

```text
user action or saga state transition
        ↓
meaningful event/condition
        ↓
small audio trigger
        ↓
flame_audio
        ↓
preloaded SFX or optional loop
```

Initial event mapping:

- node tap/selection → short select SFX;
- transition into completed state → short completion SFX;
- celebration effect starts → optional reward SFX;
- optional ambient loop → only after mandatory gates are green.

## 13.5.2 Ownership rules

- `SagaMapState` remains authoritative for progression/current level.
- Audio reads/reacts; it never mutates map progression.
- A failed sound must not cancel or delay the visual action.
- Keep triggers close to the orchestration point that knows the event occurred.
- Do not create a global event bus for this POC.

## 13.5.3 Performance rules

- preload/cached short presentation SFX;
- avoid allocations or asset loading in the per-frame render path;
- never tie playback frequency to continuous drag updates;
- use pooling only for proven rapid overlapping playback;
- audio must be removable without changing world, projection, or renderer logic.

---

# 14. RECOMMENDED FILE STRUCTURE

Target, not bureaucracy:

```text
lib/
├── main.dart
├── app/
│   └── saga_app.dart
├── saga_map/
│   ├── saga_map_screen.dart
│   ├── saga_map_game.dart
│   ├── domain/
│   │   ├── saga_node.dart
│   │   ├── saga_node_state.dart
│   │   └── saga_map_state.dart
│   ├── world/
│   │   ├── saga_path.dart
│   │   └── visible_node_window.dart
│   ├── navigation/
│   │   └── saga_scroll_physics.dart
│   ├── projection/
│   │   └── perspective_projector.dart
│   ├── rendering/
│   │   ├── saga_scene.dart
│   │   └── saga_map_painter.dart
│   ├── debug/
│   │   └── saga_debug_overlay.dart
│   └── audio/
│       └── saga_audio.dart
└── ui/
    └── saga_hud.dart
```

Target approximately 14–17 meaningful implementation files.

Deviation is allowed only when real code proves a different grouping clearer.

Do not split one concept across files merely to satisfy “clean architecture.”

---

# 15. ANTI-REDUNDANCY RULES — NON-NEGOTIABLE

1. Exactly one movement/progression SSOT: `SagaMapState.progress`.
2. No duplicate `scrollOffset`, `cameraOffset`, `worldOffset`, `mapOffset`, or equivalent mutable progression state.
3. No repository layer.
4. No dependency-injection framework.
5. No service locator.
6. No generic base class without two concrete current use cases.
7. No interface with one implementation unless it protects a proven boundary and the reason is documented.
8. No speculative cross-platform abstraction.
9. No generated boilerplate.
10. No state-management package without demonstrated need.
11. No per-frame unbounded object creation.
12. No endlessly appended stones/components/widgets.
13. No alternate architecture documents.
14. No duplicate progress TODO lists.
15. No “manager”, “service”, “controller”, or “engine” class without a precise owned responsibility.
16. Before adding a class, explain why an existing owner cannot hold the responsibility.
17. Before adding a dependency, explain what maintained code it replaces.
18. Before adding an abstraction, show the real variation it represents.
19. Prefer a pure function over a class when no identity/state is required.
20. No generic audio manager/service/event bus; one small audio owner is the maximum unless real complexity proves otherwise.
21. Audio may react to domain events but must never own or duplicate gameplay state.
20. Prefer deletion when a bonus feature destabilizes the core.

---

## 15.1 Asset anti-redundancy rules

- One procedural stone renderer is preferred over a collection of per-stone raster assets.
- At most a small number of deterministic visual variants may be introduced when they create visible value.
- Shared icons must come from one coherent source/style whenever possible.
- Environment art must remain layered and composable; do not duplicate near-identical full-scene backgrounds.
- Do not create wrapper classes around assets unless runtime behavior demonstrates a concrete need.

# 16. CODE QUALITY RULES

- Use current Dart language features where they improve clarity.
- Keep nullability explicit.
- Avoid `dynamic` except at unavoidable external boundaries.
- Use immutable value objects by default.
- Keep mutable state centralized and minimal.
- Make projection/path logic independently testable.
- Avoid comments that merely restate code.
- Comment rationale, non-obvious math, and tradeoffs.
- Keep methods focused.
- Do not chase arbitrary line-count targets at the cost of clarity.

## 16.1 Approximate code budget

Expected core implementation order of magnitude:

- approximately 800–1,600 purposeful Dart lines, excluding generated/platform boilerplate and tests/docs.

This is an estimate, not a hard gate.

A much larger result triggers mandatory redundancy review.

---

# 17. TEST PLAN

Do not build a huge test suite.

Test high-value invariants.

## 17.1 `SagaPath`

Mandatory:

- [ ] same index returns same logical position
- [ ] very large positive index returns finite valid values
- [ ] negative index returns finite valid values if supported
- [ ] path preset changes intended geometry without changing renderer contract

## 17.2 `VisibleNodeWindow`

Mandatory:

- [ ] visible count remains bounded
- [ ] advancing progress advances integer window
- [ ] no duplicate live indices
- [ ] very large simulated progress remains bounded
- [ ] simulated travel equivalent to at least 1,000,000 nodes does not grow visible count

## 17.3 `PerspectiveProjector`

Mandatory:

- [ ] farther valid node projects smaller than nearer comparable node
- [ ] far nodes trend toward horizon
- [ ] projected outputs remain finite
- [ ] behind-camera/invalid nodes are safely culled

## 17.4 `SagaScrollPhysics`

Mandatory:

- [ ] drag changes progress
- [ ] release inertia continues progress when velocity exists
- [ ] friction decays velocity
- [ ] velocity settles below threshold
- [ ] update behavior is `dt` aware

## 17.5 Optional integration test

Only if time remains:

- launch Saga Map;
- perform deterministic drag;
- verify progress changed and app remains alive.

---

# 18. PERFORMANCE VALIDATION

## 18.1 Evidence rule

Performance claims require evidence.

Do not infer production performance from:

- debug mode;
- emulator alone;
- a visual impression alone.

## 18.2 Mandatory environment

- physical Android device;
- Flutter profile mode;
- chosen presentation scenario.

## 18.3 Mandatory scenario

At minimum:

- continuous high-velocity map traversal for approximately 30 seconds;
- debug overlay confirms visible count remains bounded;
- observe Flutter/DevTools performance evidence;
- record actual device and method.

## 18.4 Required artifact

Create:

```text
docs/performance/results.md
```

Record:

- device model;
- Android version if easily available;
- Flutter version;
- Flame version;
- build mode;
- scenario;
- configured visible-node count;
- observed issues;
- measured findings available from tooling;
- changes made because of evidence;
- unresolved concerns.

Do not fabricate values.

## 18.5 Performance acceptance

Mandatory:

- [ ] no unbounded visible-node growth
- [ ] no obvious persistent jank during normal presentation interaction
- [ ] no crash during sustained traversal
- [ ] profile evidence recorded honestly

Preferred:

- smooth ~60 Hz experience on presentation device where hardware/display support it.

Do not convert “preferred” into a fake guaranteed measurement.

---

# 19. DOCUMENTATION DELIVERABLES

Required repository docs:

```text
AD.md
ARCHITECTURE_DECISIONS.md
README.md
docs/
├── architecture.md
├── assets.md
└── performance/
    └── results.md
```

`ARCHITECTURE_DECISIONS.md` is the single rationale companion and must contain the ADRs, alternatives compared, evidence, rejection logic, tradeoffs, fallbacks, and re-evaluation triggers. Do not create duplicate per-ADR files unless the repository later proves a concrete need.

The rationale companion must remain non-normative: `AD.md` still controls implementation and progress.

---

# 20. TRUE-3D FUTURE MIGRATION TRIGGERS

Do not migrate merely because “3D sounds better.”

Re-evaluate real 3D only if future requirements include several of:

- arbitrary camera rotation;
- true 3D mesh navigation;
- complex occlusion impossible to fake cleanly;
- dynamic 3D lighting;
- rich animated 3D castle/world assets;
- free camera movement;
- physically meaningful depth interactions;
- a large reusable 3D asset pipeline.

At that time, perform fresh package/engine research.

Current POC world/domain contracts should remain as reusable as reasonably possible, but do not build speculative adapters today.

---

# 21. TWO-DAY EXECUTION PLAN

Time blocks are sequencing guidance, not promises.

## DAY 1 — Core architecture + experience

### Wave 0 — Bootstrap and lock

Tasks:

- [ ] create Flutter project or inspect starter repo
- [ ] confirm Android run path
- [ ] record Flutter SDK version
- [ ] resolve compatible current stable Flame version
- [ ] add minimal dependency
- [ ] copy this `AD.md` to repository root
- [ ] create progress log entry
- [ ] create minimal file skeleton only as needed

**Gate D1-G0**

Pass when:

- app launches on Android target;
- dependency resolves;
- this file is root SSOT;
- no speculative architecture added.

### Wave 1 — Domain + infinite world

Tasks:

- [ ] `SagaNodeState`
- [ ] `SagaNode`
- [ ] `SagaMapState`
- [ ] deterministic `SagaPath`
- [ ] `VisibleNodeWindow`
- [ ] unit tests for deterministic and bounded behavior

**Gate D1-G1**

Pass when:

- index generation is deterministic;
- very large index works;
- visible count remains bounded after large simulated travel;
- tests green.

### Wave 2 — Projection + first visible world

Tasks:

- [ ] `PerspectiveProjector`
- [ ] `SagaScene`
- [ ] basic renderer
- [ ] background
- [ ] 20-ish visible projected stones
- [ ] far-to-near draw order

**Gate D1-G2**

Pass when:

- static screenshot clearly reads as depth-rich journey toward horizon;
- near/far scale difference is obvious;
- no infinite allocation model.

### Wave 3 — Interaction

Tasks:

- [ ] drag input
- [ ] progress update
- [ ] inertia
- [ ] friction
- [ ] `dt`-aware update
- [ ] physics tests

**Gate D1-G3 — CRITICAL**

Pass when:

- user can continuously traverse apparently infinite nodes;
- no visible discontinuity at integer window changes;
- interaction feels controllable;
- progress is the only movement SSOT.

If this gate fails, stop bonus work.

### Wave 4 — Core visual depth

Tasks:

- [ ] fog/atmosphere
- [ ] shadows
- [ ] tuned path meander
- [ ] castle anchor
- [ ] node visual states
- [ ] current node emphasis

**Day 1 Exit Gate**

Must pass all:

- [ ] Android runnable
- [ ] convincing depth
- [ ] continuous drag
- [ ] inertia
- [ ] infinite logical progression
- [ ] bounded visible count
- [ ] castle visible
- [ ] no duplicate progression state
- [ ] core tests green

No Day 2 bonus work until this gate is green.

---

## DAY 2 — Architecture proof + performance + polish

### Wave 5 — Debug proof

Tasks:

- [ ] debug overlay
- [ ] actual progress
- [ ] current index
- [ ] actual visible count
- [ ] path preset
- [ ] optional actual FPS source
- [ ] projection debug mode

**Gate D2-G1**

Pass when an interviewer can understand infinite/bounded/projection behavior without opening source code.

### Wave 6 — Extensibility proof

Tasks:

- [ ] second path preset/config
- [ ] same renderer works unchanged
- [ ] simple toggle in debug/demo UI
- [ ] tests prove deterministic behavior

**Gate D2-G2**

Pass when world-generation variation does not require renderer rewrite.

### Wave 7 — Performance evidence

Tasks:

- [ ] physical Android device
- [ ] profile mode
- [ ] sustained traversal scenario
- [ ] DevTools/performance overlay observation
- [ ] record findings
- [ ] fix only evidence-backed bottlenecks

**Gate D2-G3 — CRITICAL**

Pass when:

- profile method documented;
- visible count remains bounded;
- no crash;
- presentation interaction is acceptably smooth;
- no fabricated performance claim.

### Wave 8 — Product polish

- [ ] verify asset provenance/license records for all committed non-procedural assets

Only after D2-G3:

- [ ] simple HUD
- [ ] current/completed/upcoming visual refinement
- [ ] one tap interaction
- [ ] optional current-node animation
- [ ] optional particles
- [ ] minimal select/completion SFX via `flame_audio`
- [ ] optional ambient loop only if all prior gates remain green
- [ ] optional shader experiment

Delete any bonus that destabilizes the core.

### Wave 9 — Submission closure

Tasks:

- [ ] `flutter analyze`
- [ ] tests
- [ ] Android build/run verification
- [ ] README
- [ ] architecture doc
- [ ] rationale companion updated through ADR-010
- [ ] performance results
- [ ] asset provenance doc
- [ ] redundancy review
- [ ] dead code removal
- [ ] TODO audit
- [ ] final demo path rehearsal

**Final Gate**

Must pass:

- [ ] no known critical bug
- [ ] no fake metric
- [ ] no unbounded node growth
- [ ] no duplicate progression SSOT
- [ ] tests green
- [ ] analyzer acceptable
- [ ] physical Android demo verified
- [ ] documentation matches actual code

---

# 22. MULTI-AGENT EXECUTION MODEL

Parallel agents are allowed, but ownership is strict.

## Role A — Architecture Guardian

**Code ownership:** none by default

Responsibilities:

- enforce this AD;
- review duplicate state;
- review dependency additions;
- reject speculative abstractions;
- inspect module-boundary violations;
- keep progress log truthful.

Must not create an alternate architecture.

## Role B — World / Infinity

Owns:

```text
saga_map/domain/
saga_map/world/
```

Responsibilities:

- node model;
- state classification;
- deterministic path;
- visible-window derivation;
- tests.

Must not edit renderer except via agreed contract change.

## Role C — Projection / Rendering

Owns:

```text
saga_map/projection/
saga_map/rendering/
```

Responsibilities:

- projection math;
- scene representation;
- draw order;
- stones;
- atmosphere;
- castle visual.

Must not invent alternate movement state.

## Role D — Input / Physics

Owns:

```text
saga_map/navigation/
```

Responsibilities:

- drag mapping;
- velocity;
- inertia;
- friction;
- tests.

Output affects only canonical progress.

## Role E — UI / Visual Polish

Owns visual polish, Flutter HUD, and approved layered environment/support assets. Must follow ADR-010 and may not introduce unreviewed asset packs.


Owns:

```text
ui/
saga_map_screen.dart
approved assets
```

Responsibilities:

- HUD;
- overlays;
- debug controls shell;
- final visual polish outside core renderer.

Must not reimplement map state in Flutter widget state.

## Role F — Verification / Performance

Owns:

```text
test/
docs/performance/
verification scripts if any
```

Responsibilities:

- analyzer/test verification;
- invariant tests;
- profile procedure;
- evidence recording;
- redundancy findings.

No unrelated feature development.

---

# 23. AGENT DEPENDENCY ORDER

Do not launch all agents blindly.

```text
AD lock
  ↓
Domain contracts + state
  ↓
World model / visible window
  ├──────────────┐
  ▼              ▼
Projection      Input physics
  └──────┬───────┘
         ▼
      Renderer
         ↓
   Debug proof + UI
         ↓
Performance verification
         ↓
Polish / submission closure
```

Parallelism is allowed only when interfaces are already stable enough to avoid duplicate invention.

---

# 24. CHANGE CONTROL

## 24.1 Any agent proposing a new dependency must provide

- capability needed;
- why Flutter/Flame/current code is insufficient;
- exact package;
- maintenance/version evidence;
- integration cost;
- code it replaces;
- fallback/removal path.

No evidence → no dependency.

## 24.2 Any agent proposing a new abstraction must provide

- two real current variations, or
- one demonstrated boundary whose isolation materially reduces risk.

Otherwise reject.

## 24.3 Any agent proposing true 3D must stop

The proposal requires explicit SSOT amendment before implementation.

---

# 25. STOP CONDITIONS

Stop the current feature and return to the last green gate if:

- app no longer runs on Android;
- visible count grows with travel history;
- a second mutable movement SSOT appears;
- projection outputs non-finite values;
- sustained traversal crashes;
- bonus work causes persistent jank;
- merge conflicts reveal duplicated implementations;
- architecture cannot be explained simply;
- package integration consumes disproportionate time;
- documentation no longer matches implementation.

Do not hide a stop condition with more code.

---

# 26. FALLBACK MAP

| Problem | Preferred fallback |
|---|---|
| Flame integration blocks progress | Keep domain/projector and render with Flutter `CustomPainter` |
| Explicit pooling becomes buggy | Derive bounded visible integer range without persistent pool |
| Blur is expensive | Replace with color/alpha fog |
| Castle asset is weak | Procedural silhouette + atmosphere |
| Shader causes instability | Remove shader completely |
| Snapping feels bad | Keep continuous inertial traversal |
| Particles cause jank | Remove particles |
| Debug FPS source is unreliable | Hide FPS; keep truthful bounded-count metrics |
| HUD unfinished | Ship polished full-screen map with minimal controls |
| True-3D temptation appears | Document future trigger; do not migrate during POC |

---

# 27. INTERVIEW DEMO PATH

Rehearse this order:

1. **Show the experience first.**
   - drag through map;
   - show depth;
   - show castle;
   - show node states.

2. **Keep scrolling.**
   - explain logically infinite indexing.

3. **Enable debug overlay.**
   - show current progress/index;
   - show bounded visible-node count.

4. **Enable projection debug.**
   - explain logical world → relative depth → screen projection.

5. **Switch path preset.**
   - prove generator/render separation.

6. **Show architecture diagram.**
   - World → Window → Projection → Scene → Renderer.

7. **Explain package decision.**
   - reuse Flame for lifecycle;
   - custom-build only tiny domain-specific projection/infinite logic.

8. **Show real performance evidence.**
   - physical Android device;
   - profile methodology;
   - honest findings.

9. **Explain future 3D trigger.**
   - not dogmatic;
   - migrate only when product requirements justify it.

---

# 28. README MINIMUM CONTENT

README must include:

- one-paragraph assignment summary;
- how to run Android app;
- chosen architecture in one diagram;
- dependency rationale;
- infinite-world explanation;
- performance validation summary;
- test commands;
- limitations;
- future work;
- link to `ARCHITECTURE_DECISIONS.md`.

Do not write marketing claims unsupported by the implementation.

---

# 29. PROGRESS LEDGER — SINGLE CODING PROGRESS SOURCE OF TRUTH

> This section is the only authoritative progress tracker.
> Do not create `TODO.md`, `PLAN.md`, `STATUS.md`, or competing task ledgers.
> Normal issue trackers/commits may exist, but this remains the project-level implementation truth for the POC.

## Status values

- `NOT_STARTED`
- `IN_PROGRESS`
- `BLOCKED`
- `IMPLEMENTED`
- `VERIFIED`
- `REJECTED`

## Current progress

| Work Item | Owner | Status | Evidence | Blocker / Next |
|---|---|---|---|---|
| AD locked in repository root | Architecture Guardian | NOT_STARTED | — | Copy this file to repo root |
| Android bootstrap verified | — | NOT_STARTED | — | — |
| Flutter/Flame versions recorded | — | NOT_STARTED | — | Resolve at implementation start |
| Domain models | World agent | VERIFIED | Present & unmodified: `lib/saga_map/domain/saga_map_state.dart` (29 lines), `saga_node.dart` (15), `saga_node_state.dart` (1). `git status` shows these files untracked (`??`) with no edits made by this reconciliation (only AD.md changed). Consumed without error by the 13 passing world/projection tests below. | — |
| Deterministic SagaPath | World agent | VERIFIED | Present & unmodified: `lib/saga_map/world/saga_path.dart` (37 lines). `flutter test test/saga_map/world/saga_path_test.dart` → "nodeAt is deterministic — same arguments yield equal results" passed (part of "All tests passed!" 13/13 run, Flutter 3.44.5 stable). | — |
| Bounded VisibleNodeWindow | World agent | VERIFIED | Present & unmodified: `lib/saga_map/world/visible_node_window.dart` (29 lines). `flutter test test/saga_map/world/visible_node_window_test.dart` → bounded-count (small travel + ~1,000,000-equivalent travel), forward-shift, and ascending-no-duplicate index invariants all passed (part of 13/13). | — |
| World invariant tests | World agent | VERIFIED | `flutter test test/saga_map/world/saga_path_test.dart test/saga_map/world/visible_node_window_test.dart` → "All tests passed!" (0 failures). Files present & unmodified: `saga_path_test.dart` (41 lines), `visible_node_window_test.dart` (44 lines). | — |
| PerspectiveProjector | Projection agent | VERIFIED | Present & unmodified: `lib/saga_map/projection/perspective_projector.dart` (100 lines). `flutter test test/saga_map/projection/perspective_projector_test.dart` → farther-depth-smaller-scale, finite-output, camera-cull, and perspective-singularity-cull cases all passed (part of 13/13). | — |
| Projector tests | Projection agent | VERIFIED | `flutter test test/saga_map/projection/perspective_projector_test.dart` → all cases passed within "All tests passed!" 13/13 run (Flutter 3.44.5 stable). File present & unmodified: `perspective_projector_test.dart` (65 lines). | — |
| Basic renderer | Projection agent | NOT_STARTED | — | — |
| Drag physics | Input agent | NOT_STARTED | — | — |
| Inertia/friction | Input agent | NOT_STARTED | — | — |
| Physics tests | Input agent | NOT_STARTED | — | — |
| Infinite traversal integrated | Integration | NOT_STARTED | — | — |
| Fog/depth tuning | Projection agent | NOT_STARTED | — | — |
| Castle horizon | Projection/UI | NOT_STARTED | — | — |
| Layered environment assets | UI/Visual agent | NOT_STARTED | — | Follow ADR-010; keep layers composable |
| Asset provenance record | UI/Visual agent | NOT_STARTED | — | Document all non-procedural assets |
| Node states visuals | Projection/UI | NOT_STARTED | — | — |
| Day 1 critical gate | Architecture Guardian | NOT_STARTED | — | — |
| Debug overlay | UI/Verification | NOT_STARTED | — | — |
| Projection debug mode | Projection/Verification | NOT_STARTED | — | — |
| Second path preset | World agent | NOT_STARTED | — | — |
| Physical Android profile run | Verification | NOT_STARTED | — | — |
| Performance results doc | Verification | NOT_STARTED | — | — |
| HUD polish | UI agent | NOT_STARTED | — | — |
| Decision rationale companion synced | Architecture Guardian | NOT_STARTED | `ARCHITECTURE_DECISIONS.md` | Copy to repo root and keep aligned with locked decisions |
| README | Integration | NOT_STARTED | — | — |
| Final redundancy audit | Architecture Guardian | NOT_STARTED | — | — |
| Final analyzer/tests | Verification | NOT_STARTED | — | — |
| Final Android demo verification | Verification | NOT_STARTED | — | — |

## Progress update rule

When changing a row to `VERIFIED`, add concrete evidence, for example:

- test command and result;
- physical device/model and run mode;
- screenshot path;
- commit hash;
- profiler result path;
- exact gate checklist.

`IMPLEMENTED` is not the same as `VERIFIED`.

---

# 30. FINAL ACCEPTANCE CHECKLIST

## Core experience

- [ ] depth-rich saga map
- [ ] continuous drag
- [ ] inertia/friction
- [ ] infinite logical stones
- [ ] bounded visible runtime set
- [ ] castle horizon
- [ ] node states

## Architecture

- [ ] one progress SSOT
- [ ] world generation separated from projection
- [ ] projection separated from rendering
- [ ] Flutter UI separated from world rendering
- [ ] no unproven abstraction explosion
- [ ] no redundant state

## Proof

- [ ] debug overlay
- [ ] bounded-count demonstration
- [ ] projection debug mode
- [ ] second path preset or equivalent real extension proof

## Quality

- [ ] core unit tests green
- [ ] analyzer acceptable
- [ ] dead code removed
- [ ] no fake metrics
- [ ] no critical TODO

## Performance

- [ ] physical Android profile mode
- [ ] sustained traversal verified
- [ ] results documented
- [ ] no unbounded growth
- [ ] no crash

## Documentation

- [ ] non-procedural asset provenance/license status documented
- [ ] repeated saga geometry is procedural/reused rather than per-node raster duplication

- [ ] README
- [ ] `ARCHITECTURE_DECISIONS.md` current
- [ ] architecture doc
- [ ] `ARCHITECTURE_DECISIONS.md` current and aligned with locked decisions
- [ ] performance results
- [ ] asset provenance doc
- [ ] AD progress ledger current

---

# 31. FIRST EXECUTION COMMAND FOR A CODING AGENT

Use this instruction after placing this file at repository root:

> Read `AD.md` in full and treat it as the single authoritative implementation and progress source of truth. Read `ARCHITECTURE_DECISIONS.md` only for rationale and tradeoff context; it is non-normative and must not be used to reinterpret LOCKED decisions. Inspect the repository before changing anything. Begin at the earliest incomplete execution wave. Do not create a competing plan, TODO file, status file, architecture, or progress tracker. Respect strict module ownership, one progression SSOT, anti-redundancy rules, gates, stop conditions, and evidence requirements. Update the `AD.md` Progress Ledger as work is implemented and verified. Continue through safe unblocked tasks; stop only for a genuine blocker, a failed critical gate, or a decision that requires amending a LOCKED item.

---

# 32. FINAL PRINCIPLE

The POC is not trying to prove that the largest architecture can be built in two days.

It is trying to prove that the right architecture was chosen deliberately:

```text
small logical world model
        +
deterministic infinity
        +
bounded runtime work
        +
custom depth projection
        +
reused lifecycle tooling
        +
real Android performance evidence
        =
credible, explainable Saga Map foundation
```

When uncertain, optimize for:

1. core experience;
2. correctness;
3. bounded behavior;
4. explainability;
5. measured performance;
6. future optionality;
7. fewer moving parts.

