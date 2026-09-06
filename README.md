# NEON SPACE SURVIVAL

A fast-paced neon space survival roguelite built with Godot 4.

## Current status

**Phases 1–11: repository implementation complete.**

The project now includes the core survival loop, movement, energy combat, XP/levels, enemies and boss content, ship modules and drone support, polish foundations, pause/settings UI, in-game Credits economy hooks, QA documentation, release metadata, and Android touch controls.

## Controls

### Desktop
- **WASD / Arrow keys** — Move
- **Space** — Fire energy
- **1 / 2 / 3** — Install Engine / Core / Drone modules when upgrade points are available
- **Esc** — Pause / Settings

### Android / touch
On touch devices, the on-screen movement and FIRE controls appear automatically. They drive the same input actions as desktop controls.

## Gameplay systems

- Bounded survival arena
- Survival timer and HUD
- Energy projectile combat
- XP orbs, levels, and upgrade points
- Enemy spawning and contact damage
- Boss encounter at 60 seconds with health, damage, defeat, and XP reward
- Engine, Core, and Drone modules
- Autonomous orbiting support drone with periodic pulse feedback
- Persistent fictional in-game Credits
- Run-end Credit reward with duplicate-claim protection
- Pause/settings UI with persistent local preferences

## Release

The release preparation checklist is in `docs/RELEASE_PHASE11.md`.

For Android/Google Play, the final local build still requires a configured Godot Android export preset, final package ID, release signing credentials, a release AAB, device testing, and Play Console declarations. **Never commit keystores, passwords, API keys, or other signing secrets.**

## QA

`docs/QA_PHASE10.md` contains the manual Godot runtime checklist. Repository-side fixes are committed, but a real Godot runtime/export test still needs to be performed in a Godot 4 environment before publishing.

## Repository

- Default branch: `main`
- Project name: `NEON SPACE SURVIVAL`
- Engine: Godot 4
