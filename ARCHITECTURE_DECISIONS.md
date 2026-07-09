# Saga Map Flutter POC — Architecture Decisions, Alternatives & Tradeoffs

> **Status:** Decision-rationale companion; non-normative
> **Normative implementation SSOT:** `AD.md`
> **Target:** 2-day interview POC
> **Platform:** Android presentation target
> **Checked:** 2026-07-08

---

# 0. PURPOSE AND READING RULE

This file explains **why** the architecture in `AD.md` was chosen, **what alternatives were compared**, **what evidence supports the choice**, and **when a locked decision should be reconsidered**.

This file is intentionally separate so coding agents are not encouraged to redesign the system while implementing it.

Rules:

1. `AD.md` is the authoritative implementation and progress source of truth.
2. This file is context and rationale only.
3. A coding agent must not reinterpret a LOCKED decision because an alternative appears here.
4. If implementation evidence invalidates a decision, stop and propose an explicit amendment to `AD.md`.
5. Do not duplicate coding progress here.
6. Do not turn rejected alternatives into dependencies without a documented decision change.

---

# 1. DECISION CONTEXT

## Assignment essence

The required experience is a Flutter saga map whose core is:

- scrolling through a three-dimensional-feeling map;
- apparently infinite stones/nodes;
- a castle on the horizon;
- smooth interaction and performance.

The remaining demo details are bonus scope.

## Project constraints

| Constraint | Consequence |
|---|---|
| 2-day POC | High setup-risk technologies are penalized |
| Android presentation | Physical-device proof can focus on one platform |
| Flutter-forward | Flutter ecosystem choices should be preferred where fit |
| Packages recommended | Reuse proven lifecycle/tooling rather than rebuild everything |
| Explainability required | Avoid opaque or oversized architecture |
| AI/multi-agent development | Strong SSOT and ownership rules are mandatory |
| Only demo video supplied | No production 3D asset pipeline should be assumed |
| Future work should be easy | Domain/world logic should not be fused to one renderer |

## North Star

> Build a small, visually convincing, measurable, explainable architecture POC that demonstrates deliberate engineering judgment and leaves credible extension paths.

---

# 2. OPTION SET CONSIDERED

| Option | Description | Strength | Main concern | Decision |
|---|---|---|---|---|
| Pure Flutter widget tree | Many positioned/transformed widgets | Familiar Flutter development | Render control and large moving widget tree complexity | Rejected as primary renderer |
| Pure Flutter `CustomPainter` | Custom canvas loop without Flame | Minimal dependency, direct control | Must own more lifecycle/input/effects plumbing | Valid fallback |
| **Flutter + Flame + custom 2.5D** | Flame lifecycle; small custom world/projection/rendering | Best balance of control, speed, explainability | Requires custom projection math | **Selected** |
| `flutter_scene` | True 3D scene package over Flutter GPU | Real 3D scene capabilities | Package states early preview; Flutter GPU dependency | Rejected from critical path |
| `flame_3d` | Experimental 3D support in Flame | Familiar Flame direction, true 3D exploration | Explicitly experimental | Rejected from critical path |
| Unity bridge | Embed dedicated game engine | Mature full 3D ecosystem | Bridge/setup complexity; weak Flutter-forward story | Rejected |
| Filament/native 3D bridge | Native real-time 3D renderer | Strong real 3D capabilities | Integration and platform complexity | Rejected |
| Custom Flutter GPU renderer | Low-level custom GPU rendering | Maximum control | Very high implementation risk for 2-day POC | Rejected |

---

<a id="adr-001"></a>
# ADR-001 — Flutter + Flame Lifecycle, Custom 2.5D Projection

## Decision

Use:

- Flutter for the application shell and ordinary HUD/UI;
- Flame for the real-time game/update/render lifecycle and optional effects/debug support;
- a small custom 2.5D projection layer for the saga world.

## Why selected

The required visual can be represented as logical nodes with horizontal position and depth, then projected to screen position, scale, fog, and draw order. This avoids the setup and asset-pipeline cost of a general 3D engine while retaining a convincing depth-rich result.

Flame provides a central real-time game loop through `FlameGame`; its official docs describe that object as owning the continuous update/render loop. Flame also documents performance guidance and FPS/debug components. This means the POC can reuse lifecycle infrastructure rather than inventing another mini-engine.

## Compared with

### Pure Flutter widgets

**Why not selected:**

- a large moving map expressed as a widget tree risks mixing application layout with world rendering;
- projection and depth ordering are more naturally controlled in a render pass;
- it encourages per-node widget state and rebuild concerns that the POC does not need.

**When it could win:**

- very small static map;
- accessibility/semantics on every node is the dominant requirement;
- no continuous world-style movement.

### Pure `CustomPainter`

**Why not selected as default:**

It is technically viable and remains the primary fallback. However, Flame already provides real-time lifecycle infrastructure and optional debugging/effect capabilities, so reusing it is reasonable under a package-friendly brief.

**Why it remains a fallback:**

If Flame integration itself becomes a blocker, the domain/path/projection design should still work with a direct Flutter painter.

### True 3D packages

Not selected because the 2-day POC does not require arbitrary camera rotation, mesh-heavy scenes, lighting, PBR materials, or a full 3D asset pipeline.

## Benefits

- small custom math surface;
- highly explainable;
- direct visual tuning to the reference;
- bounded render workload;
- no 3D asset dependency;
- future renderer replacement remains possible if world logic stays separate.

## Costs / risks

- custom projection must be tuned by eye;
- it is not a general 3D world;
- future arbitrary camera movement would likely require a different renderer.

## Re-evaluate when

Reconsider true 3D if any of these become mandatory:

- arbitrary 3-axis camera movement;
- mesh-based terrain;
- dynamic lighting/shadows as product requirements;
- 3D character navigation;
- glTF-heavy content pipeline;
- occlusion and depth-buffer behavior beyond simple ordered layers.

## Evidence

- Flame `FlameGame` official lifecycle documentation.
- Flame official performance guidance.
- Flame official debug/FPS documentation.

---

<a id="adr-002"></a>
# ADR-002 — Infinite Logical Indexing + Bounded Visible Window

## Decision

Represent the path as a deterministic function of integer node index and derive only a bounded visible range around current progress.

## Why selected

The assignment asks for infinite stones, but “infinite” is a product illusion, not a requirement to allocate infinite objects.

A deterministic function:

```text
index → logical node position/state
```

allows any node to be reconstructed without storing traversal history. A visible window:

```text
current region → bounded integer range
```

keeps runtime work stable as logical progress grows.

## Compared with

### Append nodes forever

**Rejected because:** memory and object count grow with traversal duration.

### Pre-generate a huge list

**Rejected because:** arbitrary cap, unnecessary startup/memory cost, still not genuinely unbounded.

### Infinite Flutter list

**Rejected because:** the map is a world/projection problem, not a conventional linear list; depth placement and draw ordering are custom.

### Chunked world persistence

**Deferred because:** useful for a production authored world, but unnecessary for a procedural POC with no backend/persistence requirement.

## Benefits

- conceptually infinite;
- bounded scene complexity;
- deterministic tests;
- easy large-index proof;
- no stored history.

## Risk

Poor path formulas can look repetitive.

## Mitigation

Use two or more deterministic frequency components or a seeded deterministic strategy while keeping the API index-based.

## Re-evaluate when

- node content becomes authored rather than procedural;
- server-driven levels require persistence;
- branching paths appear;
- users can edit/reorder the map.

---

<a id="adr-003"></a>
# ADR-003 — One Progression Value as Movement SSOT

## Decision

`SagaMapState.progress` is the sole authoritative movement position through the map.

Velocity may exist in the physics controller, but visual/world position must derive from `progress`.

## Why selected

Interactive camera systems often accumulate redundant mutable values such as:

- scroll offset;
- camera offset;
- world translation;
- node offset;
- selected index progress.

Multiple authoritative movement values create drift, synchronization bugs, and AI-generated redundancy.

## Compared with

### Separate camera and scroll state

Rejected because there is only one movement axis/experience in this POC. Separate authorities provide no demonstrated value.

### Flutter `ScrollController` as source of truth

Rejected because the world is not a Flutter list and the renderer should not depend on widget scroll semantics.

## Benefits

- easy reasoning;
- easy tests;
- deterministic visible-window derivation;
- fewer synchronization bugs.

## Re-evaluate when

- free camera exploration becomes independent of saga progression;
- multiple viewports/cameras are introduced;
- cinematic camera movement must temporarily detach from user progression.

---

<a id="adr-004"></a>
# ADR-004 — Flutter Owns App UI; Map Engine Owns World Rendering

## Decision

Use Flutter widgets for:

- top HUD;
- bottom navigation;
- dialogs/buttons;
- ordinary overlays.

Use the map renderer for:

- stones;
- horizon/castle scene;
- depth/fog;
- world-linked effects.

## Why selected

Flutter is already optimized for application UI, while the saga world requires continuous projection and ordered rendering. Keeping those concerns separate avoids reimplementing ordinary UI inside a canvas and avoids making the widget tree own world simulation.

## Compared with

### Everything in Flame/canvas

Rejected because ordinary UI becomes harder to maintain and less idiomatic without a demonstrated rendering need.

### Everything in Flutter widgets

Rejected because the moving projected world becomes mixed with app layout/rebuild behavior.

## Benefits

- clear ownership;
- easy future product UI work;
- easier interview explanation;
- fewer custom controls.

## Re-evaluate when

A HUD element must participate directly in world-space rendering or needs frame-synchronized game effects that justify moving it into the engine layer.

---

<a id="adr-005"></a>
# ADR-005 — Physical Android Profile-Mode Performance Evidence

## Decision

Performance claims require a physical Android device and Flutter profile-mode evidence.

## Why selected

Flutter’s official performance documentation explicitly guides developers to connect a physical device, run in profile mode, launch DevTools, and inspect performance. DevTools provides frame-by-frame performance analysis.

Therefore:

- debug-mode smoothness is not accepted as proof;
- emulator-only results are not accepted as proof;
- “60 FPS” must not be written without measured evidence.

## Compared with

### Debug mode

Rejected as performance evidence because development instrumentation changes runtime characteristics.

### Emulator only

Rejected as final proof because it does not represent the chosen physical presentation device.

### FPS counter only

Insufficient alone. Useful as a live signal, but DevTools/profile evidence is stronger for diagnosis and documentation.

## Benefits

- credible interview proof;
- catches real raster/UI jank;
- supports evidence-driven optimization.

## Re-evaluate when

Never for the final POC claim. Additional benchmark automation may supplement it, not replace it.

---

<a id="adr-006"></a>
# ADR-006 — True-3D Packages Excluded from the Critical Path

## Decision

Do not use `flutter_scene`, `flame_3d`, Unity bridges, Filament wrappers, or a custom Flutter GPU renderer in the critical path of this two-day POC.

## Why selected

### `flutter_scene`

Current package documentation describes it as an **early preview**, says things may break, and states that it relies on Flutter GPU, which it also describes as preview-state. That is too much critical-path risk for a two-day interview POC.

### `flame_3d`

Current package documentation explicitly calls it an **experimental implementation of 3D support for Flame**. It is interesting for future exploration, not the safest delivery foundation here.

### Unity / native 3D bridges

They add engine embedding and integration boundaries without a demonstrated requirement for general 3D features. They also weaken the Flutter-forward architecture story.

### Custom Flutter GPU

Maximum control, but far too much low-level implementation risk for the delivery window.

## Compared with selected 2.5D

| Criterion | Custom 2.5D | True 3D critical path |
|---|---|---|
| 2-day setup risk | Lower | Higher |
| Explainability | High | Medium/low depending on package |
| Asset pipeline need | Minimal | Often higher |
| Required visual fit | Strong | Strong |
| Arbitrary 3D capability | Limited | Strong |
| Current need for arbitrary 3D | No | — |

## Re-evaluate when

The production roadmap demonstrates requirements listed under ADR-001’s re-evaluation triggers.

---

<a id="adr-007"></a>
# ADR-007 — Bounded Derived Window Before Explicit Object Pooling

## Decision

Start with a bounded visible index range. Add explicit pooling only if profiling shows allocation pressure or churn worth fixing.

## Why selected

The real invariant is:

> runtime work does not grow with logical travel distance.

An object pool is an optimization mechanism, not the requirement itself. Adding pool bookkeeping before measurement would increase code and explanation cost.

Flame’s performance documentation discusses avoiding common performance pitfalls; that supports profiling and targeted optimization rather than assuming every small bounded scene needs pooling.

## Compared with

### Mandatory pool from day one

Rejected because:

- more lifecycle bookkeeping;
- more mutable state;
- harder debugging;
- no evidence yet that ~20–30 visible nodes need it.

### Unbounded allocation

Rejected because work must remain bounded.

## Re-evaluate when

Profile/DevTools evidence shows:

- meaningful allocation churn;
- GC-related frame issues;
- expensive object reconstruction in the hot path.

---

<a id="adr-008"></a>
# ADR-008 — Minimal Dependency Set; Add Packages Only for Demonstrated Need

## Decision

Core dependency posture:

- Flutter SDK;
- Flame;
- `vector_math` only if it makes real projection code clearer/smaller;
- optional shader/effect additions only after mandatory gates.

Do not add state-management, routing, DI, immutable-codegen, physics, or 3D packages without a demonstrated requirement.

## Why selected

This is a one-screen two-day POC. Every dependency adds:

- API surface;
- setup/version risk;
- concepts the candidate must explain;
- possible AI-generated boilerplate.

Packages should earn their presence by removing meaningful work or risk.

## Compared with

### Riverpod / Bloc / Provider

Rejected because no cross-feature application-state problem has been demonstrated.

### GetIt / DI framework

Rejected because a tiny composition root can wire the small module set directly.

### GoRouter

Rejected because one primary screen does not justify a routing package.

### Freezed

Rejected because the small model set does not justify code generation overhead.

### Forge2D

Rejected because the required inertia/friction behavior is simple 1D motion, not rigid-body physics.

## Re-evaluate when

A real requirement emerges that cannot remain simple without the package.

---

<a id="adr-009"></a>
# ADR-009 — Minimal Event-Driven Audio via `flame_audio`

## Decision

Use `flame_audio` for the POC's small audio surface:

- node select/tap SFX;
- completion/checkmark SFX;
- optional celebration SFX;
- optional ambient/background loop only after core delivery gates are green.

Audio reacts to meaningful map events. It does not own gameplay state, progression, selection truth, or completion truth.

## Why selected

The project already uses Flame for the real-time runtime boundary. Flame documents `flame_audio` as its audio bridge, backed by `audioplayers`, and supports ordinary playback, looping/background music, caching, and `AudioPool` for low-latency repeated/overlapping local SFX.

For this two-day POC, that provides the required capability without designing a custom audio engine.

## Compared with

### Direct `audioplayers`

Viable, and it is the underlying capability used by `flame_audio`. Rejected as the default because the selected app already uses Flame and the bridge gives a more coherent integration surface for this POC.

Reconsider if Flame is removed from the project.

### Other general Flutter audio packages

Not selected because no capability gap has been demonstrated. Adding another audio stack would increase package surface and explanation burden without a proven POC benefit.

### Custom audio engine / generic `AudioManager`

Rejected. The POC has only a handful of event-driven sounds. A custom engine, event bus, mixer abstraction, or multi-backend interface would be speculative architecture.

### No sound at all

Valid fallback and preferable to destabilizing the core. Not selected as the primary plan because a few well-timed SFX can improve perceived responsiveness and demonstrate a clean future interaction boundary at low scope.

## Usage rules

- Preload/cache short presentation SFX before they are needed.
- Use `AudioPool` only when one short effect genuinely fires rapidly or overlaps and profiling/behavior justifies it.
- Do not play sound on every drag update or animation frame.
- A playback failure must not block, cancel, or delay the visual/gameplay event.
- Ambient/background looping is optional and lower priority than interaction SFX.
- Audio is removable without changes to the world model, projector, or renderer.

## Benefits

- Small coherent dependency surface.
- Uses an official Flame bridge.
- Supports simultaneous game SFX use cases.
- Clear extension path for BGM/ambient audio.
- Easy to explain and easy to remove.

## Costs / risks

- Adds another package and audio assets.
- Platform audio behavior can vary and must be tested on the presentation Android device.
- Excessive triggering can create noise or resource pressure.
- Background/ambient audio adds lifecycle concerns that are unnecessary for the core map.

## Re-evaluate when

- Flame is removed;
- production audio requires mixing buses, ducking, streaming, advanced spatial audio, or a larger content pipeline;
- platform-specific lifecycle behavior becomes a real requirement;
- measured repeated SFX latency requires a more deliberate pooling strategy.

## Evidence

- Flame Audio docs: https://docs.flame-engine.org/latest/bridge_packages/flame_audio/audio.html
- Flame AudioPool docs: https://docs.flame-engine.org/latest/bridge_packages/flame_audio/audio_pool.html
- Flame BGM docs: https://docs.flame-engine.org/latest/bridge_packages/flame_audio/bgm.html
- pub.dev package: https://pub.dev/packages/flame_audio

---

<a id="adr-010"></a>
# ADR-010 — Hybrid Asset Strategy by Runtime Responsibility

## Decision

Use three asset sources intentionally:

1. **Procedural/code-generated** for repeated world geometry and depth-reactive effects.
2. **Generated or manually illustrated layered art** for unique signature atmospheric elements.
3. **Curated licensed existing assets** for generic supporting UI/content where reuse is faster and stylistically coherent.

The selected default mapping is:

| Asset / visual | Selected source |
|---|---|
| Stones/platforms | Procedural renderer |
| Stone shadows | Procedural renderer |
| Current/progress rings | Flutter/vector/procedural |
| Fog/horizon fade | Procedural/runtime effect |
| Particles | Flame/procedural |
| Distant castle | Generated or manually illustrated layered PNG/WebP |
| Far landscape/cloud layers | Generated or manually illustrated layered assets |
| Generic hearts/coins/gems/gifts/trophies | Flutter/vector or curated coherent licensed set |

## Why selected

The POC has an infinite logical path but no supplied production asset library. Asset choice therefore has to support both speed and runtime behavior.

Repeated stones are poor candidates for one-off downloaded/generated files because they must react continuously to:

- projection scale;
- depth/fog;
- node state;
- theme/color changes;
- an unbounded logical index range.

Unique horizon art has the opposite characteristics: it is visually important, mostly static, and does not need per-node procedural variation. A small layered raster asset is therefore cheaper and easier to polish than building a 3D castle pipeline.

However, "mostly static asset" does **not** mean "visually identical at every distance." Signature environment art should participate in the scene's depth model. The renderer should derive apparent scale, haze/fog blending, opacity, color intensity, contrast-like treatment, and optional detail visibility from relative depth. This creates the intended effect that a far castle is pale and indistinct while a closer castle becomes larger, more colorful, clearer, and richer in visible detail.

Generic HUD symbols are commodity visuals. Reusing a coherent existing vector/icon source is usually more efficient than individually generating them.

## Compared with

### One downloaded asset pack for everything

**Rejected because:**

- unlikely to match all visual responsibilities;
- repeated world geometry becomes coupled to finite art files;
- hero art and generic icons often have different style needs;
- searching for a perfect pack can consume a large fraction of the two-day window.

**When it could win:**

- company supplies a complete coherent production art kit;
- an existing pack matches the reference closely and has clear licensing.

### AI-generate every object individually

**Rejected because:**

- style inconsistency;
- unnecessary asset count;
- poor deterministic continuity;
- hard future theming;
- more repository noise;
- repeated stones would still need depth/state behavior in code.

### Procedural everything

**Rejected because:**

- a signature castle and atmospheric background can cost disproportionate time to hand-draw well;
- procedural-only purity does not improve the North Star;
- unique art can be safely isolated from gameplay logic.

### One baked full-scene background

**Rejected because:**

- destroys independent parallax control;
- makes the castle/haze/background inseparable;
- weakens future art replacement;
- risks making the moving world feel like an overlay on a screenshot.

### Real 3D asset pipeline

**Rejected because:**

- no supplied 3D assets;
- no requirement for mesh-heavy interaction;
- glTF/import/material/lighting setup adds critical-path complexity;
- the distant castle does not justify a full 3D pipeline.

### Search specifically for "2.5D assets"

**Rejected as a requirement because:**

2.5D is primarily the rendering model, not a special file format. Ordinary 2D procedural shapes, PNG/WebP, and SVG visuals can be projected with logical depth, scale, fog, and ordered drawing.


## Distance-aware signature asset policy

### Decision

For unique environment assets such as the castle, use a staged depth-aware strategy:

1. Start with one high-quality source asset.
2. Project its size from relative depth.
3. Blend toward atmospheric color/fog when far.
4. Reduce far-distance opacity/contrast/color intensity and restore them progressively as the asset approaches.
5. Add a second detail overlay or near/far LOD asset only when target-device review proves the single asset insufficient.

Conceptually:

```text
far
→ smaller
→ more haze
→ more gray/blue wash
→ lower contrast
→ less visible detail

near
→ larger
→ less haze
→ stronger color
→ stronger contrast
→ more visible detail
```

### Compared with

#### One unchanged raster asset at all depths

**Rejected because:**

- scale alone often looks like a sticker moving on top of the scene;
- does not reproduce atmospheric perspective;
- weakens the sense of approach and discovery.

#### Multiple independent images for many distance bands

**Rejected as the default because:**

- unnecessary asset count;
- transition complexity;
- style/alignment mismatch risk;
- more memory and authoring work than the two-day POC justifies.

**Allowed when:**

- one high-resolution asset visibly breaks down when near;
- the art direction intentionally reveals new authored details;
- a second LOD/detail layer measurably improves the target-device result.

#### Dynamic blur as the primary depth effect

**Rejected as the default because:**

- can be more expensive;
- often unnecessary once haze, tint, opacity, and contrast treatment are tuned;
- increases performance risk in a graphics-heavy POC.

**Fallback order:**

1. scale;
2. atmospheric fog/haze blend;
3. opacity/tint/color-intensity treatment;
4. optional detail overlay/LOD;
5. blur only if still needed and profile-mode evidence permits it.

### Why this is architecture-relevant

This behavior belongs in rendering/projection presentation logic, not in gameplay state and not inside the asset file itself. Keeping it depth-driven preserves:

- one logical world model;
- replaceable art;
- consistent approach behavior;
- future migration to richer renderers;
- straightforward performance fallbacks.

### Re-evaluate when

- the castle becomes a close-up interactive destination;
- arbitrary camera rotation exposes flatness;
- authored world themes require distinct LOD sets;
- production art direction requires mesh lighting/material response.

## Benefits

- supports infinite-world behavior without infinite assets;
- keeps unique visuals polishable;
- preserves runtime control of depth/parallax;
- reduces dependency and repository noise;
- keeps future art replacement straightforward;
- easy to explain in interview.

## Costs / risks

- generated hero art may not perfectly match the reference;
- mixing sources can create visual inconsistency;
- third-party assets introduce licensing/provenance obligations;
- raster layers need appropriate resolution testing on the target device.

## Mitigations

- lock a small visual direction before generating/downloading assets;
- keep environment art in separate composable layers;
- use one coherent icon source/style;
- document provenance for every committed non-procedural asset;
- reject assets with unknown usage rights;
- verify the final look on the Android presentation device.

## Re-evaluate when

- the company supplies official art assets;
- production requires authored themed worlds;
- art direction demands mesh-based lighting or camera movement;
- a dedicated artist creates a formal pipeline;
- localization/remote content requires dynamic asset delivery.

## Implementation consequence

The architecture should keep logical world state independent from visual asset choice:

```text
logical node/index/state
→ projection/depth
→ renderer chooses procedural shape or approved visual
```

The castle/background remain presentation assets and must not own gameplay progression.

# 3. PACKAGE AND TOOL DECISION MAP

| Capability | Selected | Alternatives considered | Why selected | Trigger to reconsider |
|---|---|---|---|---|
| App framework | Flutter | Native Android, Unity shell | Assignment target and Flutter-forward requirement | Never for this POC |
| Real-time lifecycle | Flame | Manual ticker/painter loop | Reuses documented game loop and debug/effect capabilities | Flame becomes integration blocker |
| World model | Custom deterministic index function | Stored list, chunks, server data | Infinite illusion with bounded state | Authored/server-driven world |
| Projection | Custom 2.5D | `flutter_scene`, `flame_3d`, Flutter GPU | Lowest risk that still matches visual requirement | Arbitrary 3D requirements |
| App UI | Flutter widgets | Canvas/Flame HUD | Idiomatic maintainable app UI | World-space HUD requirement |
| Performance proof | Flutter profile mode + DevTools | Debug FPS only, emulator | Official evidence path | Supplement only, do not remove |
| FPS live signal | Flame `FpsComponent` optional | Custom counter | Existing documented capability | If no Flame debug integration used |
| Vector math | Conditional `vector_math` | Scalar Dart math | Only if clarity improves | Remove if unused |
| Physics | Small custom 1D inertia | Forge2D | Requirement is simple drag/decay | Real collision/rigid-body needs |
| Effects | Flame particles optional | Custom particles, shader-only | Existing capability after core gate | Performance or visual mismatch |
| Audio | `flame_audio` | Direct `audioplayers`, other Flutter audio packages, custom engine, none | Official Flame bridge; enough for small event-driven SFX/BGM | Flame removed or production audio needs expand |
| Asset pipeline | Hybrid: procedural + generated layered art + curated licensed support assets | All-downloaded, all-generated, all-procedural, baked background, full 3D pipeline | Matches source strategy to runtime responsibility; signature art is depth-aware and may escalate to LOD only when needed | Official art kit, close-up authored destinations, or mesh-heavy product requirements |

---

# 4. REJECTED-OPTION LOG

| Option | Why rejected now | Not a claim that it is bad | Future relevance |
|---|---|---|---|
| `flutter_scene` | Early-preview warning + Flutter GPU preview dependency increase delivery risk | Yes | Revisit for production true-3D needs |
| `flame_3d` | Explicitly experimental | Yes | Revisit as ecosystem matures |
| Unity bridge | Over-sized integration boundary for Flutter-forward 2-day POC | Yes | Dedicated 3D product/game |
| Filament wrapper | Native bridge and scene complexity not justified | Yes | High-end Android-specific 3D |
| Custom Flutter GPU renderer | Too much low-level work | Yes | Long-horizon renderer R&D |
| Widget-per-stone | Wrong ownership model for projected moving world | Yes | Tiny/static map |
| Infinite append list | Runtime work grows with traversal | No | None for this requirement |
| Mandatory object pool | Premature optimization without profile evidence | Yes | Add if profiling proves need |
| Riverpod/Bloc | No demonstrated state-management problem | Yes | Larger multi-feature app |
| DI framework | Composition graph too small | Yes | Large modular product |
| Forge2D | Rigid-body engine unnecessary for 1D inertia | Yes | Real physics/collision requirements |
| Custom audio engine / generic AudioManager | Handful of POC sounds do not justify a subsystem | Yes | Advanced production audio requirements |

| AI-generate every stone/object | Inconsistent, redundant, poor fit for infinite procedural world | Yes | Use generated art only for isolated signature visuals |
| One baked full-scene background | Removes independent parallax/composition control | Yes | Static mock only; not selected POC |
| Full 3D asset pipeline for castle/map | Disproportionate setup risk with no supplied 3D assets | Yes | Reconsider for mesh-heavy requirements |

---

# 5. EVIDENCE AND SOURCE REGISTER

The implementation should re-check package versions at start. The architectural evidence below was checked on 2026-07-08.

| Evidence | What it supports | Source |
|---|---|---|
| `FlameGame` owns the central game loop/update-render cycle | Reuse Flame lifecycle | https://docs.flame-engine.org/latest/flame/game.html |
| Flame publishes performance guidance | Evidence-driven optimization | https://docs.flame-engine.org/latest/flame/other/performance.html |
| Flame documents `FpsComponent` / `FpsTextComponent` | Optional live FPS signal | https://docs.flame-engine.org/latest/flame/other/debug.html |
| Flutter performance flow says physical device + profile mode + DevTools | Mandatory performance proof | https://docs.flutter.dev/perf/ui-performance |
| DevTools Performance view supports frame investigation | Performance diagnosis | https://docs.flutter.dev/tools/devtools/performance |
| `flutter_scene` says early preview and relies on preview Flutter GPU | Exclude from critical path | https://pub.dev/packages/flutter_scene |
| `flame_3d` describes itself as experimental 3D support | Exclude from critical path | https://pub.dev/packages/flame_3d |
| Flame documents `flame_audio` as an audio bridge using `audioplayers` | Select coherent small audio integration | https://docs.flame-engine.org/latest/bridge_packages/flame_audio/audio.html |
| Flame documents `AudioPool` as preloaded players for low-delay repeated/overlapping local SFX | Pool only for proven rapid SFX use | https://docs.flame-engine.org/latest/bridge_packages/flame_audio/audio_pool.html |
| `flame_audio` package is published by flame-engine.org and supports game audio/BGM/SFX | Package provenance and capability | https://pub.dev/packages/flame_audio |

---

# 6. RESEARCH-TO-ARCHITECTURE TRACEABILITY

| Architecture decision | Requirement | Alternatives researched | Selected | Evidence basis | Why not alternatives |
|---|---|---|---|---|---|
| Real-time loop | Smooth continuous movement | Manual Flutter loop, Flame | Flame | Official Flame lifecycle docs | Avoid rebuilding lifecycle plumbing |
| Depth rendering | 3D-feeling saga map | Widgets, painter, Flame+2.5D, `flutter_scene`, `flame_3d`, bridges, GPU | Flame + custom 2.5D | Required visual can be depth-projected; true-3D options carry extra risk | General 3D not required by POC |
| Infinite nodes | Infinite stones | append, pre-generate, list, deterministic index | Deterministic index + window | Bounded-work reasoning and testability | Other approaches grow or impose arbitrary limits |
| Movement state | Explainability/no drift | separate scroll/camera/world offsets | One progress SSOT | Simpler state invariant | Multiple authorities add sync risk |
| UI boundary | Easy future app work | all-canvas, all-widgets, split | Split Flutter UI / world renderer | Concern fit | Avoid rebuilding UI or widgetizing world |
| Performance proof | Credible performance | debug, emulator, FPS label, profile/DevTools | Physical profile + DevTools | Official Flutter guidance | Stronger than anecdotal smoothness |
| Pooling | Bounded runtime | mandatory pool, derived window, unbounded | Derived bounded window first | Complexity proportional to evidence | Pool only if profiler proves need |
| Sound feedback | Small responsive interaction cues | none, direct `audioplayers`, other packages, custom engine | `flame_audio` | Official Flame bridge/docs; supports caching, loops and pooled repeated SFX | Small coherent surface; no custom subsystem |
| Asset strategy | Only demo video supplied; infinite path; two-day limit | All-downloaded, all-generated, all-procedural, baked background, 3D pipeline | Hybrid responsibility-based asset strategy | ADR-010 decision analysis | Procedural repeated geometry; layered signature art; curated generic support assets |

---

# 7. FAILURE / FALLBACK MAP

| Selected decision fails because | Fallback | What remains reusable |
|---|---|---|
| Flame integration blocks progress | Pure Flutter `CustomPainter`/ticker path | Domain, path, visible window, projection |
| 2.5D looks too flat | Tune projection/horizon/fog; only then evaluate isolated 3D spike | World model and progress state |
| Blur/fog is too expensive | Color/opacity atmospheric blending | Projection depth factor |
| Visible-window reconstruction allocates too much | Add measured reuse/pooling | Index/window architecture |
| Castle asset is weak | Procedural silhouette | Horizon model |
| Particle bonus causes jank | Remove bonus effect | Core map |
| Shader experiment fails | Remove shader | Entire core renderer |
| HUD work expands | Reduce to simple Flutter overlay | Core world |
| Audio integration or asset playback fails | Disable audio; preserve visual event and map flow | Entire core architecture |
| Generated castle/background does not match style | Replace isolated layer without changing world logic | World/projection architecture |
| Third-party asset license/provenance unclear | Remove asset; use procedural or clearly licensed replacement | Entire core architecture |
| Raster environment layer hurts memory/performance | Downscale/compress/split layer | Gameplay/world logic |

---

# 8. RE-VERIFICATION BEFORE IMPLEMENTATION

| Item | What to re-check | Trigger |
|---|---|---|
| Flame version | Current stable compatible version and docs | Project initialization |
| Flutter SDK | Installed stable version and Android toolchain | Project initialization |
| `vector_math` | Whether actually needed | Before adding dependency |
| `flutter_scene` / `flame_3d` status | Only if reopening true-3D decision | Explicit ADR amendment proposal |
| Performance claims | Actual physical device/profile evidence | Before README/interview claim |
| Visible count | Real visual/performance tradeoff | Integration tuning |
| Pooling need | Allocation/profile evidence | Only after profile run |
| `flame_audio` version | Current compatible stable version and Android playback on presentation device | Before adding/locking audio |
| Audio assets | Format/latency/volume on target Android device | Before final rehearsal |
| Non-procedural assets | Source/provenance, license status, target-device visual quality, raster dimensions/compression | Before final submission |

---

# 9. INTERVIEW-SAFE DECISION SUMMARY

A concise explanation:

> “I separated the logical saga world from its renderer. The world is deterministic and index-based, so it can progress indefinitely while only a bounded visible range is processed. I used Flame for the real-time lifecycle instead of rebuilding a game loop, but kept the 2.5D projection custom because the reference needs depth, not a general 3D engine. I compared current true-3D Flutter options, but kept them out of the critical path because the available packages still carry preview or experimental risk for a two-day POC. Flutter widgets own ordinary HUD UI, and performance is verified on the physical Android demo device in profile mode rather than claimed from debug mode.”

For assets, repeated world geometry stays procedural, signature horizon art remains layered and replaceable, and generic support icons come from a coherent curated source with explicit provenance.

---

# 10. CHANGE CONTROL

A decision may move from LOCKED only when all are supplied:

1. observed blocker or new requirement;
2. evidence that the current decision fails;
3. proposed alternative;
4. migration impact;
5. delivery impact;
6. fallback;
7. explicit amendment to `AD.md`.

Do not change architecture merely because another option is interesting.
