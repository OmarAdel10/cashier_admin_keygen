# Cashier Admin Keygen Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans to implement task-by-task.

**Goal:** Build Android-only offline Ed25519 license key generator with biometric gate, QR scanner, and hardware-backed key storage.

**Architecture:** Clean Architecture + Provider. Services: GatekeeperService (local_auth), KeyManager (flutter_secure_storage + ed25519_edwards25519). Screens: AuthGateScreen → SetupScreen/KeyGenScreen.

**Tech Stack:** Flutter 3.x, Dart SDK ^3.12.2, provider, local_auth, flutter_secure_storage, mobile_scanner, ed25519_edwards25519

## Global Constraints
- Android only (minSdk = 21), no iOS config
- FLAG_SECURE on all windows
- Package: `com.cashier.adminkeygen`
- No Shorebird, no OTA code-push
- All commits on `development` branch only
- Draft commits for review before executing
- No double quotes in commit messages
- Commit format: `<emoji> <type>(<scope>): <summary>` with bullet body
- Emoji legend: 🐣 feat, 🐞 fix, 📄 docs, 🎨 style, ✏️ refactor, ⚡ perf, 🏗️ chore

---

### Task 1: CI/CD — GitHub Actions Workflow

**Files:**
- Create: `.github/workflows/android_ci.yml`
- Modify: `.gitignore`

**Interfaces:**
- Consumes: (none)
- Produces: CI pipeline that validates every push/PR to development/master

- [ ] **Step 1: Create CI workflow file**

`.github/workflows/android_ci.yml`:
```yaml
name: Android CI

on:
  push:
    branches: [development, master]
  pull_request:
    branches: [development, master]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with:
          distribution: 'zulu'
          java-version: 17
      - uses: subosito/flutter-action@v2
        with:
          channel: 'stable'
          cache: true
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test
      - run: flutter build apk --release
      - uses: actions/upload-artifact@v4
        with:
          name: app-release-apk
          path: build/app/outputs/flutter-apk/app-release.apk
```

- [ ] **Step 2: Update .gitignore**

Add to `.gitignore`:
```
# CI artifacts
.github/
```

- [ ] **Step 3: Verify file structure**

Run: `ls -la .github/workflows/`
Expected: `android_ci.yml` exists

- [ ] **Step 4: Draft commit**

```bash
git add .github/workflows/android_ci.yml .gitignore
git diff --cached --stat
```
Present diff for user review.

---

### Task 2: Project Scaffolding — Rename & Dependencies

**Files:**
- Create: `.github/DEVELOPMENT_ENVIRONMENT.md`
- Create: `lib/core/services/.gitkeep`
- Create: `lib/features/auth/screens/.gitkeep`
- Create: `lib/features/setup/screens/.gitkeep`
- Create: `lib/features/keys/screens/.gitkeep`
- Create: `lib/features/keys/widgets/.gitkeep`
- Create: `lib/core/models/.gitkeep`
- Modify: `pubspec.yaml`
- Modify: `android/app/build.gradle.kts`
- Modify: `android/app/src/main/AndroidManifest.xml`
- Modify: `lib/main.dart` (clear counter app, leave minimal entry)

**Interfaces:**
- Consumes: Task 1 CI file exists
- Produces: Clean project skeleton with correct deps, folder structure, minSdk=21, package renamed

- [ ] **Step 1: Rewrite pubspec.yaml**

Update `pubspec.yaml`:
```yaml
name: cashier_admin_keygen
description: 'Offline Ed25519 license key generator for Cashier POS'
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: ^3.12.2

dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.2
  local_auth: ^2.3.0
  flutter_secure_storage: ^9.2.4
  mobile_scanner: ^6.0.2
  ed25519_edwards25519: ^0.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0

flutter:
  uses-material-design: true
```

- [ ] **Step 2: Update Android build.gradle.kts**

Set `namespace` and `applicationId`:
```kotlin
namespace = "com.cashier.adminkeygen"
// ...
defaultConfig {
    applicationId = "com.cashier.adminkeygen"
    minSdk = 21
    // targetSdk, versionCode, versionName from flutter
}
```

- [ ] **Step 3: Update AndroidManifest.xml**

Ensure `android/app/src/main/AndroidManifest.xml` includes camera permission for mobile_scanner:
```xml
<uses-permission android:name="android.permission.CAMERA" />
```

- [ ] **Step 4: Flatten main.dart to clean entry**

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const CashierAdminKeygenApp());
}

class CashierAdminKeygenApp extends StatelessWidget {
  const CashierAdminKeygenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cashier Admin Keygen',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(child: Text('Cashier Admin Keygen')),
      ),
    );
  }
}
```

- [ ] **Step 5: Create folder structure with .gitkeep files**

```
lib/core/services/.gitkeep
lib/core/models/.gitkeep
lib/features/auth/screens/.gitkeep
lib/features/setup/screens/.gitkeep
lib/features/keys/screens/.gitkeep
lib/features/keys/widgets/.gitkeep
```

- [ ] **Step 6: Create DEVELOPMENT_ENVIRONMENT.md**

`.github/DEVELOPMENT_ENVIRONMENT.md`:
```markdown
# Development Environment

## Git Workflow
- Branch: `development` (primary)
- No new branches without explicit approval
- All commits drafted for review before `git commit`

## Commit Format
```
<emoji> <type>(<scope>): <summary under 50 chars>

* Bullet list of functional implementations
* Architectural impacts or state engine changes

WARNINGS (include ONLY if secrets, console logs, or outstanding TODOs)
```

### Legend
- 🐣 feat, 🐞 fix, 📄 docs, 🎨 style, ✏️ refactor, ⚡ perf, 🏗️ chore

### Rules
- Subject line: under 50 absolute characters, imperative mood
- No double quotes (`"`) in commit payload — single quotes only
```

- [ ] **Step 7: Run flutter pub get to validate**

Run: `flutter pub get`
Expected: Success with all deps resolved

- [ ] **Step 8: Remove `.gitkeep` files from folder structure**

```bash
find lib -name '.gitkeep' -delete
```

- [ ] **Step 9: Draft commit**

```bash
git add pubspec.yaml pubspec.lock lib/ android/app/build.gradle.kts android/app/src/main/AndroidManifest.xml .github/DEVELOPMENT_ENVIRONMENT.md
git diff --cached --stat
```

---

### Task 3: Core Services — GatekeeperService & KeyManager

**Files:**
- Create: `lib/core/services/gatekeeper_service.dart`
- Create: `lib/core/services/key_manager.dart`
- Create: `lib/core/models/activation_key.dart`

**Interfaces:**
- Consumes: Project scaffolding from Task 2 (flutter_secure_storage configured)
- Produces: `GatekeeperService.authenticate() → Future<bool>` and `KeyManager.{hasKeyPair, generateKeyPair, importSeed, signDeviceId, getPublicKey}`

- [ ] **Step 1: Create GatekeeperService**

`lib/core/services/gatekeeper_service.dart`:
```dart
import 'package:local_auth/local_auth.dart';

class GatekeeperService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> authenticate() async {
    try {
      final bool canAuth = await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
      if (!canAuth) return false;

      return await _auth.authenticate(
        localizedReason: 'Authenticate to access key generator',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  Future<bool> canAuthenticate() async {
    return await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
  }
}
```

- [ ] **Step 2: Create ActivationKey model**

`lib/core/models/activation_key.dart`:
```dart
class ActivationKey {
  final String deviceId;
  final String signatureBase64;

  const ActivationKey({
    required this.deviceId,
    required this.signatureBase64,
  });

  String get formatted => 'Device ID: $deviceId\nActivation Key: $signatureBase64';
}
```

- [ ] **Step 3: Create KeyManager**

`lib/core/services/key_manager.dart`:
```dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ed25519_edwards25519/ed25519_edwards25519.dart' as ed;

class KeyManager {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const _seedKey = 'ed25519_seed';

  Future<bool> hasKeyPair() async {
    final seed = await _storage.read(key: _seedKey);
    return seed != null && seed.isNotEmpty;
  }

  Future<String> generateKeyPair() async {
    final keyPair = ed.generateKeyPair();
    final seed = base64.encode(keyPair.seed!.bytes);
    await _storage.write(key: _seedKey, value: seed);
    return getPublicKey();
  }

  Future<void> importSeed(String seedHex) async {
    final seedBytes = _hexToBytes(seedHex);
    if (seedBytes.length != 32) {
      throw ArgumentError('Seed must be exactly 32 bytes (64 hex chars)');
    }
    final seedB64 = base64.encode(seedBytes);
    await _storage.write(key: _seedKey, value: seedB64);
  }

  Future<String> getPublicKey() async {
    final seedB64 = await _storage.read(key: _seedKey);
    if (seedB64 == null) throw StateError('No key pair found');
    final seedBytes = base64.decode(seedB64);
    final keyPair = ed.KeyPair.fromSeed(seedBytes);
    final publicKey = keyPair.publicKey;
    return _bytesToHex(publicKey.bytes);
  }

  Future<String> signDeviceId(String deviceId) async {
    final seedB64 = await _storage.read(key: _seedKey);
    if (seedB64 == null) throw StateError('No key pair found');
    final seedBytes = base64.decode(seedB64);
    final keyPair = ed.KeyPair.fromSeed(seedBytes);
    final payload = utf8.encode(deviceId);
    final signature = keyPair.privateKey.sign(payload, ed.SignatureType());
    return base64.encode(signature.bytes);
  }

  String _bytesToHex(Uint8List bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  Uint8List _hexToBytes(String hex) {
    final cleaned = hex.replaceAll(' ', '');
    if (cleaned.length % 2 != 0) {
      throw ArgumentError('Hex string must have even length');
    }
    final bytes = Uint8List(cleaned.length ~/ 2);
    for (int i = 0; i < bytes.length; i++) {
      bytes[i] = int.parse(cleaned.substring(i * 2, i * 2 + 2), radix: 16);
    }
    return bytes;
  }
}
```

- [ ] **Step 4: Validate with flutter analyze**

Run: `flutter analyze`
Expected: No errors (ignore unused import warnings for now)

- [ ] **Step 5: Draft commit**

```bash
git add lib/core/services/gatekeeper_service.dart lib/core/services/key_manager.dart lib/core/models/activation_key.dart
git diff --cached --stat
```

---

### Task 4: AuthGateScreen — Biometric Overlay & Lifecycle

**Files:**
- Create: `lib/features/auth/screens/auth_gate_screen.dart`
- Create: `lib/features/auth/providers/auth_provider.dart`
- Modify: `lib/main.dart` (wire provider, FLAG_SECURE, route to auth gate)

**Interfaces:**
- Consumes: `GatekeeperService.authenticate()` from Task 3
- Produces: `AuthGateScreen` — opaque overlay that locks/resumes on lifecycle change

- [ ] **Step 1: Create AuthProvider**

```dart
// lib/features/auth/providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import '../../../core/services/gatekeeper_service.dart';

class AuthProvider extends ChangeNotifier {
  final GatekeeperService _gatekeeper = GatekeeperService();
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  Future<bool> authenticate() async {
    final result = await _gatekeeper.authenticate();
    _isAuthenticated = result;
    notifyListeners();
    return result;
  }

  void lock() {
    _isAuthenticated = false;
    notifyListeners();
  }
}
```

- [ ] **Step 2: Create AuthGateScreen**

```dart
// lib/features/auth/screens/auth_gate_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AuthGateScreen extends StatefulWidget {
  final Widget child;
  const AuthGateScreen({super.key, required this.child});

  @override
  State<AuthGateScreen> createState() => _AuthGateScreenState();
}

class _AuthGateScreenState extends State<AuthGateScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _authenticate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<AuthProvider>().lock();
      _authenticate();
    }
  }

  Future<void> _authenticate() async {
    final auth = context.read<AuthProvider>();
    await auth.authenticate();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.isAuthenticated) {
          return widget.child;
        }
        return PopScope(
          canPop: false,
          child: Scaffold(
            backgroundColor: Colors.black87,
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.fingerprint, size: 80, color: Colors.white70),
                  const SizedBox(height: 24),
                  const Text(
                    'Authentication Required',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Unlock to access key generator',
                    style: TextStyle(color: Colors.white60, fontSize: 14),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: _authenticate,
                    icon: const Icon(Icons.lock_open),
                    label: const Text('Authenticate'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
```

- [ ] **Step 3: Update main.dart with FLAG_SECURE and provider**

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/auth_gate_screen.dart';
import 'features/keys/screens/keygen_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const CashierAdminKeygenApp());
}

class CashierAdminKeygenApp extends StatelessWidget {
  const CashierAdminKeygenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        title: 'Cashier Admin Keygen',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: AuthGateScreen(child: KeyGenScreen()),
      ),
    );
  }
}
```

- [ ] **Step 4: Create placeholder KeyGenScreen**

```dart
// lib/features/keys/screens/keygen_screen.dart
import 'package:flutter/material.dart';

class KeyGenScreen extends StatelessWidget {
  const KeyGenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cashier Admin Keygen')),
      body: const Center(child: Text('Key Generator')),
    );
  }
}
```

- [ ] **Step 5: Set FLAG_SECURE in Android**

Create `lib/core/services/secure_window.dart`:
```dart
import 'package:flutter/services.dart';

class SecureWindow {
  static void enable() {
    SystemChrome.setSystemUIChangeCallback((systemOverlaysAreVisible) {});
  }
}
```

We'll integrate FLAG_SECURE via the Android Activity instead. Add to `android/app/src/main/kotlin/com/cashier/adminkeygen/MainActivity.kt`:
```kotlin
package com.cashier.adminkeygen

import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.setFlags(
            WindowManager.LayoutParams.FLAG_SECURE,
            WindowManager.LayoutParams.FLAG_SECURE
        )
    }
}
```

(Note: find correct path for MainActivity.kt in the android directory first)

- [ ] **Step 6: Validates with flutter analyze**

Run: `flutter analyze`
Expected: No errors

- [ ] **Step 7: Draft commit**

---

### Task 5: SetupScreen — First-Run Key Generation

**Files:**
- Create: `lib/features/setup/screens/setup_screen.dart`
- Create: `lib/features/setup/providers/setup_provider.dart`
- Modify: `lib/features/keys/screens/keygen_screen.dart` (add first-run check)

**Interfaces:**
- Consumes: `KeyManager` from Task 3
- Produces: Setup flow (generate/import key, show public key)

- [ ] **Step 1: Create SetupProvider**

```dart
// lib/features/setup/providers/setup_provider.dart
import 'package:flutter/foundation.dart';
import '../../../core/services/key_manager.dart';

class SetupProvider extends ChangeNotifier {
  final KeyManager _keyManager = KeyManager();
  bool _isLoading = false;
  String? _publicKey;
  String? _error;

  bool get isLoading => _isLoading;
  String? get publicKey => _publicKey;
  String? get error => _error;

  Future<bool> generateKey() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _publicKey = await _keyManager.generateKeyPair();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> importSeed(String seed) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _keyManager.importSeed(seed);
      _publicKey = await _keyManager.getPublicKey();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> hasKeys() async {
    return await _keyManager.hasKeyPair();
  }
}
```

- [ ] **Step 2: Create SetupScreen**

```dart
// lib/features/setup/screens/setup_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/setup_provider.dart';

class SetupScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const SetupScreen({super.key, required this.onComplete});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _seedController = TextEditingController();
  bool _showImport = false;

  @override
  void dispose() {
    _seedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SetupProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Key Setup')),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.vpn_key, size: 64, color: Colors.indigoAccent),
                const SizedBox(height: 16),
                const Text(
                  'No master key found',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Generate a new Ed25519 keypair or import an existing seed.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                if (provider.publicKey != null) ...[
                  const Text('Public Key:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SelectableText(
                      provider.publicKey!,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: provider.publicKey!));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Public key copied')),
                      );
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy Public Key'),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: widget.onComplete,
                    child: const Text('Continue'),
                  ),
                ] else ...[
                  FilledButton.icon(
                    onPressed: provider.isLoading ? null : () => provider.generateKey(),
                    icon: provider.isLoading
                        ? const SizedBox(
                            width: 16, height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.add),
                    label: const Text('Generate New Key'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => setState(() => _showImport = !_showImport),
                    child: Text(_showImport ? 'Cancel Import' : 'Import Existing Seed'),
                  ),
                  if (_showImport) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: _seedController,
                      decoration: const InputDecoration(
                        labelText: 'Seed (64 hex chars)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 1,
                    ),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: provider.isLoading
                          ? null
                          : () => provider.importSeed(_seedController.text.trim()),
                      child: const Text('Import'),
                    ),
                  ],
                ],
                if (provider.error != null) ...[
                  const SizedBox(height: 16),
                  Text(provider.error!, style: const TextStyle(color: Colors.red)),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
```

- [ ] **Step 3: Update KeyGenScreen with first-run check**

```dart
// lib/features/keys/screens/keygen_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../setup/providers/setup_provider.dart';
import '../../setup/screens/setup_screen.dart';

class KeyGenScreen extends StatefulWidget {
  const KeyGenScreen({super.key});

  @override
  State<KeyGenScreen> createState() => _KeyGenScreenState();
}

class _KeyGenScreenState extends State<KeyGenScreen> {
  final SetupProvider _setupProvider = SetupProvider();
  bool? _hasKeys;

  @override
  void initState() {
    super.initState();
    _checkKeys();
  }

  Future<void> _checkKeys() async {
    final hasKeys = await _setupProvider.hasKeys();
    if (mounted) setState(() => _hasKeys = hasKeys);
  }

  @override
  Widget build(BuildContext context) {
    if (_hasKeys == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_hasKeys!) {
      return ChangeNotifierProvider.value(
        value: _setupProvider,
        child: SetupScreen(
          onComplete: () {
            setState(() => _hasKeys = true);
          },
        ),
      );
    }

    return const _SigningView();
  }
}

class _SigningView extends StatelessWidget {
  const _SigningView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cashier Admin Keygen')),
      body: const Center(child: Text('Ready to sign — scanner coming next')),
    );
  }
}
```

- [ ] **Step 4: Validate with flutter analyze**

Run: `flutter analyze`
Expected: No errors

- [ ] **Step 5: Draft commit**

---

### Task 6: KeyGenScreen — QR Scanner, Manual Input & Signing

**Files:**
- Create: `lib/features/keys/widgets/qr_scanner_widget.dart`
- Create: `lib/features/keys/widgets/key_display_widget.dart`
- Create: `lib/features/keys/providers/keygen_provider.dart`
- Modify: `lib/features/keys/screens/keygen_screen.dart` (replace _SigningView placeholder)

**Interfaces:**
- Consumes: `KeyManager.signDeviceId()` from Task 3
- Produces: Complete sign flow — QR scan or manual entry → sign → display + copy

- [ ] **Step 1: Create KeygenProvider**

```dart
// lib/features/keys/providers/keygen_provider.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/services/key_manager.dart';

class KeygenProvider extends ChangeNotifier {
  final KeyManager _keyManager = KeyManager();
  String? _deviceId;
  String? _activationKey;
  bool _isSigning = false;
  String? _error;

  String? get deviceId => _deviceId;
  String? get activationKey => _activationKey;
  bool get isSigning => _isSigning;
  String? get error => _error;
  bool get hasResult => _activationKey != null;

  void setDeviceId(String id) {
    _deviceId = id;
    _activationKey = null;
    _error = null;
    notifyListeners();
  }

  Future<void> sign() async {
    if (_deviceId == null || _deviceId!.isEmpty) return;
    _isSigning = true;
    _error = null;
    _activationKey = null;
    notifyListeners();
    try {
      _activationKey = await _keyManager.signDeviceId(_deviceId!);
    } catch (e) {
      _error = e.toString();
    }
    _isSigning = false;
    notifyListeners();
  }

  void reset() {
    _deviceId = null;
    _activationKey = null;
    _error = null;
    _isSigning = false;
    notifyListeners();
  }
}
```

- [ ] **Step 2: Create QR Scanner Widget**

```dart
// lib/features/keys/widgets/qr_scanner_widget.dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerWidget extends StatelessWidget {
  final void Function(String deviceId) onDetected;

  const QrScannerWidget({super.key, required this.onDetected});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 250,
        child: MobileScanner(
          onDetect: (capture) {
            final barcode = capture.barcodes.firstOrNull;
            if (barcode?.rawValue != null) {
              final raw = barcode!.rawValue!;
              final regex = RegExp(r'^CS-[A-Z0-9]{4}-[A-Z0-9]{4}$');
              if (regex.hasMatch(raw.toUpperCase())) {
                onDetected(raw.toUpperCase());
              }
            }
          },
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Create KeyDisplayWidget**

```dart
// lib/features/keys/widgets/key_display_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KeyDisplayWidget extends StatelessWidget {
  final String deviceId;
  final String activationKey;

  const KeyDisplayWidget({
    super.key,
    required this.deviceId,
    required this.activationKey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.indigoAccent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Device ID:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(deviceId, style: const TextStyle(fontFamily: 'monospace', fontSize: 16)),
          const SizedBox(height: 16),
          const Text('Activation Key:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          SelectableText(
            activationKey,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: activationKey));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Activation key copied')),
              );
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copy Activation Key'),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Update KeyGenScreen — full signing view**

```dart
// lib/features/keys/screens/keygen_screen.dart (full rewrite of _SigningView)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../setup/providers/setup_provider.dart';
import '../../setup/screens/setup_screen.dart';
import '../providers/keygen_provider.dart';
import '../widgets/qr_scanner_widget.dart';
import '../widgets/key_display_widget.dart';

class KeyGenScreen extends StatefulWidget {
  const KeyGenScreen({super.key});

  @override
  State<KeyGenScreen> createState() => _KeyGenScreenState();
}

class _KeyGenScreenState extends State<KeyGenScreen> {
  final SetupProvider _setupProvider = SetupProvider();
  bool? _hasKeys;
  final _manualController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkKeys();
  }

  @override
  void dispose() {
    _manualController.dispose();
    super.dispose();
  }

  Future<void> _checkKeys() async {
    final hasKeys = await _setupProvider.hasKeys();
    if (mounted) setState(() => _hasKeys = hasKeys);
  }

  @override
  Widget build(BuildContext context) {
    if (_hasKeys == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_hasKeys!) {
      return ChangeNotifierProvider.value(
        value: _setupProvider,
        child: SetupScreen(
          onComplete: () {
            setState(() => _hasKeys = true);
          },
        ),
      );
    }

    return ChangeNotifierProvider(
      create: (_) => KeygenProvider(),
      child: _SigningView(manualController: _manualController),
    );
  }
}

class _SigningView extends StatelessWidget {
  final TextEditingController manualController;
  const _SigningView({required this.manualController});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cashier Admin Keygen')),
      body: Consumer<KeygenProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Scan Device ID QR Code:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                QrScannerWidget(
                  onDetected: (id) {
                    provider.setDeviceId(id);
                    manualController.text = id;
                  },
                ),
                const SizedBox(height: 16),
                const Divider(),
                const Text('Or enter manually:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: manualController,
                  decoration: const InputDecoration(
                    hintText: 'CS-XXXX-XXXX',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  onChanged: (v) {
                    final regex = RegExp(r'^CS-[A-Z0-9]{4}-[A-Z0-9]{4}$');
                    if (regex.hasMatch(v.toUpperCase())) {
                      provider.setDeviceId(v.toUpperCase());
                    }
                  },
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: provider.deviceId == null || provider.isSigning
                      ? null
                      : () => provider.sign(),
                  icon: provider.isSigning
                      ? const SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.token),
                  label: const Text('Generate Activation Key'),
                ),
                if (provider.error != null) ...[
                  const SizedBox(height: 16),
                  Text(provider.error!, style: const TextStyle(color: Colors.red)),
                ],
                if (provider.hasResult) ...[
                  const SizedBox(height: 24),
                  KeyDisplayWidget(
                    deviceId: provider.deviceId!,
                    activationKey: provider.activationKey!,
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () {
                      provider.reset();
                      manualController.clear();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Generate Another'),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
```

- [ ] **Step 5: Register camera permission in AndroidManifest**

Ensure `android/app/src/main/AndroidManifest.xml` contains:
```xml
<uses-permission android:name="android.permission.CAMERA" />
```

- [ ] **Step 6: Validate with flutter analyze**

Run: `flutter analyze`
Expected: No errors

- [ ] **Step 7: Draft commit**

---

### Task 7: Final Integration — main.dart, Android flags, cleanup

**Files:**
- Modify: `android/app/src/main/kotlin/com/cashier/adminkeygen/MainActivity.kt` (FLAG_SECURE)
- Modify: `lib/main.dart` (final polish)
- Delete: `test/widget_test.dart` (replace with meaningful test)

**Interfaces:**
- Consumes: All previous tasks
- Produces: Working, compiled APK

- [ ] **Step 1: Set FLAG_SECURE on Android MainActivity**

Find the actual path to MainActivity.kt. It's likely under `android/app/src/main/kotlin/com/cashier/adminkeygen/` or similar. Read it first to confirm path, then add:
```kotlin
package com.cashier.adminkeygen

import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.setFlags(
            WindowManager.LayoutParams.FLAG_SECURE,
            WindowManager.LayoutParams.FLAG_SECURE
        )
    }
}
```

- [ ] **Step 2: Write meaningful widget test**

`test/widget_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:cashier_admin_keygen/features/auth/providers/auth_provider.dart';
import 'package:cashier_admin_keygen/features/auth/screens/auth_gate_screen.dart';
import 'package:cashier_admin_keygen/features/keys/screens/keygen_screen.dart';

void main() {
  testWidgets('AuthGateScreen shows authentication prompt when not authenticated',
      (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthProvider(),
        child: const MaterialApp(
          home: AuthGateScreen(child: KeyGenScreen()),
        ),
      ),
    );
    expect(find.text('Authentication Required'), findsOneWidget);
  });
}
```

- [ ] **Step 3: flutter build apk --release to verify end-to-end**

Run: `flutter build apk --release`
Expected: BUILD SUCCESSFUL — APK at `build/app/outputs/flutter-apk/app-release.apk`

- [ ] **Step 4: Draft commit**

---

### Task 8: Self-Review & Final Commit

- [ ] **1. Spec coverage check:** Every spec section (auth, keys, camera, signing, CI/CD, FLAG_SECURE, Android-only) implemented in its own task.
- [ ] **2. Placeholder scan:** No "TBD", "TODO", or incomplete code.
- [ ] **3. Type consistency:** `GatekeeperService.authenticate()`, `KeyManager.signDeviceId()`, `KeyManager.hasKeyPair()` — consistent across all tasks.
- [ ] **4. Run final analysis:** `flutter analyze` and `flutter test` both pass.

- [ ] **5. Draft final commit**

---

## Self-Review (inline)

**Spec coverage:**
- Biometric gate: Task 4 (AuthGateScreen + AuthProvider)
- Key vault (flutter_secure_storage + Ed25519): Task 3 (KeyManager)
- Key generation/import: Task 5 (SetupScreen + SetupProvider)
- QR scanner: Task 6 (QrScannerWidget)
- Manual input: Task 6 (text field in _SigningView)
- Signing output + copy: Task 6 (KeyDisplayWidget)
- CI/CD: Task 1 (GitHub Actions)
- FLAG_SECURE: Task 7 (MainActivity.kt)
- Android-only: Tasks 1-7 (no iOS config)
- Clean architecture: All tasks (services, providers, screens separated)

**Placeholder scan:** No placeholders found. All code is complete.

**Type consistency:** All method signatures match across tasks. `signDeviceId(String) → Future<String>`, `hasKeyPair() → Future<bool>`, `authenticate() → Future<bool>`.

**Scope check:** Single application, good.
