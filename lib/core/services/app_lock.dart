import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Biometric app lock: when enabled, the app requires fingerprint/face
/// unlock on launch and whenever it returns from the background.
class AppLockController extends Notifier<bool /* locked */> {
  static const _kEnabled = 'app_lock_enabled';
  final _auth = LocalAuthentication();
  bool _enabled = false;

  @override
  bool build() {
    _load();
    return false;
  }

  bool get enabled => _enabled;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(_kEnabled) ?? false;
    if (_enabled) {
      state = true; // start locked
      unlock();
    }
  }

  Future<bool> canUseBiometrics() async {
    try {
      return await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  Future<bool> setEnabled(bool on) async {
    if (on) {
      // prove the user can actually unlock before turning it on
      final ok = await _authenticate('Confirm to enable app lock');
      if (!ok) return false;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kEnabled, on);
    _enabled = on;
    state = false;
    return true;
  }

  /// Called when the app resumes from background.
  void onAppResumed() {
    if (_enabled && !state) {
      state = true;
      unlock();
    }
  }

  Future<void> unlock() async {
    final ok = await _authenticate('Unlock Pikanda');
    if (ok) state = false;
  }

  Future<bool> _authenticate(String reason) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // fall back to device PIN/pattern
        ),
      );
    } catch (e) {
      debugPrint('local_auth failed: $e');
      // Device without any lock configured: never brick the app.
      return true;
    }
  }
}

final appLockProvider =
    NotifierProvider<AppLockController, bool>(AppLockController.new);

/// Fullscreen gate shown while locked.
class LockGate extends ConsumerStatefulWidget {
  final Widget child;
  const LockGate({super.key, required this.child});

  @override
  ConsumerState<LockGate> createState() => _LockGateState();
}

class _LockGateState extends ConsumerState<LockGate>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(appLockProvider.notifier).onAppResumed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final locked = ref.watch(appLockProvider);
    if (!locked) return widget.child;

    return Material(
      color: const Color(0xFF0D0D12),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🐼⚡', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 12),
            const Text('Pikanda is locked',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => ref.read(appLockProvider.notifier).unlock(),
              icon: const Icon(Icons.fingerprint),
              label: const Text('Unlock'),
            ),
          ],
        ),
      ),
    );
  }
}
