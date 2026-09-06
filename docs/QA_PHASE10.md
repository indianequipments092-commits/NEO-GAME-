# NEON SPACE SURVIVAL — Phase 10/Final QA Checklist

## Repository-side fixes completed
- [x] Fixed the support-drone orbit/pulse implementation.
- [x] Added real enemy health, projectile damage, defeat, and XP reward handling.
- [x] Added real boss health, projectile damage, defeat, and XP reward handling.
- [x] Separated XP-orb collision from combat-target collision so energy projectiles do not consume XP orbs.
- [x] Verified the run-end reward path is invoked before the game is paused.
- [x] Prevented repeated run rewards with `run_reward_claimed`.
- [x] Removed the per-frame Credits HUD refresh.
- [x] Added a game-over restart button that reloads the current run safely.
- [x] Added Android touch controls that reuse the desktop input actions.
- [x] Added release project metadata and launcher icon.
- [x] Rewarded-ad integration remains a placeholder and does not include a live ad SDK.

## Manual Godot QA to perform
1. Launch `main.tscn` and confirm the player moves inside the arena.
2. Hold Space and confirm energy projectiles spawn and the combat counter increases.
3. Confirm projectiles damage enemies and enemies disappear after enough hits.
4. Confirm defeated enemies create XP rewards and collecting them updates the XP/level HUD.
5. Use module keys after leveling: `1` engine, `2` core, `3` drone.
6. Confirm the drone follows the player in an orbit and periodically shows `DRONE PULSE`.
7. Confirm enemies spawn from arena edges and contact damage reduces hull.
8. Survive to 60 seconds and confirm the boss indicator appears and pulses.
9. Confirm the boss takes projectile damage, updates its health display, and can be defeated.
10. Confirm the run ends at zero hull and a survival-time Credit reward is added once.
11. Confirm `RESTART RUN` reloads a fresh run even while the game is paused.
12. Open pause/settings and confirm resume/settings navigation works.
13. Restart the game and confirm saved Credits and settings persist.
14. On a touch device, confirm movement and FIRE buttons appear and drive the same controls.
15. On a non-touch desktop, confirm mobile controls remain hidden.
16. Test a release export on a real target device before publishing.

## Performance / optimization checks
- Credits HUD is not rewritten every frame.
- XP/enemy spawning uses bounded intervals.
- Projectiles and defeated targets clean themselves up.
- Use Godot's Debugger/Profiler during a long run to inspect frame time, object counts, and script hotspots.

## Release checks
- Verify project version and launcher icon.
- Configure the final Android package ID in the local Godot export preset.
- Use a non-debug release keystore stored outside the repository.
- Export a signed Android App Bundle (`.aab`) and install/test it on a target device.
- Complete the applicable store, content, privacy/data-safety, and age/target-audience declarations based on the final shipped build.

## Validation status

The repository-side fixes are committed. A full runtime/export test still requires opening/running the project in a Godot 4 environment; this environment cannot independently execute the Godot project. Do not treat the game as publication-validated until the manual checklist passes on the target device(s).
