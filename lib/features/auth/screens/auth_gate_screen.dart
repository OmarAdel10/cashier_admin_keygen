import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class AuthGateScreen extends StatefulWidget {
  final Widget child;

  const AuthGateScreen({super.key, required this.child});

  @override
  State<AuthGateScreen> createState() => _AuthGateScreenState();
}

class _AuthGateScreenState extends State<AuthGateScreen>
    with WidgetsBindingObserver {
  final LocalAuthentication _auth = LocalAuthentication();
  bool _isAuthenticated = false;
  bool _isLoading = false;

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
      });
      _authenticate();
    }
  }

  Future<void> _authenticate() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final authenticated = await _auth.authenticate(
        localizedReason: 'Authenticate to access the app',
      );
      setState(() => _isAuthenticated = authenticated);
    } catch (e) {
      setState(() => _isAuthenticated = false);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isAuthenticated) return widget.child;

    return Scaffold(
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                key: const Key('authenticate_button'),
                onPressed: _authenticate,
                child: const Text('Authenticate'),
              ),
      ),
    );
  }
}
