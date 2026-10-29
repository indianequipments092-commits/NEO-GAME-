# NEON 3D BATTLE ROYALE

A Godot 4 third-person 3D island-combat prototype. This project is being rebuilt on a separate feature branch from the earlier 2D space-survival game.

## Prototype status

- Procedurally generated island with ocean edge, roads, simple houses and trees.
- Third-person player controller, camera look, keyboard movement and hitscan rifle.
- 49 lightweight offline bots (50 combatants including the player) for an early scale smoke test.
- Health, elimination/win state, timer, restart and touch-friendly movement/fire buttons.
- Godot Web and Android export presets plus a GitHub Actions validation/build workflow.
- Legacy 2D assets and scripts are retained for rollback; no legacy files are deleted in this phase.

## Controls

### Desktop
- **WASD / Arrow keys** — Move
- **Mouse movement** — Look around (click to recapture the mouse)
- **Left mouse / Space** — Fire
- **Esc** — Release/capture mouse
- **R** — Restart after elimination or victory

### Touch
- On-screen arrow buttons — Move
- **FIRE** — Shoot

## Build and test

GitHub Actions workflow: `.github/workflows/android-apk.yml`

The workflow imports and runs the project headlessly, then exports:
- Android debug APK
- Web build (`build/web/index.html` plus generated assets)

Download the artifacts from the workflow run. A Web export is not a hosted deployment by itself; deploy the generated `build/web` contents to a static host such as Vercel only after verifying the artifact.

## Known prototype limitations

- The island and character are generated from primitive meshes; this is a functional greybox, not final photorealistic art or animation.
- Bots are local AI, not online players. Online multiplayer, matchmaking, authoritative server and anti-cheat are future work.
- Browser and Android builds need actual CI/device/browser validation; do not infer release readiness from the presence of export configuration.
- Touch movement/fire are implemented; mobile camera-look gestures and final performance tuning remain follow-up work.

## Safety and migration

See [the exact migration manifest](docs/NEON_3D_MIGRATION_MANIFEST.md). `main` remains the baseline branch, and legacy 2D files are not deleted.
