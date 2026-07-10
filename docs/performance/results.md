# Saga Map Performance Results

Date: 2026-07-10

## Environment

- Flutter: 3.44.5 stable
- Dart: 3.12.2
- DevTools: 2.57.0
- Flame: `^1.37.0`
- flame_audio: `^2.12.1`
- Verified build modes: debug APK and profile APK

## Devices

The final verification used a physical Android presentation device:

- Google Pixel 7 Pro, Android 16 API 36, arm64, 120 Hz display

Emulator compatibility was also checked on:

- Medium Phone, sdk gphone64 arm64, Android 15 API 35
- Pixel 10 Pro AVD, sdk gphone16k arm64, Android 17 API 37

The earlier emulator package-service failure no longer reproduces. Both AVDs and the physical device built, installed, and launched the current profile APK successfully.

## Validation Completed

```sh
flutter analyze
flutter test
flutter build apk --debug
flutter run -d 35171FDH3001PS --profile
```

Results:

- analyzer: no issues
- full suite: 70/70 passing
- debug APK: built at `build/app/outputs/flutter-apk/app-debug.apk`
- profile APK: built and launched on the physical Pixel 7 Pro and both configured Android AVDs

## Scenario

The physical profile scenario ran for 30 seconds and included 25 automated forward swipes, repeated step transitions, reward collection, and five header-plus transitions to exercise the major combo path. It completed without an app crash, Flutter exception, or skipped-frame report. The post-run screen preserved completed/current/upcoming states, a continuous path to the castle, fixed HUD placement, and responsive counter updates. Unit and integration tests independently prove the visible window remains bounded at large progress.

Configured logical window:

- level 0: 15 indices
- later levels: 17 indices

## Emulator Findings

The API 37 AVD produced valid screenshots for idle, progression, reward flight, and lightning-combo review. It was not valid performance evidence: DevTools showed approximately 1 FPS with a sampled slow frame around 531 ms UI / 1351 ms raster while QEMU consumed roughly 140% host CPU and the guest spent about 44% CPU in kernel work.

The API 35 AVD used roughly 7% host CPU and launched profile mode without a skipped-frame warning, but its compositor returned black screenshots and exposed no Flutter frames to the DevTools Performance view. No frame-time claim is derived from that run.

Android `gfxinfo` reported zero Flutter SurfaceView frames under Impeller and was rejected as timing evidence.

## Physical Device Findings

Flutter DevTools Performance recorded a 120 FPS average during the controlled 30-second traversal on the Pixel 7 Pro. Most visible UI and raster work stayed around 1-3 ms, below the 8.33 ms budget of the 120 Hz display. DevTools reported three isolated slow frames during the combined traversal and reward trigger; there was no persistent jank pattern.

Impeller used the Vulkan backend. The Flutter run log contained no unhandled exceptions, rendering overflows, asset failures, or skipped-frame warnings during the scenario. Ordinary Android lifecycle and resource-release warnings were not associated with a visual or functional failure.

## Conclusion

The mandatory physical Android profile gate passes. The app sustained the presentation device's 120 Hz target on average, rendered a bounded world window, preserved visual state through progression, and completed sustained traversal without a crash or persistent jank. The three isolated slow frames remain a small optimization target, not a release-blocking pattern.
