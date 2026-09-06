# NEON SPACE SURVIVAL — Development Phases

## Phase 1 — GitHub Base & Project Setup
- Repository foundation
- README and ignore rules
- Godot 4 project configuration
- Bootstrap main scene
- Basic input actions
- Initial project folder structure

**Status: Complete**

## Phase 2 — Core Gameplay
- Playable player scene and controller
- 8-direction movement with acceleration and friction
- Bounded survival arena with collision walls
- Main gameplay scene and startup flow
- Survival timer HUD
- Basic gameplay feedback/instructions

**Status: Complete**

## Phase 3 — Combat
- Fictional energy projectile scene using Area2D overlap detection
- Player firing control with a configurable fire interval
- Direction memory so energy follows the player's last movement direction
- Projectile lifetime and automatic cleanup
- Generic `take_damage()` hook for future damageable targets
- Combat counter HUD and Space-key control hint

**Status: Complete**

## Phase 4 — XP / Level / Roguelite Progression
- Collectible green XP orb scene
- Automatic XP orb spawning in the survival arena
- Player XP tracking and collection
- Level-up threshold and increasing XP requirements
- Level counter and XP progress HUD
- Upgrade-point reward on level-up for future roguelite choices
- Progression hooks ready for Phase 5+ content

**Status: Complete**

## Phase 5 — Enemies / Bosses / World Content
- Basic pursuing enemy scene with collision-based contact hazard behavior
- Enemy spawning from arena edges during the survival run
- Player hull/health system with brief contact invulnerability
- Hull status HUD and run-ended state
- Large boss encounter that appears after 60 seconds
- Boss encounter HUD indicator and pulsing visual
- XP spawning hooks retained for future enemy defeat rewards
- Phase 5 world-content foundation ready for Phase 6

**Status: Complete**

## Phase 6 — Ships / Drones / Modules / Meta Progression
- Support drone scene with orbital follow behavior
- Drone pulse callback connected to the player
- Engine module that improves movement speed
- Core module that improves energy fire cadence
- Drone module that deploys the support drone
- Upgrade-point spending through simple in-game module controls
- Module level HUD with engine/core/drone levels
- Meta-progression core hooks for future persistent progression
- Ship progression foundation ready for Phase 7+ polish

**Status: Complete**

## Phase 7 — Polish / VFX / Audio / Game Juice
- Procedural animated starfield background
- Lightweight gameplay juice controller
- Pulsing boss encounter indicator
- HUD feedback/tween hook for future events
- Polish-ready structure for particles and audio integration
- Visual/gameplay feedback foundation ready for Phase 8

**Status: Complete**

## Phase 8 — UI / Menus / Settings
Planned.

## Phase 9 — Economy / Ads / Monetization
Planned.

## Phase 10 — Testing / Optimization / QA
Planned.

## Phase 11 — Release / Store Preparation
Planned.
