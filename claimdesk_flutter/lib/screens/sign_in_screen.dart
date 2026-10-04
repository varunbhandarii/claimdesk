import 'package:flutter/material.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import '../client.dart';
import '../data/errors.dart';
import '../ui/brand.dart';
import '../ui/claim_shapes.dart';
import '../ui/desk_theme.dart';
import '../ui/desk_widgets.dart';
import 'pick_venue_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});
  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  late final EmailAuthController _controller;
  GoogleAuthController? _google;
  bool _restoring = true;
  bool _showPassword = false;
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
    googleSignInReady.then((ready) {
      if (!ready || !mounted) return;
      setState(() {
        _google = GoogleAuthController(client: client)
          ..addListener(_googleChanged);
      });
    });
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

  void _googleChanged() {
    final google = _google;
    if (!mounted || google == null) return;
    setState(() {
      if (google.state == GoogleAuthState.loading) _error = null;
      final error = google.error;
      if (error != null) _error = errorMessage(error);
    });
  }

  @override
  void dispose() {
    client.auth.authInfoListenable.removeListener(_authChanged);
    _controller.dispose();
    _google
      ?..removeListener(_googleChanged)
      ..dispose();
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
    final c = context.desk;
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: _HangingClaim()),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 40, 28, 40),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) => AutofillGroup(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: ClaimDeskMark(
                              width: 72,
                              semanticLabel: 'ClaimDesk',
                            ),
                          ),
                          const SizedBox(height: 14),
                          Semantics(
                            header: true,
                            child: Text(
                              'ClaimDesk',
                              style: context.type.displayAt(46),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'A place for everything found.\nSign in to your venue’s desk.',
                            style: context.type.body.copyWith(
                              fontSize: 16,
                              height: 1.45,
                              color: c.ink2,
                            ),
                          ),
                          const SizedBox(height: 30),
                          LabeledField(
                            label: 'Email',
                            child: TextField(
                              controller: _controller.emailController,
                              enabled: !_controller.isLoading,
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: const [AutofillHints.username],
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                hintText: 'you@venue.org',
                                prefixIcon: Icon(Icons.mail_outline, size: 20),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          LabeledField(
                            label: 'Password',
                            child: TextField(
                              controller: _controller.passwordController,
                              enabled: !_controller.isLoading,
                              obscureText: !_showPassword,
                              autofillHints: const [AutofillHints.password],
                              decoration: InputDecoration(
                                prefixIcon: const Icon(
                                  Icons.lock_outline,
                                  size: 20,
                                ),
                                suffixIcon: IconButton(
                                  tooltip: _showPassword
                                      ? 'Hide password'
                                      : 'Show password',
                                  onPressed: () => setState(
                                    () => _showPassword = !_showPassword,
                                  ),
                                  icon: Icon(
                                    _showPassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    size: 20,
                                  ),
                                ),
                              ),
                              onSubmitted: (_) => _login(),
                            ),
                          ),
                          if (_error != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: NoteStrip(
                                icon: Icons.error_outline,
                                tone: DiscTone.bad,
                                child: Text(_error!),
                              ),
                            ),
                          const SizedBox(height: 22),
                          FilledButton(
                            style: bigButtonStyle(context),
                            onPressed: _controller.isLoading ? null : _login,
                            child: Text(
                              _controller.isLoading ? 'Signing in…' : 'Sign in',
                            ),
                          ),
                          if (_google case final google?) ...[
                            const SizedBox(height: 20),
                            const _OrDivider(),
                            const SizedBox(height: 20),
                            LayoutBuilder(
                              builder: (context, box) => Center(
                                child: GoogleSignInWidget(
                                  controller: google,
                                  minimumWidth: box.maxWidth
                                      .clamp(1, 400)
                                      .toDouble(),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 22),
                          Text(
                            'Ask your supervisor for an account.',
                            textAlign: TextAlign.center,
                            style: context.type.body.copyWith(
                              fontSize: 13.5,
                              color: c.ink3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _login() {
    if (_controller.isLoading) return;
    setState(() => _error = null);
    _controller.login();
  }
}

/// "or" between the email form and Google sign-in.
class _OrDivider extends StatelessWidget {
  const _OrDivider();
  @override
  Widget build(BuildContext context) {
    final c = context.desk;
    return Row(
      children: [
        Expanded(child: Divider(color: c.line, height: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'or',
            style: context.type.body.copyWith(fontSize: 13.5, color: c.ink3),
          ),
        ),
        Expanded(child: Divider(color: c.line, height: 1)),
      ],
    );
  }
}

/// Decoration behind the sign-in form: a found-item tag hanging on its string
/// and the owner's claim ticket tucked in the opposite corner.
class _HangingClaim extends StatelessWidget {
  const _HangingClaim();
  @override
  Widget build(BuildContext context) {
    final c = context.desk;
    return ExcludeSemantics(
      child: LayoutBuilder(
        builder: (context, box) {
          final roomy = box.maxWidth >= 720;
          return Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned(
                right: roomy ? box.maxWidth * .08 : -34,
                top: roomy ? 90 : 56,
                child: Transform.rotate(
                  angle: .26,
                  alignment: Alignment.centerLeft,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: 38,
                        bottom: 32,
                        child: Container(
                          width: 1.5,
                          height: 220,
                          color: c.lineStrong,
                        ),
                      ),
                      DecoratedBox(
                        decoration: ShapeDecoration(
                          color: c.tag,
                          shape: const TagShape(point: 22, radius: 10),
                        ),
                        child: SizedBox(
                          height: 64,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(32, 0, 30, 0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 13,
                                  height: 13,
                                  decoration: BoxDecoration(
                                    color: c.paper,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0x5916181B),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Text(
                                  'K7P2QM',
                                  style: context.type
                                      .codeAt(22)
                                      .copyWith(color: c.tagOn),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: roomy ? box.maxWidth * .07 : -26,
                bottom: roomy ? 90 : 56,
                child: Transform.rotate(
                  angle: -.14,
                  child: DecoratedBox(
                    decoration: ShapeDecoration(
                      color: c.ticket,
                      shape: const TicketShape(radius: 10, notch: 10),
                    ),
                    child: SizedBox(
                      height: 58,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(30, 0, 28, 0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            DashedLine(
                              axis: Axis.vertical,
                              length: 30,
                              thickness: 2,
                              dash: 4,
                              gap: 3,
                              color: c.ticketOn.withValues(alpha: .6),
                            ),
                            const SizedBox(width: 14),
                            Text(
                              'SMP854',
                              style: context.type
                                  .codeAt(22)
                                  .copyWith(color: c.ticketOn),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
