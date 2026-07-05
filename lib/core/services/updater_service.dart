import 'package:flutter/material.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

import '../../shared/widgets.dart';

/// Shorebird over-the-air patching.
///
/// Releases built with `shorebird release android` auto-update on launch
/// (auto_update is on in shorebird.yaml). This service adds a manual
/// "check now" path with UI feedback, and reports the current patch number.
/// When the app isn't running under Shorebird (e.g. a plain `flutter build`),
/// everything no-ops gracefully.
class UpdaterService {
  UpdaterService._();
  static final instance = UpdaterService._();

  final _updater = ShorebirdUpdater();

  bool get isAvailable => _updater.isAvailable;

  Future<int?> currentPatchNumber() async {
    try {
      final patch = await _updater.readCurrentPatch();
      return patch?.number;
    } catch (_) {
      return null;
    }
  }

  /// Checks + downloads any pending patch, with snackbar feedback.
  Future<void> checkForUpdates(BuildContext context) async {
    if (!_updater.isAvailable) {
      showSnack(context,
          'Code push inactive (this build wasn\'t made with Shorebird)');
      return;
    }
    showSnack(context, 'Checking for updates…');
    try {
      final status = await _updater.checkForUpdate();
      if (!context.mounted) return;
      switch (status) {
        case UpdateStatus.upToDate:
          showSnack(context, 'You\'re on the latest version ✅');
        case UpdateStatus.outdated:
          showSnack(context, 'Update found — downloading…');
          await _updater.update();
          if (context.mounted) {
            _promptRestart(context);
          }
        case UpdateStatus.restartRequired:
          _promptRestart(context);
        case UpdateStatus.unavailable:
          showSnack(context, 'Updater unavailable on this build');
      }
    } on UpdateException catch (e) {
      if (context.mounted) showSnack(context, 'Update failed: ${e.message}');
    } catch (e) {
      if (context.mounted) showSnack(context, 'Update failed: $e');
    }
  }

  void _promptRestart(BuildContext context) {
    showDialog(
      context: context,
      builder: (dCtx) => AlertDialog(
        title: const Text('Update ready 🎉'),
        content: const Text(
            'A new patch has been downloaded. Restart the app to apply it.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dCtx),
              child: const Text('Later')),
        ],
      ),
    );
  }
}
