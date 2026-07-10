# Asset Inventory

This starter pack contains the generated environment and prop assets needed to begin implementing the saga-map POC.

## Environment
- `assets/environment/sky.webp` — opaque sky background.
- `assets/environment/mountains_far.png` — transparent distant mountain panorama layer.
- `assets/environment/haze.png` — transparent haze/cloud atmosphere layer.
- `assets/environment/foreground_mist.png` — transparent foreground mist layer.
- `assets/environment/castle.png` — transparent main castle asset.
- `assets/environment/castle_detail_overlay.png` — transparent detail overlay for distance-aware castle clarity.

## Props
- `assets/props/magic_chest.png` — transparent reward chest prop.
- `assets/props/crystal_orb.png` — transparent crystal orb prop.
- `assets/props/floating_crystal.png` — transparent floating crystal prop.
- `assets/props/saga_book.png` — generated story-book HUD icon.
- `assets/props/snowflake.png` — generated challenge HUD icon.
- `assets/props/trophy.png` — generated achievement HUD icon.
- `assets/props/magic_lamp.png` — generated hint HUD icon.
- `assets/props/gift_box.png` — generated reward HUD icon.
- `assets/props/reward_star.png` — generated source variant retained for art reference; runtime collection uses the VFX-pack star.

## VFX
- `assets/vfx/lightning_combo/frame_0.png` through `frame_7.png` — generated transparent lightning sequence from the supplied Saga Map VFX pack.
- `assets/vfx/lightning_residual_streak.png` — generated transparent combo after-image.
- `assets/vfx/reward_star.png` — generated transparent collection star.
- `assets/vfx/sparkle.png` — generated transparent trail/ambient sparkle.
- `assets/vfx/soft_glow.png` — generated transparent current-node/combo glow.
- `assets/vfx/lightning_sweep.png`, `blue_slash_frames.png`, `sparkle_gold.png`, and `magic_portal.png` — generated working-source variants; currently not loaded by the runtime.

## Source / provenance
All art assets were generated specifically for this project in the current ChatGPT sessions. The VFX-pack files were supplied by the project owner and prepared as transparent RGBA assets. No third-party marketplace assets are included.

## Notes
- Repeated stones, shadows, rings, and particles remain procedural and are not included as raster assets.
- Audio is intentionally not included in this pack.
- If desired, you can still regenerate any single art asset later with a stronger style match once coding is underway.
