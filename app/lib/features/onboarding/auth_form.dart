import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_state.dart';
import '../../core/config.dart';
import '../../core/l10n.dart';
import '../../core/sfx.dart';
import '../../core/theme.dart';
import '../../data/repository.dart';
import '../../effects/mascot.dart';

const minPasswordLength = 10;

/// Sign up or sign in. Registering keeps everything the player has done so far as a guest.
class AuthForm extends ConsumerStatefulWidget {
  const AuthForm({super.key, required this.onSignedIn, this.onGuest, this.startWithLogin = false});

  /// [existing] is true when the player came back to an account they already had.
  final void Function(bool existing) onSignedIn;

  /// Null hides the "continue as guest" option.
  final VoidCallback? onGuest;
  final bool startWithLogin;

  @override
  ConsumerState<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends ConsumerState<AuthForm> {
  late bool _login = widget.startWithLogin;
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  String? _validate() {
    final l = context.l;
    final email = _email.text.trim();
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) return l.authBadEmail;
    if (!_login && _password.text.length < minPasswordLength) return l.authShortPassword(minPasswordLength);
    if (_login && _password.text.isEmpty) return l.authBadLogin;
    return null;
  }

  Future<void> _submit() async {
    final problem = _validate();
    if (problem != null) {
      setState(() => _error = problem);
      return;
    }
    Sfx.click();
    final l = context.l;
    setState(() {
      _busy = true;
      _error = null;
    });
    final app = ref.read(appProvider.notifier);
    try {
      if (_login) {
        await app.login(_email.text.trim(), _password.text);
      } else {
        await app.register(_email.text.trim(), _password.text, _name.text.trim());
      }
      Sfx.success();
      if (mounted) widget.onSignedIn(_login);
    } on AuthFailed catch (e) {
      if (mounted) {
        setState(() => _error = switch (e.reason) {
              AuthFailure.badLogin => l.authBadLogin,
              AuthFailure.emailTaken => l.authTaken,
              AuthFailure.needsServer => l.authNeedsServer,
              AuthFailure.other => l.errorGeneric,
            });
      }
    } catch (_) {
      if (mounted) setState(() => _error = l.errorGeneric);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final offline = ref.watch(appProvider.select((s) => s.offline));
    return Center(
      child: SingleChildScrollView(
        child: AutofillGroup(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Center(child: Mascot(mood: MascotMood.happy, size: 96)),
            Text(_login ? l.authLoginTitle : l.authRegisterTitle, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(l.authWhy, textAlign: TextAlign.center, style: const TextStyle(color: K.muted, height: 1.35)),
            const SizedBox(height: 14),
            if (offline) ...[
              Text(l.authNeedsServer, textAlign: TextAlign.center, style: const TextStyle(color: K.warn, height: 1.35)),
              const SizedBox(height: 12),
            ] else ...[
              SegmentedButton<bool>(
                showSelectedIcon: false,
                segments: [ButtonSegment(value: false, label: Text(l.authRegister)), ButtonSegment(value: true, label: Text(l.authLogin))],
                selected: {_login},
                onSelectionChanged: (s) => setState(() {
                  _login = s.first;
                  _error = null;
                }),
              ),
              const SizedBox(height: 12),
              if (!_login) ...[
                TextField(controller: _name, maxLength: 40, textInputAction: TextInputAction.next, autofillHints: const [AutofillHints.nickname], decoration: InputDecoration(labelText: l.authName, counterText: '')),
                const SizedBox(height: 10),
              ],
              TextField(controller: _email, keyboardType: TextInputType.emailAddress, textInputAction: TextInputAction.next, autofillHints: const [AutofillHints.email], decoration: InputDecoration(labelText: l.authEmail)),
              const SizedBox(height: 10),
              TextField(
                controller: _password,
                obscureText: _obscure,
                autofillHints: [_login ? AutofillHints.password : AutofillHints.newPassword],
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  labelText: l.authPassword,
                  helperText: _login ? null : l.authPasswordHint(minPasswordLength),
                  suffixIcon: IconButton(
                    tooltip: l.authShowPassword,
                    icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              // A security game has to say this: without HTTPS, everyone on the Wi-Fi could read along.
              if (Config.insecureConnection)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Icon(Icons.warning_amber_rounded, size: 17, color: K.warn),
                    const SizedBox(width: 6),
                    Expanded(child: Text(l.authInsecure, style: const TextStyle(color: K.warn, fontSize: 13, height: 1.35))),
                  ]),
                ),
              if (_error != null) Padding(padding: const EdgeInsets.only(top: 10), child: Text(_error!, style: const TextStyle(color: K.danger, fontWeight: FontWeight.w600))),
              const SizedBox(height: 14),
              FilledButton(
                onPressed: _busy ? null : _submit,
                child: _busy ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text(_login ? l.authLogin : l.authRegister),
              ),
            ],
            if (widget.onGuest != null) ...[
              const SizedBox(height: 6),
              TextButton(onPressed: widget.onGuest, child: Text(l.authGuest)),
            ],
          ]),
        ),
      ),
    );
  }
}

/// The same form as a screen of its own, reached from the profile.
class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key, this.login = false});
  final bool login;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
          child: AuthForm(startWithLogin: login, onSignedIn: (_) => context.go('/')),
        ),
      ),
    );
  }
}
