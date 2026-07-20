import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AuthGateScreen extends StatefulWidget {
  final Widget child;
  const AuthGateScreen({super.key, required this.child});

  @override
  State<AuthGateScreen> createState() => _AuthGateScreenState();
}

class _AuthGateScreenState extends State<AuthGateScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _authenticate());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
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
        if (auth.status == AuthStatus.success) {
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
                  _buildIcon(auth.status),
                  const SizedBox(height: 24),
                  _buildTitle(auth.status),
                  const SizedBox(height: 8),
                  _buildSubtitle(auth.status, auth.errorMessage),
                  const SizedBox(height: 32),
                  _buildButton(auth.status),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildIcon(AuthStatus status) {
    return switch (status) {
      AuthStatus.loading => const SizedBox(
          width: 80,
          height: 80,
          child: CircularProgressIndicator(color: Colors.white70),
        ),
      AuthStatus.failure => const Icon(
          Icons.fingerprint,
          size: 80,
          color: Colors.redAccent,
        ),
      AuthStatus.unavailable => const Icon(
          Icons.smartphone,
          size: 80,
          color: Colors.orangeAccent,
        ),
      _ => const Icon(
          Icons.fingerprint,
          size: 80,
          color: Colors.white70,
        ),
    };
  }

  Widget _buildTitle(AuthStatus status) {
    return Text(
      switch (status) {
        AuthStatus.loading => 'Authenticating\u2026',
        AuthStatus.failure => 'Authentication Failed',
        AuthStatus.unavailable => 'Not Available',
        _ => 'Authentication Required',
      },
      style: const TextStyle(color: Colors.white, fontSize: 20),
    );
  }

  Widget _buildSubtitle(AuthStatus status, String? errorMessage) {
    return Text(
      switch (status) {
        AuthStatus.loading => 'Please complete the biometric prompt',
        AuthStatus.failure || AuthStatus.unavailable =>
          errorMessage ?? 'Unable to authenticate.',
        _ => 'Tap to unlock key generator',
      },
      style: const TextStyle(color: Colors.white60, fontSize: 14),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildButton(AuthStatus status) {
    if (status == AuthStatus.loading) {
      return const SizedBox.shrink();
    }

    return ElevatedButton.icon(
      onPressed: _authenticate,
      icon: Icon(
        status == AuthStatus.unavailable
            ? Icons.refresh
            : Icons.lock_open,
      ),
      label: Text(
        switch (status) {
          AuthStatus.failure => 'Retry',
          AuthStatus.unavailable => 'Try Again',
          _ => 'Authenticate',
        },
      ),
    );
  }
}
