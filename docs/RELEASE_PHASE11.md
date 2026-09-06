# NEON SPACE SURVIVAL — Phase 11 Release / Store Preparation

## Release readiness checklist

### Project identity
- [x] Application name is `NEON SPACE SURVIVAL`.
- [x] Main scene is configured as `res://scenes/main.tscn`.
- [x] Repository uses `main` as the release branch.

### Android / Google Play
- [x] Android export is documented as the release target.
- [x] Google Play release format is documented as Android App Bundle (`.aab`).
- [x] Release builds must disable debug export.
- [x] Non-debug release signing is required.
- [x] Keystore credentials are explicitly kept outside source control.
- [x] Target API 36+ is recorded for current Google Play new-app/update submission requirements.
- [ ] Configure the final Android export preset in the local Godot editor with the project's chosen package ID.
- [ ] Configure release keystore/signing credentials locally or through the secure build environment.
- [ ] Export a release `.aab` and verify it installs/opens on a test device.

### Store assets and metadata
- [x] Store preparation checklist created.
- [ ] Final launcher/adaptive icon assets supplied and assigned in the Android export preset.
- [ ] Final screenshots prepared from a verified release build.
- [ ] Final short/full store descriptions reviewed.
- [ ] Content rating and target-audience declarations completed in Play Console.
- [ ] Privacy/data-safety declarations completed based on the final shipped SDKs and data behavior.
- [ ] App content declarations completed in Play Console.

### Security / repository hygiene
- [x] No release keystore or signing password is stored in the repository.
- [x] No live advertising SDK credentials are stored in the repository.
- [x] Rewarded-ad functionality remains an integration placeholder until a compliant provider is deliberately configured.
- [ ] Final release build must be generated from a clean checkout and reviewed before upload.

## Versioning policy

Use semantic product versioning for human-readable releases and a monotonically increasing Android version code for Play uploads. Do not reuse an Android version code after an upload.

## Final release gate

Phase 11 is considered **release-preparation complete** when the repository-side configuration and documentation are ready. Actual publication remains a manual owner-controlled step because signing credentials, Play Console declarations, final store assets, and the exported AAB must be supplied securely outside the public repository.

## Current status

**Phase 11 — Repository release preparation complete; final local export and Play Console submission remain manual.**
