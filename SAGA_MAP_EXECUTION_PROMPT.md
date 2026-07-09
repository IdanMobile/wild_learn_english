# SAGA MAP POC — FULL EXECUTION (BUILD TO COMPLETION)

## MODE

EXECUTION. Build the Saga Map POC end-to-end, wave by wave, respecting every gate
in `AD.md`. This is NOT the planning-only phase — implement real code, real tests,
real assets wiring, real Android runs. Stop only at genuine blockers (see "Blockers"
below), never by fabricating evidence.

## AUTHORITY RULES

1. `AD.md` (repo root) is the single locked implementation/progress source of truth.
   If anything in this prompt conflicts with `AD.md`, `AD.md` wins.
2. `ARCHITECTURE_DECISIONS.md` is rationale only — read it for the "why," never treat
   it as a second authority.
3. Do not create `TODO.md`, `TASKS.md`, a second architecture doc, or any competing
   progress tracker. Progress is tracked ONLY in `AD.md` §29 (Progress Ledger) — update
   it as you go, status values `NOT_STARTED / IN_PROGRESS / BLOCKED / IMPLEMENTED /
   VERIFIED / REJECTED`. `IMPLEMENTED` is not the same as `VERIFIED`.
4. Do not invent abstractions, packages, or files beyond what `AD.md` specifies.
   Reread §15 (Anti-Redundancy Rules — NON-NEGOTIABLE) before adding any class.
5. Never fabricate performance numbers, FPS values, or "it works" claims without
   actually running the code and observing it.

## STARTING REPO STATE (verify this is still accurate before trusting it)

As of last audit: bare `flutter create` scaffold. `lib/` contains only the default
`main.dart` counter app. `pubspec.yaml` has no `flame`/`flame_audio`/`assets:` section.
No `test/`, no `integration_test/`, no CI, not a git repo. All 9 expected asset files
exist under `assets/environment/` and `assets/props/` (matching `docs/assets.md`
exactly) but are not yet declared in `pubspec.yaml`. No audio assets exist. No demo
video exists anywhere in the repo. `docs/architecture.md` and
`docs/performance/results.md` do not exist yet. `AD.md` §29's ~30 ledger rows are all
`NOT_STARTED`.

Re-verify with `flutter --version`, `flutter devices`, `ls lib/`, `git status` (if a
`.git` dir exists) at the start — do not assume the above is still true if evidence
contradicts it.

## LOCKED DECISIONS FROM PRIOR PLANNING SESSION

- **Physical Android device (required for Wave 7 / Gate D2-G3, CRITICAL):** may not be
  available. Proceed through Waves 0–6 normally. At Wave 7, check `flutter devices`
  for a physical target. If none is available: do NOT substitute an emulator as final
  evidence (`AD.md` §18.1 forbids this) and do NOT fabricate numbers. Instead, document
  this honestly as a blocked/incomplete gate in `docs/performance/results.md` and in
  the `AD.md` §29 ledger, then continue completing Waves 8–9 (everything not gated on
  the device). Leave Gate D2-G3 and the final "physical Android demo verified"
  checklist item honestly unchecked.
- **Git:** out of scope. Do not run `git init` or add a git-init task. If a
  `commit hash` evidence field would apply, mark it "not applicable — repo not under
  version control" rather than inventing one.

## EXECUTION PLAN — 35 tasks across 10 waves (W0–W9)

Execute in this order. Each wave has a gate; do not start bonus/polish work if a
CRITICAL gate fails — stop and fix first (see `AD.md` §21/§25).

### WAVE 0 — Bootstrap (Gate D1-G0)
- **W0-1** Run `flutter --version`, `flutter doctor`, `flutter devices`; record exact
  resolved versions.
- **W0-2** `flutter pub add flame` and `flutter pub add flame_audio` (resolve current
  stable versions live — never hardcode from memory, per §4.5); add `flutter: assets:`
  entries for all 9 files under `assets/environment/` and `assets/props/`;
  `flutter pub get`.
- **W0-3** Replace `lib/main.dart` boilerplate with a minimal `SagaApp` →
  `MaterialApp(home: SagaMapScreen())` entrypoint (`lib/app/saga_app.dart`,
  `lib/saga_map/saga_map_screen.dart` as a blank `Scaffold` stub). Do NOT pre-create
  empty `domain/`, `world/`, `navigation/`, `projection/`, `rendering/`, `debug/`,
  `audio/` folders — create each file only in the wave that populates it.
- **W0-4** Update `AD.md` §29 rows for bootstrap to `VERIFIED` with real evidence.

### WAVE 1 — Domain + infinite world (Gate D1-G1)
- **W1-1** `lib/saga_map/domain/saga_node_state.dart` (`enum SagaNodeState {
  completed, current, upcoming }`) and `lib/saga_map/domain/saga_node.dart` (immutable
  `SagaNode { index, x, depth, state }`, const constructor, no boolean flags).
- **W1-2** `lib/saga_map/domain/saga_map_state.dart` — `SagaMapState { double
  progress; int currentLevel; }`. This is the ONE movement SSOT — no
  `scrollOffset`/`cameraOffset`/`worldOffset` duplicate anywhere in the codebase, ever.
- **W1-3** `lib/saga_map/world/saga_path.dart` — pure `SagaNode nodeAt(int index,
  {required int currentLevel})`; deterministic sinusoidal `x(i)`; monotonic `depth`;
  state derived from index vs currentLevel; no Flutter/Flame/Canvas import; no cached
  mutable history.
- **W1-4** `lib/saga_map/world/visible_node_window.dart` — bounded index range
  (~2 behind / ~24 ahead as a starting point, tune later), recomputed each call, no
  cross-frame accumulation.
- **W1-5** `test/saga_map/world/saga_path_test.dart` — same-index-same-result,
  large-index finite, negative-index finite (decide & document support).
- **W1-6** `test/saga_map/world/visible_node_window_test.dart` — bounded count,
  window shifts with progress, no duplicate indices, stays bounded at
  ≥1,000,000-equivalent simulated travel (prove via the arithmetic, don't brute-force
  allocate a million nodes in the test).
- **Gate D1-G1**: deterministic generation, large index works, bounded visible count
  proven, tests green.

### WAVE 2 — Projection + first visible world (Gate D1-G2)
- **W2-1** `lib/saga_map/projection/perspective_projector.dart` — pure math:
  `relativeDepth = node.depth - progress`; `scale = focalLength / (focalLength +
  relativeDepth)`; `screenX = viewportCenterX + node.x * scale`; tuned `screenY`
  toward horizon; `fogFactor`; guard against near-zero divide; cull non-finite /
  behind-camera results.
- **W2-2** `test/saga_map/projection/perspective_projector_test.dart` — farther
  projects smaller, trends toward horizon, finite output sweep, safe culling.
- **W2-3** `lib/saga_map/rendering/saga_scene.dart` — small immutable bounded struct
  assembled from window→path→projector output. Keep it a plain data holder, do not
  grow it into a scene graph.
- **W2-4** `lib/saga_map/saga_map_game.dart` — Flame `Game`/`FlameGame` subclass
  wiring `SagaMapState` + path/window/projector/painter. No inline domain math — this
  class must not become a god class.
- **W2-5** `lib/saga_map/rendering/saga_map_painter.dart` — far-to-near draw order,
  consumes `SagaScene`, simple procedural stone shapes (no per-node raster assets),
  never mutates `progress`. Hoist `Paint`/`Path` objects to fields, don't allocate
  per-frame.
- **Gate D1-G2**: static screenshot reads as depth-rich, obvious near/far scale
  difference, bounded stone count, no per-frame allocation in the hot path.

### WAVE 3 — Interaction (Gate D1-G3, CRITICAL)
- **W3-1** `lib/saga_map/navigation/saga_scroll_physics.dart` — drag delta →
  sensitivity → progress delta; release inertia with `dt`-aware friction decay,
  settles below a threshold; never binds to a Flutter `ListView` scroll offset.
- **W3-2** Wire drag input (Flame `DragCallbacks` or `GestureDetector` around
  `GameWidget`) into `SagaScrollPhysics` → `SagaMapState.progress` → the render
  pipeline, completing the full `AD.md` §5.1 pipeline end-to-end.
- **W3-3** `test/saga_map/navigation/saga_scroll_physics_test.dart` — drag changes
  progress, release inertia continues, friction decays, settles, `dt`-aware.
- **Gate D1-G3 (CRITICAL)**: continuous drag traversal feels apparently infinite, no
  discontinuity at window-boundary changes, `progress` is verifiably the only mutated
  movement value (grep for a second `double progress`-like field). **If this gate
  fails, stop all bonus work and fix it before touching Wave 4.**

### WAVE 4 — Core visual depth (Day 1 Exit Gate)
- **W4-1** Extend `saga_map_painter.dart` with fog/atmosphere blending from
  `fogFactor` (color/alpha only — no blur), procedural stone shadows, tuned path
  meander constants (verify `saga_path_test.dart` still passes after tuning).
- **W4-2** Extend `saga_map_painter.dart` to render `assets/environment/castle.png`
  as a distance-aware horizon anchor — scale/haze/opacity derived purely from existing
  depth/progress, no new mutable offset field. Single asset only; do not touch
  `castle_detail_overlay.png` yet.
- **W4-3** Extend `saga_map_painter.dart` to visually differentiate
  `SagaNodeState.{completed,current,upcoming}` via color/opacity/accent — a plain
  `switch`, no new boolean fields.
- **Day 1 Exit Gate**: Android runnable, convincing depth, continuous drag + inertia,
  infinite logical progression, bounded visible count, castle visible, single
  progression SSOT, core tests green. **Do not start Day 2 work until this is green.**

### WAVE 5 — Debug proof (Gate D2-G1)
- **W5-1** `lib/saga_map/debug/saga_debug_overlay.dart` — toggleable overlay showing
  REAL `progress`, current index, live visible-node count, path preset name, and FPS
  from a real measurement source (never hardcode 60). Wire toggle into
  `saga_map_screen.dart`.
- **W5-2** Extend the debug overlay (or painter, debug-guarded) with projection debug
  annotations (horizon line, index, relative depth, scale per node) reusing the
  already-computed `SagaScene` — do not recompute projection twice.
- **Gate D2-G1**: an interviewer can understand infinite/bounded/projection behavior
  without opening source.

### WAVE 6 — Extensibility proof (Gate D2-G2)
- **W6-1** Extend `saga_path.dart` with `enum SagaPathPreset { gentle, dramatic }` —
  same formula, different tuning constants selected by a plain `switch`. No strategy
  interface for two cases (violates §15 rule 7).
- **W6-2** Add a live preset toggle (HUD or debug overlay). Verify zero diffs to
  projection/rendering/physics files were needed — that diff-count IS the extensibility
  proof. Full test suite still green.
- **Gate D2-G2**: world-generation variation required zero renderer rewrite.

### WAVE 7 — Performance evidence (Gate D2-G3, CRITICAL — see "Locked Decisions" above)
- **W7-1** `flutter run --profile -d <physical-android-device>`; ~30s continuous
  high-velocity traversal; observe via DevTools Performance / performance overlay;
  confirm bounded visible count via the debug overlay throughout. If no physical
  device is available, follow the blocker-handling rule above instead of skipping
  silently.
- **W7-2** `docs/performance/results.md` — device model, OS version, Flutter/Flame
  versions, build mode, scenario, configured visible-node count, observed issues,
  measured findings, honest reporting even if W7-1 could not be completed on a
  physical device.
- **Gate D2-G3**: profile method documented, bounded count confirmed, no crash, no
  fabricated claim — OR honestly recorded as blocked/incomplete with reason.

### WAVE 8 — Polish (only after Gate D2-G3 is resolved, pass or honestly-blocked)
- **W8-1** Verify `docs/assets.md` still matches the `pubspec.yaml assets:` block —
  no drift.
- **W8-2** `lib/ui/saga_hud.dart` — top counters/buttons/debug-toggle entry point,
  reads `SagaMapState` live, never keeps a local copy of progress.
- **W8-3** `lib/saga_map/audio/saga_audio.dart` — minimal `flame_audio` owner class:
  preload 2–3 short SFX (tap/select, completion), play on real domain events, never
  mutates state, fails silently (debug-log only). NOTE: no audio asset files exist yet
  — sourcing them (and adding `assets/audio/`, declaring in `pubspec.yaml`, recording
  provenance in `docs/assets.md`) is a real prerequisite not separately itemized in
  `AD.md`'s ledger. This whole task is optional/skippable per §13.5 if time-constrained
  — skip cleanly rather than half-build it.
- **W8-4** Optional: one tap interaction on the current node with a small
  animation/particle response — genuinely optional, easily removable if it causes
  jank (remove it if so, per the fallback map).

### WAVE 9 — Submission closure (Final Gate)
- **W9-1** `flutter analyze`, `flutter test` (full suite), final `flutter run -d
  <android>` on the same device used in W7-1 if available.
- **W9-2** Rewrite `README.md` per `AD.md` §28: assignment summary, exact run
  commands, one architecture diagram (the §5.1 pipeline), dependency rationale (link
  `ARCHITECTURE_DECISIONS.md`), infinite-world explanation, performance summary (from
  W7-2, honest), test commands, limitations, future work (§20 triggers).
- **W9-3** `docs/architecture.md` — describe the ACTUAL shipped module boundaries and
  file tree (not an aspirational copy of §14), note any justified deviations.
- **W9-4** Final `AD.md` §29 ledger pass: every row updated to its true final status
  with real evidence (test command + result, device model, etc. — not rubber-stamped).
  Walk `AD.md` §30's Final Acceptance Checklist honestly; leave any item unmet if it
  genuinely wasn't achieved (e.g. W7-1 may legitimately stay `BLOCKED`). Remove any
  dead code / stray TODOs. Grep for duplicate SSOT fields one last time.

## STOP CONDITIONS (per AD.md §25 — halt and report, don't paper over)

App no longer runs on Android; visible count grows with travel history; a second
mutable movement SSOT appears; projection outputs non-finite values; sustained
traversal crashes; bonus work causes persistent jank; architecture can no longer be
explained simply; documentation no longer matches implementation.

## WHEN FULLY DONE

Report: which waves/gates passed, which (if any) are honestly incomplete and why
(expected: Wave 7 pending a physical device, and possibly W8-3 audio if skipped),
what evidence exists for each claim, and the final state of the `AD.md` §29 ledger.
Do not claim the POC is "complete" if any CRITICAL gate (D1-G3, D2-G3) is unresolved —
report it as what it is.
