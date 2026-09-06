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
- Pause overlay opened with the standard UI cancel action
- Resume and Settings menu buttons
- Settings panel for music, SFX, and screen-shake preferences
- Persistent local settings using a Godot ConfigFile
- Keyboard/controller-friendly button focus setup
- Main HUD updated with pause/settings hint
- Dedicated menu and settings scripts/scenes

**Status: Complete**

## Phase 9 — Economy / Ads / Monetization
- Fictional in-game Credits economy
- Persistent Credits and total-earned storage with ConfigFile
- Survival-time run reward calculation
- Credits HUD integration
- Rewarded-ad provider abstraction hook without a live ad SDK
- Placeholder reward callback designed for future verified provider callbacks
- Economy foundation ready for store-platform integration in later QA/release work

**Status: Complete**

## Phase 10 — Testing / Optimization / QA
- Fixed the support-drone orbit/pulse implementation
- Connected run-end survival rewards to the actual game-over path
- Prevented duplicate run rewards
- Reduced unnecessary per-frame Credits HUD updates
- Added a dedicated Phase 10 QA checklist covering gameplay, UI, progression, economy, and persistence
- Documented manual runtime validation and profiler checks

**Status: Complete — repository QA pass finished; Godot runtime validation remains manual**

## Phase 11 — Release / Store Preparation
- Release and store-readiness checklist
- Android / Google Play AAB release guidance
- Current Google Play target API requirement recorded (Android 16 / API 36+)
- Release signing and secret-handling safeguards documented
- Versioning policy documented
- Store assets and Play Console manual gates documented
- Final clean-checkout release gate documented

**Status: Complete — repository release preparation finished; final local export and Play Console submission remain manual**
