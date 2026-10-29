# NEON 3D Battle Royale — Updater implementation report

## Scope
Branch: feature/neon-3d-battle-royale
Base commit: 1f9873bd479056bc02912e791e9d9c72734be515
Godot target: 4.6.3
Targets: Android APK with user-confirmed install; Windows desktop update helper.

## Implemented in this change
- Added an in-game update button and startup check for the latest GitHub Release manifest.
- Added trusted-host URL validation, semantic-version comparison, download progress/status, and SHA-256 verification before installation.
- Added Android Godot plugin v2 source to open the Android package installer using a FileProvider cache URI; installer confirmation is required.
- Added a Windows PowerShell updater that stages the update, waits for the game process, backs up replaced files, rolls back on failure, and relaunches.
- Added Gradle plugin project and CI build steps for debug/release AARs.
- Added Windows export preset and a tagged-release workflow that requires release-signing secrets and publishes APK, Windows ZIP, and a checksum manifest.
- Added updater design and operational requirements documentation.

## Verification status
- Source-level review: performed against the current repository files and Godot 4.6 Android plugin v2 documentation.
- Python manifest generator unit test: pending CI.
- Godot parser/import: pending the new GitHub Actions run.
- Android Gradle AAR compilation: pending CI.
- Android APK export: pending CI; release APK also requires correctly configured GitHub signing secrets.
- Windows export: pending CI.
- Web export: pending CI.
- Android real-device install/update flow: NOT TESTED here.
- Windows helper replacement/rollback on a Windows machine: NOT TESTED here.
- Silent Android install: intentionally not supported.
- Main branch and legacy file preservation: must be verified by the resulting branch comparison.

## Known risks
- The currently installed APK must share the release signing certificate with future update APKs.
- Android's “install unknown apps” permission can require an extra trip to system settings.
- Windows updates only work in a directory writable by the current user.
- A checksum verifies package consistency, not publisher identity; GitHub Release access and HTTPS remain trusted.
- Release signing secrets are not present in the repository and must be configured by the repository owner.
