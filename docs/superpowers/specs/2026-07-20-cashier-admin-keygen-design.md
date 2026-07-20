# Cashier Admin Keygen — Design Spec

## 1. Project Identity
- **Name:** `cashier_admin_keygen`
- **Package:** `com.cashier.adminkeygen`
- **Platform:** Android only (`minSdk = 21`)
- **Target:** Offline Ed25519 license key generator for Windows POS systems

## 2. Architecture (Clean Architecture + Provider)
```
lib/
├── main.dart                          # App entry, Provider setup, FLAG_SECURE
├── core/
│   ├── services/
│   │   ├── gatekeeper_service.dart     # local_auth wrapper
│   │   └── key_manager.dart           # flutter_secure_storage + ed25519
│   └── models/
│       └── activation_key.dart        # Value object for signed key
├── features/
│   ├── auth/
│   │   └── screens/
│   │       └── auth_gate_screen.dart   # Opaque auth overlay
│   ├── setup/
│   │   └── screens/
│   │       └── setup_screen.dart       # First-run key generation/import
│   └── keys/
│       ├── screens/
│       │   └── keygen_screen.dart      # QR scan + manual input + sign
│       └── widgets/
│           ├── qr_scanner_widget.dart  # mobile_scanner wrapper
│           └── key_display_widget.dart # Signed key + copy button
```

## 3. Component Details

### 3a. GatekeeperService (`local_auth`)
- Wraps `local_auth` `authenticate()` with `biometricOnly: false` (PIN fallback)
- Returns `Future<bool>` — true only on successful auth
- Called from `AuthGateScreen` on launch and app lifecycle resume
- `WidgetsBindingObserver` detects `AppLifecycleState.resumed` → re-auth
- Opaque overlay: dark transparent background, centered biometric icon + prompt
- 3-attempt lockout before showing error message

### 3b. KeyManager (`flutter_secure_storage` + `ed25519_edwards25519`)
- Key generation: `Ed25519KeyPair` → store 32-byte seed via `flutter_secure_storage`
- Key import: Accept hex/Base64 seed → validate 32 bytes → store
- Retrieval: Read seed → regenerate keypair in-memory
- Signing: `privateKey.sign(utf8.encode(deviceId))` → `base64.encode(signature.bytes)`
- Public key exported as hex string
- First-run: `KeyManager.hasKeyPair()` → route to `SetupScreen`

### 3c. QR Scanner (`mobile_scanner`)
- `QrScannerWidget` wraps `MobileScanner` with `onDetect` callback
- Validates pattern: `^CS-[A-Z0-9]{4}-[A-Z0-9]{4}$`
- Manual text field fallback with same validation

### 3d. Signing Logic
- Input: Device ID string (e.g., `CS-A1B2-C3D4`)
- Sign: Ed25519 private key over `utf8.encode(deviceId)`
- Output: Base64-encoded signature = Activation Key
- Displayed with "Copy to Clipboard" button

## 4. Screen Flow
```
App → AuthGateScreen (biometric/PIN)
  ├─ Fail → retry (max 3)
  └─ Success → KeyManager.hasKeyPair()?
       ├─ No → SetupScreen (generate/import key → show public key)
       └─ Yes → KeyGenScreen (QR/manual → sign → copy)
```

## 5. Android Security
- `FLAG_SECURE` on all windows (set in `main.dart`)
- `minSdk = 21` in `android/app/build.gradle.kts`
- Android Keystore backing via `flutter_secure_storage`
- No iOS config

## 6. Dependencies
```yaml
provider: ^6.1.2
local_auth: ^2.3.0
flutter_secure_storage: ^9.2.4
mobile_scanner: ^6.0.2
ed25519_edwards25519: ^0.1.0
```

## 7. CI/CD (GitHub Actions)
- `.github/workflows/android_ci.yml`
- Trigger: push to `development`, `master`; PRs
- Steps: Java 17 + Flutter stable → pub get → analyze → test → build apk --release → upload artifact
- No Shorebird, no OTA

## 8. Git Protocol
- Branch: `development` (current)
- Draft commits for review before `git commit`
- Format: `<emoji> <type>(<scope>): <summary>` + bullet body
- No double quotes in commit payload
- Emoji legend: 🐣 feat, 🐞 fix, 📄 docs, 🎨 style, ✏️ refactor, ⚡ perf, 🏗️ chore
