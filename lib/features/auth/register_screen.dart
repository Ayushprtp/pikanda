import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets.dart';
import 'auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;

  Future<void> _register() async {
    final username = _username.text.trim();
    if (username.length < 3) {
      showSnack(context, 'Username needs at least 3 characters');
      return;
    }
    if (!_email.text.contains('@')) {
      showSnack(context, 'Enter a valid email');
      return;
    }
    if (_password.text.length < 8) {
      showSnack(context, 'Password needs at least 8 characters');
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(authControllerProvider).signUp(
            email: _email.text.trim(),
            password: _password.text,
            username: username,
          );
      if (mounted) context.go('/');
    } catch (e) {
      if (mounted) showSnack(context, 'Sign up failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Text('🐣', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 24),
              TextField(
                controller: _username,
                autocorrect: false,
                decoration: const InputDecoration(
                    labelText: 'Username',
                    helperText: 'How friends find you (unique)',
                    prefixIcon: Icon(Icons.alternate_email)),
              ),
              const SizedBox(height: 12),
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
                obscureText: true,
                decoration: const InputDecoration(
                    labelText: 'Password (8+ chars)',
                    prefixIcon: Icon(Icons.lock_outline)),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _busy ? null : _register,
                  child: _busy
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Create Account'),
                ),
              ),
              TextButton(
                onPressed: () => context.go('/login'),
                child: const Text('Already have an account? Sign in'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
