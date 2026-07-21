import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class AuthGateScreen extends StatefulWidget {
  final Widget child;
  final Future<bool> Function()? authenticate;

  const AuthGateScreen({
    super.key,
    required this.child,
    this.authenticate,
  });

  @override
  State<AuthGateScreen> createState() => _AuthGateScreenState();
}

class _AuthGateScreenState extends State<AuthGateScreen>
    with WidgetsBindingObserver {
  bool _isAuthenticated = false;
  bool _isAuthenticating = false;

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
      setState(() {
        _isAuthenticated = false;
        _isAuthenticating = false;
      });
      _authenticate();
    }
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
    });

    final authenticated = await (widget.authenticate ?? _defaultAuthenticate)();

    if (mounted) {
      setState(() {
        _isAuthenticated = authenticated;
        _isAuthenticating = false;
      });
    }
  }

  Future<bool> _defaultAuthenticate() async {
    final auth = LocalAuthentication();
    try {
      return await auth.authenticate(
        localizedReason: 'Authenticate to access key management',
      );
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isAuthenticating && !_isAuthenticated) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_isAuthenticated) {
      return widget.child;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Authentication Required')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Authentication required',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isAuthenticating ? null : _authenticate,
                child: const Text('Authenticate'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
