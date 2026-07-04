import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets.dart';
import 'auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  bool _obscure = true;

  Future<void> _login() async {
    if (_email.text.trim().isEmpty || _password.text.isEmpty) {
      showSnack(context, 'Enter your email and password');
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(authControllerProvider).signIn(
          email: _email.text.trim(), password: _password.text);
      if (mounted) context.go('/');
    } catch (e) {
      if (mounted) showSnack(context, 'Login failed: ${_friendly(e)}');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _friendly(Object e) {
    final s = e.toString();
    if (s.contains('Invalid login')) return 'wrong email or password';
    return s.length > 80 ? '${s.substring(0, 80)}…' : s;
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🐼⚡', style: TextStyle(fontSize: 72)),
                const SizedBox(height: 8),
                Text('Pikanda',
                    style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.primary)),
                const SizedBox(height: 4),
                Text('your people, in your pocket',
                    style:
                        TextStyle(color: Colors.white.withValues(alpha: 0.5))),
                const SizedBox(height: 40),
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  decoration: const InputDecoration(
                      labelText: 'Email', prefixIcon: Icon(Icons.mail_outline)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _password,
                  obscureText: _obscure,
                  onSubmitted: (_) => _login(),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _obscure ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _busy ? null : _login,
                    child: _busy
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Sign In'),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.go('/register'),
                  child: const Text('New here? Create an account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
