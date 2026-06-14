# Security & Data Privacy Review

**Date:** 2026-06-14

## Data Management

- **Local Persistence:** Data is stored using Isar (NoSQL) in the app's private directory.
- **Export/Delete:** Users can export their entire data history via JSON and delete all local data through the Settings menu.
- **Encryption:** Leveraging OS-level file system encryption for private app directories on both iOS and Android.

## Code Security

- **Debug Logs:** Verified that no sensitive data is logged via `print` or `log` in production builds.
- **Secrets:** Checked for hardcoded API keys or credentials; none found.
- **Proguard/R8:** Enabled for Android release builds to obfuscate code.

## Privacy Compliance

- **Tracking:** Zero third-party tracking or analytics SDKs implemented (privacy-first).
- **Permissions:** Requesting minimal permissions (Storage for exports, Notifications for rest timers).

## Status

✅ SECURE - No high or medium risks identified for V1 release.
