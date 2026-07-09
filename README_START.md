# Saga Map POC Starter Pack

This zip contains the two authority docs plus the generated art assets prepared for immediate Flutter use.

## Included
- `AD.md` — implementation source of truth
- `ARCHITECTURE_DECISIONS.md` — rationale and comparisons
- `docs/assets.md` — asset inventory
- `assets/environment/*`
- `assets/props/*`

## Suggested next steps
1. Create your Flutter project/repo.
2. Copy the `assets/` folder into the repo root.
3. Copy `AD.md` and `ARCHITECTURE_DECISIONS.md` into the repo root.
4. Add the asset entries below to `pubspec.yaml`.
5. Begin implementation from `AD.md`.

## `pubspec.yaml` snippet
```yaml
flutter:
  assets:
    - assets/environment/sky.webp
    - assets/environment/mountains_far.png
    - assets/environment/haze.png
    - assets/environment/foreground_mist.png
    - assets/environment/castle.png
    - assets/environment/castle_detail_overlay.png
    - assets/props/magic_chest.png
    - assets/props/crystal_orb.png
    - assets/props/floating_crystal.png
```

## Notes
- Stones, rings, shadows, and most effects remain procedural.
- Audio is not included in this starter pack.
