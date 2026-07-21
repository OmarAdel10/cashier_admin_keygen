# CashierAdminKeygen — AGENTS.md

## Stack
- Flutter stable (Dart ^3.12.2), Material 3, dark theme, indigo seed
- State: Provider (`ChangeNotifier`, `ValueNotifier`)
- Crypto: `ed25519_edwards` — Ed25519 signing via seed stored in `flutter_secure_storage`

## Architecture
- **Feature-first** with `lib/core/` shared layer
- `lib/core/models/` — `ActivationKey`, `Failure`
- `lib/core/services/` — `GatekeeperService` (biometric auth via `local_auth`), `KeyManager` (seed gen/sign via `flutter_secure_storage`)
- `lib/features/auth/` — biometric gate (`AuthProvider` + `AuthGateScreen`)
- `lib/features/setup/` — first-run keypair gen/import (`SetupProvider` + `SetupScreen`)
- `lib/features/keys/` — device ID input (manual + QR scan via `mobile_scanner`), signing, display (`KeygenProvider` + `KeyGenScreen`)
- Entry: `lib/main.dart` → `AuthGateScreen` → if authed → `KeyGenScreen` (redirects to `SetupScreen` if no keys)

## Key Flows
1. App starts → `AuthProvider` triggers biometric prompt via `GatekeeperService`
2. After auth → `KeyGenScreen` checks `KeyManager.hasKeyPair()` → shows `SetupScreen` if none
3. `SetupScreen` — generate new Ed25519 keypair or import 32-byte hex seed, shows public key
4. `KeyGenScreen` — enter device ID (`CS-XXXX-XXXX` format) via QR scan or manual input → sign → display base64 activation key with copy button

## Device ID format
- Regex: `^CS-[A-Z0-9]{4}-[A-Z0-9]{4}$`

## Commands
```sh
flutter pub get          # install deps
flutter analyze          # lint check
flutter test             # run tests (1 widget test)
```

## Git Workflow
- Primary branch: `development` — all work lands here
- `master` — release branch (tags `v*` trigger CD)
- Commit format: `<emoji> <type>(<scope>): <summary under 50 chars>`
  - 🐣 feat, 🐞 fix, 📄 docs, 🎨 style, ✏️ refactor, ⚡ perf, 🏗️ chore
- No double quotes in commit messages — single quotes only
- CI: `flutter analyze` + `flutter test` on push/PR to `development`
- CD: analyze + test + build APK + GitHub release on push/tags to `master`

