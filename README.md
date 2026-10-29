# NEON 3D BATTLE ROYALE

A Godot 4 third-person offline battle-royale prototype, developed on a separate feature branch from the legacy 2D space-survival game.

## Current vertical-slice foundation

- Compact test area with collision-backed building shells, doorway openings, floor/roof collision and tree-trunk collision.
- Third-person spring-arm camera with camera collision, keyboard/mouse look and right-side touch-drag look.
- Basic walk, sprint, crouch and jump controls.
- Eight local test bots for a smaller, easier-to-profile slice; bot damage now requires line of sight.
- HUD controls reposition when the viewport changes size, with touch movement, jump and fire buttons.
- Existing procedural meshes are still placeholders. The high-quality visual benchmark is not complete because game-ready character/environment assets have not yet been integrated.
- Android and Windows are the target platforms. The existing CI workflow still also exports Web until a separate workflow decision is approved.

## Controls

### Desktop
- WASD / Arrow keys — Move
- Mouse movement — Look around (click to capture mouse)
- Shift — Sprint
- Ctrl — Crouch
- E — Jump
- Space / left mouse button — Fire
- Esc — Release/capture mouse
- R — Restart after elimination or victory

### Touch
- Left-side arrow buttons — Move
- JUMP — Jump
- Right-side drag — Look around
- FIRE — Fire

## Build and test

GitHub Actions workflow: .github/workflows/android-apk.yml

The workflow imports/runs the project headlessly and exports the configured Android debug APK and Web build. Windows export is not currently configured in CI; the PC build path needs to be added and tested in a later approved step.

## Known limitations

- The current character, houses, trees and world still use procedural primitive meshes; they are not final realistic art.
- Player movement and bot visibility logic have been improved, but real-device input, collision feel and AI behaviour still require manual playtesting.
- The bots are local AI, not online players. Multiplayer, matchmaking and server infrastructure are future work.
- No Android/Windows FPS, memory or thermal results are claimed until measured on actual target hardware.

## Safety and migration

See the migration manifest. The legacy 2D files are retained, and main must remain untouched.
