import 'package:flutter/material.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import '../client.dart';
import '../data/errors.dart';
import 'pick_venue_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});
  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  late final EmailAuthController _controller;
  bool _restoring = true;
  String? _error;
  @override
  void initState() {
    super.initState();
    _controller = EmailAuthController(
      client: client,
      startScreen: EmailFlowScreen.login,
      onAuthenticated: () {},
      onError: (e) {
        if (mounted) setState(() => _error = errorMessage(e));
      },
    );
    client.auth.authInfoListenable.addListener(_authChanged);
    authInitialization.then(
      (_) {
        if (mounted) setState(() => _restoring = false);
      },
      onError: (Object e) {
        if (mounted) {
          setState(() {
            _restoring = false;
            _error = errorMessage(e);
          });
        }
      },
    );
  }

  void _authChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    client.auth.authInfoListenable.removeListener(_authChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_restoring) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            semanticsLabel: 'Restoring your session',
          ),
        ),
      );
    }
    if (client.auth.isAuthenticated) {
      return PickVenueScreen(key: ValueKey(client.auth.authInfo?.authUserId));
    }
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.inventory_2_outlined, size: 52),
                    const SizedBox(height: 24),
                    Text(
                      'ClaimDesk',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'A place for everything found.\nSign in to your venue’s desk.',
                    ),
                    const SizedBox(height: 36),
                    TextField(
                      controller: _controller.emailController,
                      enabled: !_controller.isLoading,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.username],
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _controller.passwordController,
                      enabled: !_controller.isLoading,
                      obscureText: true,
                      autofillHints: const [AutofillHints.password],
                      decoration: const InputDecoration(labelText: 'Password'),
                      onSubmitted: (_) => _login(),
                    ),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          _error!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _controller.isLoading ? null : _login,
                      child: Text(
                        _controller.isLoading ? 'Signing in…' : 'Sign in',
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Ask your supervisor for an account.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _login() {
    if (_controller.isLoading) return;
    setState(() => _error = null);
    _controller.login();
  }
}
