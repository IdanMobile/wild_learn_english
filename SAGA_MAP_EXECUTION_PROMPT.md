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

**This "Starting Repo State" section describes the state before the first execution
attempt. It is superseded by the Continuation Baseline below for anything that
section lists as already delivered.**

## CONTINUATION BASELINE — PRESERVE VERIFIED WORK

This execution continues from failed orchestration run
`run-20260709090051894-25468` (immutable evidence — do not modify anything under
`~/.claude/orchestration/runs/run-20260709090051894-25468/`). Its TASK-0001 through
TASK-0015 completed and were independently verified. Their current repository
outputs are accepted baseline, not a starting point to redo:

- `pubspec.yaml`, `pubspec.lock` — flame/flame_audio deps + asset declarations added
- `lib/main.dart` — boilerplate replaced
- `lib/app/saga_app.dart`
- `lib/saga_map/saga_map_screen.dart`
- `AD.md` — §29 bootstrap rows updated to `VERIFIED`
- `lib/saga_map/domain/saga_node_state.dart`
- `lib/saga_map/domain/saga_node.dart`
- `lib/saga_map/domain/saga_map_state.dart`
- `lib/saga_map/world/saga_path.dart`
- `lib/saga_map/world/visible_node_window.dart`
- `lib/saga_map/projection/perspective_projector.dart`
- `lib/saga_map/rendering/saga_scene.dart`
- `test/saga_map/world/saga_path_test.dart`
- `test/saga_map/world/visible_node_window_test.dart`
- `test/saga_map/projection/perspective_projector_test.dart`

Rules for planning/continuing from here:
- Planning must inspect and preserve these files as-is.
- Do not schedule replacement tasks for already-satisfied work unless a concrete
  incompatibility is proven against the actual current file content.
- Any required modification to an already-verified file listed above must be
  surfaced as an explicit exception requiring review before it is scheduled — never
  silently rewritten.
- The recovery scope begins at the structural gap around scene assembly / painter /
  game wiring (see WAVE 2 below, `saga_scene_builder.dart`) and continues through the
  remaining unfinished work (interaction, visual depth, debug, extensibility,
  performance, polish, submission closure).

## SECOND-GENERATION EXECUTION STATE — run-20260709112606184-87488

This prompt was itself planned and partially executed once already, as
`run-20260709112606184-87488` (immutable evidence — do not modify anything
under `~/.claude/orchestration/runs/run-20260709112606184-87488/`). Any new
plan generated from this prompt must treat that run's outcome as follows,
layered on top of the Continuation Baseline above (do not conflate the two —
this is a second, later layer of recovery state):

- **Preserve as accepted baseline** (that run's TASK-0001–TASK-0007):
  `AD.md` §29 ledger reconciliation; `lib/saga_map/rendering/saga_scene_builder.dart`
  + its test (W2-4); `lib/saga_map/rendering/saga_map_painter.dart` (W2-5);
  `lib/saga_map/saga_map_game.dart` + `lib/saga_map/saga_map_screen.dart`
  GameWidget wiring (W2-6); Gate D1-G2 verification; `lib/saga_map/navigation/saga_scroll_physics.dart`
  (W3-1) + its test (W3-3). Verified — do not silently redo.
- **Superseded/reopened, NOT accepted baseline** (that run's TASK-0008 — the
  W3-2 drag-wiring work item touching `lib/saga_map/saga_map_game.dart` +
  `lib/saga_map/saga_map_screen.dart`): it was marked verified, but its
  acceptance criteria were incomplete — they required only that `progress`
  be mutated by drag, never that `currentLevel` be derived from it. A worker
  satisfying those old criteria left Gate D1-G3 permanently failing. Do not
  treat any current `onDragUpdate` implementation as accepted baseline; W3-2
  below has been rewritten with expanded criteria and must be re-executed.
- **Failed verification, to be rerun once W3-2 is repaired** (that run's
  TASK-0009): Gate D1-G3, CRITICAL. Its own criteria were already correct
  and need no change beyond the strengthening below — see WAVE 3.
- **Blocked/unexecuted, unchanged** (that run's TASK-0010 onward): Waves 4–9.

Do not claim TASK-0001 through TASK-0008 of that run are all accepted
baseline — only TASK-0001–TASK-0007 are. TASK-0008 is reopened.

## THIRD-GENERATION EXECUTION STATE — run-20260709124807372-32774

A third run, `run-20260709124807372-32774` (immutable evidence — do not
modify anything under
`~/.claude/orchestration/runs/run-20260709124807372-32774/`), was planned
from an earlier version of this prompt and failed before any recovery work
ran. Its TASK-0001 (read-only baseline + reopened-bug inspection,
`owned_paths: []`) required `AD.md` §29 "bootstrap-through-W3-1" rows to
already read `VERIFIED`. They read `NOT_STARTED` live, and no task anywhere
in that plan owned `AD.md` upstream of TASK-0001 — the criterion was
unsatisfiable before execution began. TASK-0001 failed 2/2 attempts,
correctly (both attempts modified zero files); every downstream task,
including the movement recovery and Gate D1-G3, was never reached.

This was not a movement-model defect — it is a distinct, prior gap: nothing
in earlier prompt versions ever assigned ownership of reconciling `AD.md`'s
own stale rows. **`AD.md` §29 is a continuously-updated ledger by design
(AUTHORITY RULES §3: "update it as you go"), not a frozen Continuation
Baseline artifact** — its rows may legitimately still read `NOT_STARTED`
for real, unfinished work, but a read-only verification task must never be
the first and only task expected to make a stale-but-actually-complete row
read `VERIFIED`. WAVE 3 below now assigns that reconciliation its own
explicit, upstream task — see the required topology at the start of WAVE 3.

Preserve as accepted baseline from this run: none — it failed at its first
task, before producing any output. Do not claim any TASK from
`run-20260709124807372-32774` is accepted baseline.

## RECOVERY GOVERNANCE

The new plan must:
- Inspect current repo state before scheduling any task — never assume an empty
  repository.
- Detect already-satisfied requirements from the Continuation Baseline above and
  skip scheduling redundant work for them.
- Preserve verified outputs — never silently redo TASK-0001–TASK-0015-equivalent
  work.
- Plan only missing/recovery/downstream work where possible.
- Flag any need to alter an already-verified file as an explicit exception requiring
  review before execution, not a silent overwrite.

## PRE-DECLARED RECOVERY-GOVERNANCE EXCEPTIONS

Every later-wave modification to a Continuation Baseline file must cite one of
these pre-approved exceptions by number in its own acceptance criteria — this
satisfies the "surfaced as an explicit exception requiring review" rule above
without re-litigating the justification in every task. A baseline-file touch that
does **not** match one of these five is a new, unreviewed exception and must not
be scheduled silently.

**MANDATORY citation rule — this generates real tasks the automatic semantic
validator checks, read it before generating any task:** for every task whose
owned paths include ANY Continuation Baseline file, the generated task's OWN
description or acceptance criteria (not this prompt) MUST literally contain
the phrase "Recovery-Governance Exception `<N>`" with the correct number.
Two failure modes are BOTH insufficient and BOTH will be rejected: (1)
**source-level association alone** — the file being *listed* under an
Exception's "Owner/work item" line in this prompt does not transfer to the
generated task automatically; (2) **inherited implication** — a task's
description explaining *why* it touches a baseline file, without the literal
citation string, does not count even if the reasoning is correct. When in
doubt, over-cite in the generated task rather than omit it.

### Exception 1 — `lib/saga_map/saga_map_screen.dart`
- **Later responsibility requiring modification:** W2-6 (wiring `GameWidget` in
  place of the blank `Scaffold` stub), W3-2 (wiring drag input around
  `GameWidget`), W5-1 (wiring the debug-overlay toggle), W8-2 (wiring `SagaHud`).
- **Why additive modification is necessary:** the file was deliberately left a
  blank stub by the bootstrap wave specifically so each later wave could wire in
  its own widget — this was always the intended extension point, not frozen
  content.
- **Existing verified behavior that must remain unchanged:** must still build a
  valid `MaterialApp`/`Scaffold` tree; no prior wave's wiring may be removed by a
  later wave, only composed with.
- **Prohibited regressions:** no wave replaces another wave's wiring instead of
  composing with it; no reintroducing the blank stub; no duplicate
  `Scaffold`/`GameWidget` instantiation.
- **Owner/work item:** W2-6, W3-2, W5-1, W8-2 — each additive, in that order.

### Exception 2 — `lib/saga_map/world/saga_path.dart` AND `test/saga_map/world/saga_path_test.dart`
This exception governs BOTH the implementation file and its baseline test
file — they are modified together and share one justification. Any
generated task that owns either file must cite "Recovery-Governance
Exception 2" in its own task text (see the citation-fidelity rule above the
exceptions list — inheriting this from the prompt is not sufficient).
- **Later responsibility requiring modification:**
  - `lib/saga_map/world/saga_path.dart`: W3-2 (adding
    `levelForProgress(double progress)` — the canonical `progress` →
    `currentLevel` derivation required by Gate D1-G3), W4-1 (tuning meander
    constants for depth feel), W6-1 (adding `SagaPathPreset` enum).
  - `test/saga_map/world/saga_path_test.dart`: **W3-3** (adding the
    `levelForProgress` regression cases A–F required by WAVE 3 below).
- **Why additive modification is necessary:**
  - W3-2: `saga_path.dart` already owns the depth-spacing constant and the
    `depth(index)` forward mapping; deriving the inverse (`progress` → level)
    in the same module avoids duplicating that spacing invariant anywhere
    else (e.g. in `saga_map_game.dart` or `saga_map_state.dart`).
  - W4-1/W6-1: unchanged from before — the baseline `nodeAt`/`x`/`depth`
    functions are deliberately parameterized by tuning constants meant to be
    adjusted once real rendering exists to judge them against;
    `SagaPathPreset` is the extensibility proof Gate D2-G2 explicitly
    requires.
  - **W3-3: a new baseline-owned symbol (`levelForProgress`) requires new
    baseline-owned test coverage in the same file that already tests
    `saga_path.dart` — this is the required test companion to W3-2, not an
    independent modification, and it extends `test/saga_map/world/saga_path_test.dart`
    exactly as additively as W3-2 extends `saga_path.dart` itself.**
- **Existing verified behavior that must remain unchanged:** `nodeAt`'s signature
  (`SagaNode nodeAt(int index, {required int currentLevel})`), its determinism
  (same index + currentLevel → identical node, always), the existing
  depth-spacing constant's value and meaning, the "no Flutter/
  Flame/Canvas import, no cached mutable history" constraints, and every
  existing test case already in `saga_path_test.dart` (all must keep passing,
  byte-for-byte behaviorally unchanged).
- **Prohibited regressions:** `test/saga_map/world/saga_path_test.dart`'s
  prior `nodeAt`/depth test cases must not be rewritten, removed, or
  weakened by W3-3 — only the A–F `levelForProgress` cases may be added; no
  strategy-interface abstraction for the two-preset case (§15 rule 7 — a
  plain `switch` only); `levelForProgress` must reuse the existing
  depth-spacing constant — neither the implementation nor its tests may
  introduce a second, duplicate spacing value.
- **Required tests proving no regression:** W3-3 adds exactly the
  `levelForProgress` cases A–F (see WAVE 3 below for the exact list) to
  `test/saga_map/world/saga_path_test.dart` — the file's existing `nodeAt`/depth
  tests must stay green, unmodified, alongside them.
- **Owner/work item:** W3-2 (`levelForProgress` implementation, additive),
  **W3-3 (`levelForProgress` test coverage, additive)**, W4-1 (constant
  tuning), W6-1 (`SagaPathPreset` enum).

### Exception 3 — `lib/saga_map/domain/saga_map_state.dart` (the movement SSOT)
- **Later responsibility requiring modification:** W6-2 (live preset toggle needs
  to track which `SagaPathPreset` is currently active).
- **Why modifying the movement SSOT is necessary:** the active preset must live
  somewhere both the debug overlay (reads it) and `saga_path.dart` (consumes it to
  pick tuning constants) can reach without a second, competing state object.
  `SagaMapState` is the one existing app-wide state class; adding a
  **non-movement** field to it is the smallest-footprint option — deliberately
  weighed against a second state class, which would violate the "ONE movement
  SSOT" spirit worse than an adjacent field on the existing one.
- **Confirm no duplicate movement state is introduced:** the addition must be a
  preset-selector field only (e.g. `SagaPathPreset pathPreset`) — never a second
  `progress`, `currentLevel`, `scrollOffset`, `cameraOffset`, or
  `worldOffset`-like field.
- **Existing movement semantics/signatures that remain intact unless explicitly
  reviewed:** `SagaMapState({required progress, required currentLevel})`,
  `copyWith`, `==`, `hashCode` for `progress`/`currentLevel` — extended (new field
  with a default), never removed or retyped, without a separate explicit review.
- **Prohibited regressions:** no new mutable movement field; no change to how
  `progress`/`currentLevel` are read/written by `SagaScrollPhysics` or
  `saga_scene_builder.dart`; the existing SSOT grep check
  (`grep 'double progress'`) must still find exactly one match.
- **Required tests proving no movement regression:** `saga_scroll_physics_test.dart`
  and any Wave 3 movement tests must pass unmodified; add or extend a test
  confirming `SagaMapState` constructed with only `progress`/`currentLevel` (no
  preset argument) behaves exactly as before the preset field existed.
- **Owner/work item:** W6-2 only. No other wave may touch this file.

### Exception 4 — `pubspec.yaml`
- **Later responsibility requiring modification:** W8-3 (audio asset
  declarations), only if that optional wave is built.
- **Why additive modification is necessary:** baseline `pubspec.yaml` only
  declares the 9 pre-existing environment/props assets from Wave 0; audio assets
  don't exist yet and are sourced fresh in W8-3.
- **Existing verified behavior that must remain unchanged:** the `flame`/
  `flame_audio` dependency versions and the 9 already-declared Wave 0 asset
  entries must not be removed or have their versions changed.
- **Prohibited regressions:** `flutter pub get` must still resolve cleanly; no
  asset entry may reference a file that doesn't exist on disk (`docs/assets.md`
  updated in the same task, per W8-3).
- **Owner/work item:** W8-3 — additive only, explicitly optional/skippable per
  §13.5.

### Exception 5 — `AD.md` §29 ledger reconciliation (W3-0b only)
- **Later responsibility requiring modification:** W3-0b (reconciling stale
  bootstrap-through-W3-1 §29 rows before any read-only task is required to
  observe them as `VERIFIED`).
- **Why this needs a declared exception even though `AD.md` is a living
  ledger, not a frozen baseline file:** §29 is explicitly designed for
  continuous updates ("update it as you go" — AUTHORITY RULES §3), so routine
  gate-evidence rows are not baseline-frozen content. This exception exists
  only because W3-0b is a *dedicated* reconciliation task (not incidental
  gate bookkeeping) and its output gates whether W3-0c can pass — its scope
  must be explicitly bounded so it cannot become a shortcut for marking
  unfinished work `VERIFIED`.
- **Existing verified behavior that must remain unchanged:** rows already
  correctly `VERIFIED` (e.g. the six World/Projection rows) must not be
  touched or have their evidence text altered.
- **Prohibited regressions:** no row may be changed to `VERIFIED` without
  concrete evidence (existing file + passing test + prior verified-run
  citation) recorded in that row's Evidence column; unrelated rows outside
  the bootstrap-through-W3-1 scope must be left exactly as they are; W3-0b
  must not touch any implementation file — `AD.md` only.
- **Owner/work item:** W3-0b only.

This exception is subject to the MANDATORY citation rule at the top of the
Pre-Declared Recovery-Governance Exceptions section above — the generated
W3-0b task must literally contain "Recovery-Governance Exception 5".

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

## DEVICE/EMULATOR FALLBACK PROTOCOL (Gates D1-G2, D1-G3, Day 1 Exit, W9-1)

Before each of these four gates, run `flutter devices`. Three cases:

1. **Physical device available:** use it — always preferred.
2. **No physical device, but an emulator is available:** use the emulator. This is
   acceptable for these four gates specifically (only Gate D2-G3 requires a
   physical device exclusively, per Locked Decisions above).
3. **Neither is reachable:** do NOT claim the gate passed on a run you didn't
   actually perform, and do NOT substitute a description of expected behavior for
   an observation. Instead:
   - Run the strongest available static fallback: `flutter analyze` (zero
     issues) plus `flutter test` (full suite green) plus, where the gate needs
     visual confirmation, a `flutter build apk --debug` (or equivalent)
     compile-only check as evidence the app at least builds.
   - Record explicitly, in the gate's evidence and in the `AD.md` §29 row:
     "device/emulator unavailable — fallback validation performed (name exactly
     which of analyze/test/build ran and passed) — device-run gate still
     pending." Never word this as "gate passed" or "verified" for the run-only
     portion.
   - Continue to the next wave rather than stalling — this generalizes the same
     honest-blocker pattern the Wave 7 device-unavailable rule above already
     uses for Gate D2-G3.

## PRE-EXECUTION STRUCTURAL PLAN VALIDATION (mandatory before ORCHESTRATE)

Before this plan is approved for execution, the planner/plan validator must check:

A. **Consumer-before-provider inversion** — if task A consumes a responsibility/file
   that task B owns, B must not depend on A, unless a justified cycle-breaking
   contract is explicitly documented.
B. **Verification-vs-ownership contradiction** — a task must not require behavior
   while simultaneously banning the only implementation mechanism for it, unless
   that behavior is delegated to an explicit dependency that owns it.
C. **Responsibility ownership completeness** — every material verb/responsibility in
   this document (assemble, wire, project, draw, persist, validate, ...) must map to
   exactly one task's owned paths.
D. **DAG acyclicity** — the dependency graph must contain no cycles.
E. **Owned-path coverage** — every file this prompt names must be owned by exactly
   one task (or an explicitly justified shared-ownership sequence over time).
F. **Acceptance criteria satisfiability** — each task's acceptance criteria must be
   achievable using only its own owned paths and its declared dependencies' outputs,
   with nothing left implicit.
G. **Derived-state ownership completeness** — for every state field this document
   documents as derived from another field/SSOT (e.g. `currentLevel` derived from
   `progress`), confirm: (i) exactly one task explicitly owns writing/updating the
   derivation, (ii) that task's acceptance criteria require the derivation to
   actually execute in production code (not merely permit it), and (iii) a
   verification task or test actually exercises the coupling end-to-end (not just
   each field in isolation, and not satisfiable by a criteria set that only checks
   the source field changed).

Checks A–F are exactly the class of gap that caused `run-20260709090051894-25468`
to fail at TASK-0016 (see WAVE 2 below). Check G is exactly the class of gap that
caused `run-20260709112606184-87488` to pass its TASK-0008 while leaving Gate
D1-G3 permanently broken (see Second-Generation Execution State above and WAVE 3
below) — validate for both before executing, not after.

## EXECUTION PLAN — 36 tasks across 10 waves (W0–W9)

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
- **W2-3** `lib/saga_map/rendering/saga_scene.dart` — immutable bounded scene **data
  holder only**: owns the scene data representation (window + projected nodes), const
  constructor, no mutation methods, no scene-graph behavior. Does NOT own the
  assembly loop that produces its `nodes` list and does NOT provide a factory that
  performs window/path/projection traversal — that is W2-4's responsibility, not
  this file's.
- **W2-4** `lib/saga_map/rendering/saga_scene_builder.dart` — pure scene-**assembly**
  function only: call `windowFor(state.currentLevel)`, iterate the visible indices,
  call `nodeAt(index, currentLevel: state.currentLevel)` for each, call
  `PerspectiveProjector.project(node, state.progress)`, cull null projected nodes,
  return `SagaScene(window: ..., nodes: ...)`. No mutable state, no drawing, no Flame
  game lifecycle ownership. Depends only on `SagaMapState`, `saga_path.dart`'s
  `nodeAt`, `visible_node_window.dart`'s `windowFor`, `PerspectiveProjector`, and
  `SagaScene`.
- **W2-5** `lib/saga_map/rendering/saga_map_painter.dart` — far-to-near draw order,
  consumes `SagaScene` only, simple procedural stone shapes (no per-node raster
  assets), never mutates `progress`. Hoist `Paint`/`Path` objects to fields, don't
  allocate per-frame. Must **not** depend on `saga_map_game.dart`, must **not**
  assemble the scene itself, must **not** own world/projection traversal — it only
  draws what W2-4 already assembled.
- **W2-6** `lib/saga_map/saga_map_game.dart` — Flame `Game`/`FlameGame` subclass.
  Consumes `SagaMapState`, the W2-4 scene builder, and the W2-5 painter; assembles
  the per-frame `SagaScene` **only** by calling the W2-4 builder — must **not** call
  `windowFor` or `nodeAt` directly, must **not** duplicate projection math, must
  **not** duplicate painter logic. Stays thin — this class must not become a god
  class. Build this after W2-5: the painter it wires in must already exist. Wire the
  resulting `GameWidget` into `saga_map_screen.dart` in place of the blank
  `Scaffold` stub (Recovery-Governance Exception 1).
- **Gate D1-G2**: static screenshot reads as depth-rich, obvious near/far scale
  difference, bounded stone count, no per-frame allocation in the hot path. If no
  device/emulator is reachable, use the Device/Emulator Fallback Protocol above
  instead of skipping silently.

**Ordering/dependency topology for this wave (unambiguous, do not invert):**
```
SagaScene (W2-3, data holder)
    ↓                    ↓
SceneBuilder (W2-4)   Painter (W2-5)
    ↓                    ↓
        SagaMapGame (W2-6)
```
`SagaMapGame` may depend on the scene builder and the painter. Neither the scene
builder nor the painter may depend on `SagaMapGame`. The scene builder does not
depend on the painter; the painter does not depend on the scene builder unless a
future wave explicitly justifies it in writing.

### WAVE 3 — Interaction (Gate D1-G3, CRITICAL)

**Required topology for this wave (unambiguous, do not invert or collapse
into a single task):**
```
W3-0a  ledger evidence inspection (read-only)
   ↓
W3-0b  AD.md ledger reconciliation (owns AD.md only, Exception 5)
   ↓
W3-0c  read-only baseline + reopened-bug verification
   ↓
W3-1 (already-verified baseline, informational only) / W3-2  movement recovery
   ↓
Gate D1-G3 (CRITICAL)
   ↓
WAVE 4+
```
This exists because `run-20260709124807372-32774`'s TASK-0001 collapsed
ledger inspection and verification into one read-only task with no upstream
task able to make its own criteria true — see Third-Generation Execution
State above. W3-0a/W3-0b/W3-0c split that back into separately-owned steps.

- **W3-0a** Read-only: inspect `AD.md` §29 rows in the bootstrap-through-W3-1
  range. For each row not already `VERIFIED`, gather concrete evidence of
  whether the underlying work is actually done (file exists on disk, its
  test passes, and/or it is cited as verified in `run-20260709090051894-25468`
  or `run-20260709112606184-87488`'s execution evidence). Produce an
  evidence list; do not modify `AD.md` or any other file.
- **W3-0b** Using W3-0a's evidence, update `AD.md` §29 (Exception 5): change
  to `VERIFIED` only the rows W3-0a proved are actually done, with concrete
  evidence recorded in that row's Evidence column (never `VERIFIED` merely
  because this prompt says so). Leave any row honestly `NOT_STARTED` if
  W3-0a could not prove it — this task must not fabricate completeness.
  Preserve every unrelated row exactly as-is. Touches `AD.md` only, no
  implementation file.
- **W3-0c** Read-only, depends on W3-0b: re-verify the Continuation Baseline
  files listed above are present with their documented roles; re-verify
  `AD.md` §29 bootstrap-through-W3-1 rows now read `VERIFIED` for whatever
  W3-0b proved (if W3-0b honestly left a row `NOT_STARTED` because the
  underlying work is genuinely missing, this task must report that
  truthfully, not treat it as a pass); confirm `levelForProgress` is still
  absent from `lib/` and `test/`, and that `saga_map_game.dart`'s
  `onDragUpdate` still only mutates `progress` — i.e. the reopened bug is
  still real and still needs W3-2 below.
- **W3-1** `lib/saga_map/navigation/saga_scroll_physics.dart` — drag delta →
  sensitivity → progress delta; release inertia with `dt`-aware friction decay,
  settles below a threshold; never binds to a Flutter `ListView` scroll offset.
  Already accepted baseline per Second-Generation Execution State above —
  informational only, do not re-schedule.
- **W3-2** Wire drag input (Flame `DragCallbacks` or `GestureDetector` around
  `GameWidget`) into `SagaScrollPhysics` → `SagaMapState.progress` → the render
  pipeline, completing the full `AD.md` §5.1 pipeline end-to-end — AND own the
  `progress` → `currentLevel` derivation this pipeline requires (`AD.md` §17.2,
  §5.1: "advancing progress advances integer window"). Specifically,
  `onDragUpdate` (or equivalent) must, in the same state transition:
  - compute clamped absolute `progress` (never negative) from the current
    `progress` plus the drag-derived delta — `progress` remains the one
    absolute, never-reset movement value;
  - derive `currentLevel` from that same clamped `progress` via the new
    canonical `levelForProgress(double progress)` helper added to
    `saga_path.dart` (Recovery-Governance Exception 2) — never an
    independently incremented/decremented `currentLevel`, never a second
    accumulator or offset;
  - update `progress` and `currentLevel` together via a single `copyWith`
    call — never in two steps that could observe an inconsistent state;
  - correctly advance multiple levels in one large drag delta (no per-level
    loop needed — `levelForProgress` is a pure `floor` division, so this is
    automatic) and correctly retreat `currentLevel` on reverse drag, down to
    a hard floor of `currentLevel == 0`;
  - not duplicate any projection math and not introduce any state field
    beyond the existing `progress`/`currentLevel` pair.
  Touches `saga_map_game.dart`/`saga_map_screen.dart` (Recovery-Governance
  Exception 1) and `saga_path.dart` (Recovery-Governance Exception 2, for
  `levelForProgress` only). **Supersedes the prior TASK-0008 implementation
  from `run-20260709112606184-87488` — see Second-Generation Execution State
  above; do not treat any existing `onDragUpdate` as already satisfying this.**
- **W3-3** `test/saga_map/navigation/saga_scroll_physics_test.dart` — drag changes
  progress, release inertia continues, friction decays, settles, `dt`-aware
  (unchanged from before). Extend baseline file
  `test/saga_map/world/saga_path_test.dart` (**Recovery-Governance
  Exception 2** — this task's generated description and acceptance criteria
  must carry that literal citation, not just this prompt's) with
  `levelForProgress` cases: (A) below the first threshold → level 0,
  (B) exactly at a threshold → that level, (C) just above a threshold → that
  level, (D) a multi-threshold jump in one call → the correct higher level,
  (E) reverse/decreasing progress → level decreases accordingly, (F) clamp
  at zero for any non-positive progress. Existing `nodeAt`/depth tests in
  that file must pass unmodified — add only cases A–F, never rewrite, remove,
  or weaken any prior test case. Reuse the existing depth-spacing constant;
  do not duplicate it.
- **W3-4** `test/saga_map/saga_map_game_test.dart` (new file) — drive
  `onDragUpdate` directly (no widget pump needed for pure state assertions):
  (G) `progress` stays absolute and non-negative through a drag sequence,
  (H) `currentLevel` equals `levelForProgress(progress)` after every single
  drag update, (I) a cumulative forward drag spanning several thresholds
  advances `currentLevel` by more than one level in one step, (J) a long
  forward drag (many levels) leaves `buildSagaScene(...)`'s resulting
  `SagaScene.nodes` non-empty (the non-blank-scene regression this repair
  exists to prevent). (K) and (L): rerun the full existing suite —
  `saga_path_test.dart`, `visible_node_window_test.dart`,
  `perspective_projector_test.dart`, `saga_scene_builder_test.dart`,
  `saga_scroll_physics_test.dart` — all must still pass unmodified.
- **Gate D1-G3 (CRITICAL)**: continuous drag traversal feels apparently
  infinite — the visible window must keep advancing and the scene must
  never eventually go blank, no matter how long the drag continues; no
  discontinuity at window-boundary changes. `progress` is the only
  primary/source movement value — `currentLevel` is a deterministic derived
  window anchor computed from `progress` via the canonical
  `levelForProgress` helper (W3-2/`saga_path.dart`), not an independent
  accumulator: grep confirms no second `double progress`-like field, no
  second offset, no duplicate movement state. The canonical invariant
  `currentLevel == max(0, floor(progress / levelDepthSpacing))` (using
  `saga_path.dart`'s existing depth-spacing constant — never a duplicated
  value) must hold after every drag update, and `currentLevel` must be
  observed actually advancing as `progress` crosses each level-spacing
  threshold — not merely theoretically derivable. Do not satisfy this gate
  with a renderer/projection workaround (e.g. widening the visible window,
  changing culling thresholds, or otherwise masking a `currentLevel` that
  still never advances) — the underlying movement state itself must be
  correct. **If this gate fails, stop all bonus work and fix it before
  touching Wave 4.** If no device/emulator is reachable, use the
  Device/Emulator Fallback Protocol above — do not skip this CRITICAL gate
  silently.

### WAVE 4 — Core visual depth (Day 1 Exit Gate)
- **W4-1** Extend `saga_map_painter.dart` with fog/atmosphere blending from
  `fogFactor` (color/alpha only — no blur), procedural stone shadows, tuned path
  meander constants (verify `saga_path_test.dart` still passes after tuning).
  `saga_path.dart` tuning is Recovery-Governance Exception 2.
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
  If no device/emulator is reachable, use the Device/Emulator Fallback Protocol
  above instead of skipping silently.

### WAVE 5 — Debug proof (Gate D2-G1)
- **W5-1** `lib/saga_map/debug/saga_debug_overlay.dart` — toggleable overlay showing
  REAL `progress`, current index, live visible-node count, path preset name, and FPS
  from a real measurement source (never hardcode 60). Wire toggle into
  `saga_map_screen.dart` (Recovery-Governance Exception 1).
- **W5-2** Extend the debug overlay (or painter, debug-guarded) with projection debug
  annotations (horizon line, index, relative depth, scale per node) reusing the
  already-computed `SagaScene` — do not recompute projection twice.
- **Gate D2-G1**: an interviewer can understand infinite/bounded/projection behavior
  without opening source.

### WAVE 6 — Extensibility proof (Gate D2-G2)
- **W6-1** Extend `saga_path.dart` with `enum SagaPathPreset { gentle, dramatic }` —
  same formula, different tuning constants selected by a plain `switch`. No strategy
  interface for two cases (violates §15 rule 7). Recovery-Governance Exception 2.
- **W6-2** Add a live preset toggle (HUD or debug overlay), touching only
  `saga_map_state.dart` (Recovery-Governance Exception 3) and
  `saga_debug_overlay.dart`. Verify the extensibility proof **without git** (git is
  out of scope — see Locked Decisions above, do not reference commits or a commit
  diff): record the exact list of files this task modifies and confirm zero files
  under `lib/saga_map/rendering/`, `lib/saga_map/projection/`, or
  `lib/saga_map/navigation/` appear in it — that file list, not a commit diff, IS
  the extensibility proof. Full test suite still green.
- **Gate D2-G2**: world-generation variation required zero renderer rewrite,
  confirmed via the W6-2 file list above (not a git diff).

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
  reads `SagaMapState` live, never keeps a local copy of progress. Wire into
  `saga_map_screen.dart` (Recovery-Governance Exception 1).
- **W8-3** `lib/saga_map/audio/saga_audio.dart` — minimal `flame_audio` owner class:
  preload 2–3 short SFX (tap/select, completion), play on real domain events, never
  mutates state, fails silently (debug-log only). NOTE: no audio asset files exist yet
  — sourcing them (and adding `assets/audio/`, declaring in `pubspec.yaml` —
  Recovery-Governance Exception 4 — recording provenance in `docs/assets.md`) is a
  real prerequisite not separately itemized in `AD.md`'s ledger. This whole task is
  optional/skippable per §13.5 if time-constrained — skip cleanly rather than
  half-build it.
- **W8-4** Optional: one tap interaction on the current node with a small
  animation/particle response — genuinely optional, easily removable if it causes
  jank (remove it if so, per the fallback map).

### WAVE 9 — Submission closure (Final Gate)
- **W9-1** `flutter analyze`, `flutter test` (full suite), final `flutter run -d
  <android>` on the same device used in W7-1 if available. If no device/emulator is
  reachable, use the Device/Emulator Fallback Protocol above instead of skipping
  silently.
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
