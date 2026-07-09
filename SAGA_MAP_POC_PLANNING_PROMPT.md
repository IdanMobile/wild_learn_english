# SAGA MAP POC — FULL REPOSITORY AUDIT AND IMPLEMENTATION PLAN

## MODE

PLANNING ONLY.

DO NOT IMPLEMENT.
DO NOT EDIT PRODUCT CODE.
DO NOT CREATE FEATURES.
DO NOT INSTALL PACKAGES.
DO NOT RUN CODE-GENERATING COMMANDS.
DO NOT REFACTOR.
DO NOT DELETE FILES.
DO NOT START EXECUTION.

Your task in this phase is to inspect the entire repository and all supplied project documentation, validate the current state against the authoritative architecture, and produce a complete implementation plan before any coding begins.

---

# 1. PRIMARY OBJECTIVE

We are building a two-day Flutter Android interview POC for a 3D-feeling / 2.5D infinite saga map.

The core experience is:

- vertical progression through a depth-rich saga map;
- apparently infinite stones/nodes;
- a castle on the horizon;
- smooth scrolling/dragging;
- perspective depth;
- bounded runtime work;
- strong Flutter architecture;
- measurable Android performance;
- clean future extensibility;
- code that a senior developer can explain in an interview.

This is a POC.

Do not turn it into a production platform.
Do not create speculative architecture.
Do not generate redundant abstractions.
Do not optimize for code volume.

---

# 2. AUTHORITATIVE DOCUMENT ORDER

You must first locate and read all project documentation.

Read in this exact order:

1. `AD.md`
2. `ARCHITECTURE_DECISIONS.md`
3. `README_START.md`
4. `docs/assets.md`
5. every other `.md` file in the repository
6. current Flutter/Dart project files
7. tests
8. asset folders
9. Android configuration
10. package configuration
11. any existing implementation code

## Authority rules

### `AD.md`

`AD.md` is the authoritative implementation source of truth.

It defines:

- locked architecture;
- scope;
- non-goals;
- module boundaries;
- package policy;
- SSOT rules;
- execution gates;
- testing requirements;
- performance requirements;
- agent ownership;
- anti-redundancy constraints;
- authoritative progress tracking.

You must not reinterpret a locked `AD.md` decision merely because you prefer another architecture.

### `ARCHITECTURE_DECISIONS.md`

This file explains:

- why decisions were made;
- what alternatives were compared;
- tradeoffs;
- evidence;
- rejected approaches;
- fallback paths;
- re-evaluation triggers.

It is rationale, not a competing implementation authority.

If it appears to conflict with `AD.md`, `AD.md` wins.

### Other Markdown files

Use them as supporting context only.

No other document may silently become a second architecture or progress SSOT.

---

# 3. CRITICAL SSOT RULE

There must remain exactly one authoritative implementation/progress SSOT:

`AD.md`

For this planning phase you may create exactly one temporary planning artifact:

`IMPLEMENTATION_PLAN_PROPOSAL.md`

It must begin with this warning:

> NON-AUTHORITATIVE PLANNING ARTIFACT.
> `AD.md` remains the sole implementation and progress source of truth.
> This file must not be used for implementation progress tracking.
> Accepted tasks must be merged into the authoritative `AD.md` execution/progress section before execution begins.

Do not create:

- `TODO.md`
- `TASKS.md`
- another roadmap
- another architecture document
- another progress ledger
- hidden task state
- agent-specific competing TODO files

unless explicitly required by the existing authoritative AD.

---

# 4. FIRST ACTION — COMPLETE REPOSITORY INVENTORY

Before proposing tasks, inspect the complete repository.

Produce an inventory covering:

- root files;
- all Markdown documentation;
- `pubspec.yaml`;
- Flutter SDK constraints;
- Dart SDK constraints;
- dependencies;
- dev dependencies;
- `lib/`;
- `test/`;
- `integration_test/` if present;
- Android project configuration;
- assets;
- generated files;
- scripts;
- CI configuration;
- analysis/lint configuration;
- existing source code;
- existing tests;
- existing documentation;
- current git status if available.

Do not assume the starter pack equals the repository state.

The actual repository is the source of truth for what already exists.

---

# 5. CURRENT-STATE AUDIT

For every meaningful requirement in `AD.md`, determine:

- already implemented;
- partially implemented;
- missing;
- implemented differently;
- conflicting;
- blocked;
- unknown.

Use a table:

| AD Requirement | Current Repository Evidence | Status | Gap | Required Action |
|---|---|---|---|---|

Allowed status values:

- IMPLEMENTED
- PARTIAL
- MISSING
- CONFLICT
- BLOCKED
- UNKNOWN

Do not mark something implemented without exact file/path evidence.

---

# 6. LOCKED-DECISION COMPLIANCE AUDIT

Audit the repository against every locked ADR referenced by `AD.md`.

At minimum inspect:

- Flutter + Flame boundary;
- custom 2.5D projection;
- deterministic infinite logical world;
- one progression SSOT;
- Flutter HUD vs world renderer ownership;
- physical Android profile-mode evidence;
- true-3D exclusion from the critical path;
- bounded visible window before explicit pooling;
- minimal dependency policy;
- `flame_audio` sound boundary;
- hybrid asset strategy;
- distance-aware signature asset behavior.

Use:

| Decision | Locked Requirement | Current Evidence | Compliance | Required Fix |
|---|---|---|---|---|

Allowed compliance values:

- COMPLIANT
- PARTIAL
- NON-COMPLIANT
- NOT YET APPLICABLE
- UNKNOWN

---

# 7. PACKAGE AND VERSION VALIDATION

Inspect the actual Flutter project before recommending package changes.

For each package:

- exact package name;
- exact current version if already installed;
- whether it is required by `AD.md`;
- whether it is optional;
- whether it is unnecessary;
- compatibility with current Flutter/Dart constraints;
- reason for inclusion;
- exact architecture concern it owns.

Pay special attention to:

- `flame`
- `flame_audio`
- `vector_math` only if genuinely required

Do not add packages merely because they are popular.

Do not add:

- Riverpod
- Bloc
- Provider
- GetIt
- GoRouter
- Freezed
- Forge2D
- `flame_3d`
- `flutter_scene`
- Unity bridges
- Filament wrappers
- custom GPU frameworks

unless a documented blocker passes the AD re-evaluation gate.

If package information must be verified online, use current official documentation and primary sources.

---

# 8. ASSET AUDIT

Inspect every supplied asset.

Expected starter assets include approximately:

## Environment

- `assets/environment/sky.webp`
- `assets/environment/mountains_far.png`
- `assets/environment/haze.png`
- `assets/environment/foreground_mist.png`
- `assets/environment/castle.png`
- `assets/environment/castle_detail_overlay.png`

## Props

- `assets/props/magic_chest.png`
- `assets/props/crystal_orb.png`
- `assets/props/floating_crystal.png`

Verify:

- actual file existence;
- actual format;
- dimensions;
- alpha/transparency where required;
- likely runtime responsibility;
- whether each should be loaded eagerly or lazily;
- whether dimensions are unnecessarily large;
- whether trimming/compression is advisable;
- whether `pubspec.yaml` includes them;
- whether paths match documentation;
- whether provenance is documented.

Important architecture rule:

Repeated stones, shadows, rings, and most particles should remain procedural.

Do not create one raster asset per node.

For signature assets such as the castle, preserve the locked distance-aware strategy:

- scale by relative depth;
- far-distance haze/fog;
- far-distance reduced clarity/color intensity;
- progressively clearer presentation when approaching;
- optional detail overlay only where justified;
- no gameplay state inside the asset layer.

---

# 9. VISUAL REFERENCE REVIEW

If the original company demo video is available in the repository or supplied alongside this task:

- inspect it carefully;
- identify core behavior;
- separate mandatory experience from bonus details;
- compare the planned implementation against visible behavior;
- identify high-value visual differences.

Do not silently invent requirements not visible in the demo or specified by the AD.

If the demo video is not available, explicitly record:

`VISUAL REFERENCE GAP: original demo video not available to the coding agent`

Do not pretend visual fidelity has been validated without it.

---

# 10. ARCHITECTURE DECOMPOSITION

Using the actual repository plus `AD.md`, produce the smallest concrete implementation decomposition.

The expected conceptual flow is:

```text
SagaMapState.progress
        ↓
SagaScrollPhysics
        ↓
VisibleNodeWindow
        ↓
SagaPath / logical nodes
        ↓
PerspectiveProjector
        ↓
SagaScene
        ↓
SagaMapPainter / renderer
        ↓
Flutter HUD
```

But do not blindly create files merely because names appear in documentation.

For every proposed file/class:

- explain why it must exist;
- identify responsibility;
- identify inputs;
- identify outputs;
- identify owner;
- identify dependencies;
- identify tests;
- identify whether existing code can satisfy the concern.

Use:

| Proposed File / Component | Responsibility | Why Needed | Inputs | Outputs | Depends On | Tests |
|---|---|---|---|---|---|---|

Apply strict anti-redundancy review:

- no interface with one implementation unless protecting a demonstrated boundary;
- no repositories for local rendering logic;
- no service locator;
- no generic event bus;
- no speculative factories;
- no duplicate progress/camera/scroll state;
- no unnecessary state-management package;
- no unnecessary base classes;
- no wrapper around a package merely to hide the package;
- no “clean architecture” ceremony without demonstrated need.

---

# 11. ONE-PROGRESS SSOT PROOF

Explicitly audit and plan how the repository guarantees:

`SagaMapState.progress`

as the sole authoritative movement position.

Velocity may exist in the physics concern.

Derived values may exist transiently.

But do not introduce independent authorities such as:

- `scrollOffset`
- `cameraOffset`
- `worldOffset`
- `visualOffset`
- `mapTranslation`
- `currentStoneOffset`

that can drift independently.

In the plan, include a specific SSOT verification task.

---

# 12. INFINITE-WORLD PLAN

Produce a concrete plan for:

- deterministic `nodeAt(index)`;
- large positive indices;
- negative indices if supported;
- stable path generation;
- visible bounded index range;
- culling;
- no unbounded node storage;
- no unbounded widgets/components;
- no mandatory object pool unless profiling proves need.

Include proof tasks such as:

- simulate very large progression;
- verify bounded visible count;
- verify no duplicate visible indices;
- verify deterministic repeated lookup.

---

# 13. PROJECTION PLAN

Define the task breakdown for the custom 2.5D projection layer.

At minimum cover:

- relative depth;
- scale;
- screen X;
- screen Y;
- horizon behavior;
- culling;
- fog;
- draw ordering;
- finite-value safeguards;
- target-device visual tuning.

Do not turn this into a general-purpose 3D engine.

The projector should remain small, deterministic, and testable.

---

# 14. CASTLE / SIGNATURE ASSET PLAN

Plan the castle as a horizon anchor, not a normal saga node.

Cover:

- logical relative depth;
- projected scale;
- parallax;
- haze;
- opacity;
- tint/color intensity;
- clarity progression;
- detail-overlay blending;
- fallback behavior if overlay quality is insufficient.

The default plan should preserve the staged strategy:

1. main castle asset;
2. depth-based scale;
3. depth-based haze;
4. depth-based color/clarity treatment;
5. detail overlay only where visibly useful.

Do not add multiple arbitrary LOD bands.

---

# 15. INPUT AND PHYSICS PLAN

Plan:

- vertical drag;
- sensitivity;
- progress delta;
- release velocity;
- inertia;
- friction;
- stopping threshold;
- optional snapping only after core movement feels correct.

The physics concern must not render.

The renderer must not mutate progress.

---

# 16. SOUND PLAN

Follow the locked minimal sound architecture.

Plan only:

- optional short selection SFX;
- optional completion/checkmark SFX;
- optional celebration SFX;
- optional ambient loop only after mandatory gates are green.

Use `flame_audio` if package compatibility is validated.

Rules:

- audio reacts to meaningful events;
- audio never owns gameplay truth;
- no generic `AudioManager`;
- no global event bus;
- no multi-backend abstraction;
- audio failure must not block app startup, rendering, or scrolling;
- `AudioPool` only if repeated overlapping playback demonstrates need.

If actual sound assets are absent, mark this clearly and plan a non-blocking fallback.

---

# 17. DEBUG / ARCHITECTURE PROOF PLAN

Plan a toggleable debug mode that can demonstrate architecture during the interview.

Potential values:

- FPS;
- progress;
- current logical index;
- visible node count;
- renderer strategy;
- projection diagnostics.

Also plan optional projection-debug visualization.

Do not fake metrics.

Every displayed metric must derive from real runtime state.

---

# 18. PERFORMANCE VALIDATION PLAN

Create concrete tasks for real Android performance proof.

Required:

- chosen physical Android device;
- Flutter profile mode;
- real continuous-scroll scenario;
- bounded visible-node verification;
- DevTools Performance inspection;
- evidence capture;
- findings document;
- no invented FPS claims.

Specify:

- scenario duration;
- what is measured;
- expected evidence;
- what constitutes pass/fail;
- fallback actions if jank appears.

Do not use debug-mode smoothness as proof.

Do not use emulator-only results as final evidence.

---

# 19. TEST PLAN

Create the smallest high-value test suite.

At minimum consider:

## `SagaPath`

- same index → same result;
- large index → finite valid result;
- path presets differ intentionally.

## `VisibleNodeWindow`

- bounded count;
- progression shifts range;
- no duplicate indices;
- very large progress remains bounded.

## `PerspectiveProjector`

- farther nodes project smaller;
- farther nodes move toward horizon;
- values remain finite;
- behind-camera nodes are culled.

## `SagaScrollPhysics`

- drag changes progress;
- release inertia continues;
- friction decays velocity;
- velocity settles.

## Architecture invariant

- after simulated extremely large travel, visible work remains bounded.

Do not create low-value tests merely to increase count.

---

# 20. TWO-DAY EXECUTION PLAN

Produce a realistic two-day plan.

The plan must respect dependencies and gates.

At minimum separate:

## Day 1

- repository/bootstrap validation;
- package setup;
- SSOT/state skeleton;
- deterministic world;
- bounded visible window;
- projection;
- basic rendering;
- drag;
- inertia;
- castle;
- depth;
- fog;
- Android runnable proof.

## Day 2

- tests;
- debug overlay;
- projection debug mode;
- HUD;
- state visuals;
- distance-aware asset polish;
- optional sound;
- physical Android profile evidence;
- performance fixes only when measured;
- documentation;
- final cleanup;
- interview presentation flow.

But adapt this to the actual repository state.

Do not list work that already exists.

---

# 21. EXECUTION WAVES AND DEPENDENCIES

Break every task into execution waves.

Each task must include:

- Task ID
- Title
- Concern
- Exact file paths
- Preconditions
- Dependencies
- Implementation action
- Acceptance criteria
- Verification command or method
- Evidence required
- Risk
- Fallback
- Suggested agent role
- Parallel-safe yes/no

Use a table or structured blocks.

Example shape:

```text
TASK-001
Title:
Concern:
Files:
Depends on:
Preconditions:
Action:
Acceptance criteria:
Verification:
Evidence:
Risk:
Fallback:
Owner role:
Parallel-safe:
```

No vague tasks such as:

- “implement rendering”
- “add performance”
- “polish UI”

Every task must be executable and verifiable.

---

# 22. PARALLEL AGENT PLAN

We may use multiple coding agents.

Design the plan so agents do not duplicate work.

Use the ownership model from `AD.md`.

At minimum consider roles such as:

- architecture guardian;
- world/infinity;
- projection/rendering;
- input/physics;
- UI/assets;
- verification/performance.

For every task identify:

- exclusive owner;
- files owned;
- dependency boundaries;
- whether another agent may work in parallel.

Do not allow two agents to independently implement the same concern.

Do not allow agents to invent alternative architecture.

---

# 23. REDUNDANCY AUDIT BEFORE FINALIZING THE PLAN

Before writing the final plan, actively attack it.

For every proposed:

- class;
- interface;
- service;
- package;
- file;
- state value;
- abstraction;

ask:

1. Is this required now?
2. Does existing code already own this?
3. Is there a second real implementation?
4. Could a simpler function/data class solve it?
5. Does this duplicate `progress`?
6. Is this architecture ceremony?
7. Will the developer be able to explain it in the interview?

Remove unnecessary items before presenting the plan.

Include a section:

`REDUNDANCY REMOVED FROM PLAN`

listing anything you deliberately rejected.

---

# 24. RISK AND FALLBACK AUDIT

For major risks include:

- Flame integration delay;
- package incompatibility;
- asset quality mismatch;
- castle detail overlay mismatch;
- transparency/compositing issue;
- blur/shader jank;
- infinite-window bug;
- projection instability;
- drag feel problems;
- audio lifecycle issue;
- physical-device jank;
- agent merge conflicts;
- documentation drift.

For each:

| Risk | Warning Sign | Mitigation | Fallback | Stop Condition |
|---|---|---|---|---|

Use fallbacks already defined by the authoritative docs where applicable.

---

# 25. PLAN QUALITY GATE

Before outputting the plan, verify:

- every `AD.md` must-ship requirement has tasks;
- every locked ADR is respected;
- every major task has exact files;
- every task has acceptance criteria;
- every task has verification;
- dependencies are explicit;
- parallelism is safe;
- no duplicate progress SSOT exists;
- no unnecessary package is introduced;
- no speculative production architecture exists;
- physical Android performance proof exists;
- asset work is covered;
- sound is non-blocking;
- original demo reference gap is stated if unavailable;
- two-day scope is realistic;
- optional work cannot block mandatory gates.

---

# 26. REQUIRED OUTPUT FILE

Create:

`IMPLEMENTATION_PLAN_PROPOSAL.md`

It must contain, in this order:

1. Non-authoritative warning
2. Executive summary
3. Repository inventory
4. Current-state audit
5. AD compliance matrix
6. Locked-decision compliance audit
7. Documentation inconsistencies or ambiguities
8. Package/version audit
9. Asset audit
10. Visual-reference status
11. Proposed minimal file/module map
12. One-progress SSOT proof plan
13. Infinite-world implementation plan
14. Projection plan
15. Castle/distance-aware asset plan
16. Input/physics plan
17. Sound plan
18. Debug/architecture-proof plan
19. Performance validation plan
20. Test plan
21. Full task dependency graph
22. Detailed task list with exact paths
23. Parallel-agent ownership matrix
24. Day 1 schedule
25. Day 2 schedule
26. Must now / optional / do-not-do split
27. Risk/fallback matrix
28. Redundancy removed from plan
29. Missing information/blockers
30. Final pre-execution gate
31. Proposed mapping of accepted tasks into the authoritative `AD.md` progress section

---

# 27. ABSOLUTE STOP RULE

After creating `IMPLEMENTATION_PLAN_PROPOSAL.md`:

STOP.

Do not implement any task.

Do not edit Dart files.

Do not edit Flutter code.

Do not install dependencies.

Do not modify Android configuration.

Do not modify `pubspec.yaml`.

Do not move assets.

Do not begin Wave 1.

Present only:

1. where the plan file was created;
2. number of planned tasks;
3. critical blockers, if any;
4. highest-risk assumptions;
5. whether the plan is ready for human approval.

Then wait for explicit approval.

---

# 28. TRUTHFULNESS RULE

Never claim:

- a file exists unless verified;
- a feature works unless executed and verified;
- an asset is transparent unless technically inspected;
- performance is good unless profiled;
- a package version is compatible unless checked;
- the visual result matches the demo unless compared;
- a task is complete during this planning phase.

Unknown means unknown.

Missing evidence must be stated.

---

# BEGIN

Now:

1. read `AD.md` in full;
2. read `ARCHITECTURE_DECISIONS.md` in full;
3. read every other Markdown file;
4. inspect the complete repository;
5. inspect all supplied assets;
6. inspect the original demo video if available;
7. create `IMPLEMENTATION_PLAN_PROPOSAL.md`;
8. stop before execution.
