# NEON 3D Battle Royale — Automatic updater

## Scope and status

This updater is designed for the `feature/neon-3d-battle-royale` branch. The legacy 2D game and `main` branch are outside the scope.

- Android: check for a GitHub Release, download the APK, verify its SHA-256 hash, then open Android's package installer. User confirmation is required. On Android 8+, the user may need to allow this app to request package installs in system settings.
- Windows: download and verify a ZIP, start a separate PowerShell helper, close the game, replace the exported executable, and relaunch it. The install directory must be writable by the current Windows user. It is not designed to bypass Windows permissions.
- Offline: the current installed build remains playable; update checks fail gracefully and can be retried.
- Release creation: tags such as `v0.3.0` trigger the release workflow. The workflow intentionally fails if Android release-signing secrets are missing.

## Manifest schema

The release asset `update-manifest.json` contains:

- `schema_version`: integer schema version
- `version`: semantic version without the leading `v`
- `notes`: short release note
- `android.url`, `android.sha256`
- `windows.url`, `windows.sha256`

The updater accepts only HTTPS release URLs under this repository's GitHub Releases download path, compares semantic version components, and checks the downloaded file's SHA-256 before handing it to an installer/helper. SHA-256 detects corrupted or mismatched downloads; it is not a digital signature. HTTPS and the trusted GitHub repository/release permissions remain part of the trust boundary.

## Android requirements

Godot 4.6.3's Android plugin v2 requires a Gradle build and a custom Android build template. The plugin's AAR is built in CI from `android-updater-plugin/`, then copied into ignored generated paths under `addons/neon_android_updater/bin/` for export. The plugin uses Android's package installer and a FileProvider cache URI; it never silently installs an APK.

The app package ID remains `com.indianequipments.neon3dbattleroyale`. Release APKs must use the same release keystore as prior releases or Android will reject an in-place update. GitHub Actions secrets required for tagged release builds:

- `ANDROID_KEYSTORE_BASE64`: base64-encoded release keystore
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_ALIAS`

Never commit the keystore or passwords. If a currently installed APK was signed with a different key, one manual uninstall/reinstall transition may be needed and can remove app-private data.

## Windows requirements

The Windows export uses a self-contained executable with the PCK embedded. The helper waits for the game process to exit, stages the ZIP, backs up files it replaces, rolls back copied files on failure, and relaunches the executable. It does not elevate privileges; use a user-writable install directory such as a folder under the user's profile.

## Tests and release checks

- Python manifest generation should be tested with temporary fixture files; checksums must match the exact bytes.
- GDScript parsing/import, Android Gradle plugin compilation, Android export, Windows export and Web export are CI checks.
- Android installer behavior must still be manually tested on a real device, including the first-run “install unknown apps” settings path.
- Windows replacement/recovery must be tested on a Windows machine before describing it as production-ready.
- Never report a device install or Windows in-place update as tested unless it was actually run on target hardware.
