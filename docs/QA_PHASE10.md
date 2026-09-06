# NEON SPACE SURVIVAL — Phase 10 QA Checklist

## Automated / Static QA
- [x] Fixed the Phase 6 support-drone orbit/pulse script so it has a complete `_process()` implementation.
- [x] Verified the run-end reward path is invoked before the game is paused.
- [x] Prevented repeated run rewards with `run_reward_claimed`.
- [x] Removed the per-frame Credits HUD refresh; Credits now update when the economy changes.
- [x] Rewarded-ad integration remains a placeholder and does not include a live ad SDK.

## Manual Godot QA to perform
1. Launch `main.tscn` and confirm the player can move inside the arena.
2. Hold Space and confirm energy projectiles spawn and the combat counter increases.
3. Collect XP and confirm level/XP HUD updates and upgrade points are awarded.
4. Use module keys after leveling: `1` engine, `2` core, `3` drone.
5. Confirm the drone follows the player in an orbit and periodically shows `DRONE PULSE`.
6. Confirm enemies spawn from arena edges and contact damage reduces hull.
7. Survive to 60 seconds and confirm the boss indicator appears and pulses.
8. Confirm the run ends at zero hull and a survival-time Credit reward is added once.
9. Open pause/settings and confirm resume/settings navigation works.
10. Restart the game and confirm saved Credits persist.

## Performance / Optimization Notes
- Credits HUD is no longer rewritten every frame.
- Existing spawn intervals remain bounded during the first minute; XP spawning continues as the intended progression source.
- Use Godot's Debugger/Profiler during a long run to inspect frame time, object counts, and script hotspots.

## Validation Status

The repository-side QA fixes are committed. A full runtime test still requires opening/running the project in a Godot 4 editor or executable environment; this environment has not independently executed the Godot project.
