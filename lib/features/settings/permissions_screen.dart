import 'package:flutter/material.dart';

import '../../core/services/permission_service.dart';
import '../../shared/widgets.dart';

/// Shows every permission the app can use, its live status, and lets the
/// user grant it (or jump to system settings when permanently denied).
class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen>
    with WidgetsBindingObserver {
  final Map<String, bool> _granted = {};
  final Map<String, bool> _blocked = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh when the user comes back from system settings.
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    for (final p in PermissionService.all) {
      if (!p.availableHere) continue;
      _granted[p.key] = await p.isGranted;
      _blocked[p.key] = await p.isPermanentlyDenied;
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _request(AppPermission p) async {
    final ok = await p.request();
    if (!ok && await p.isPermanentlyDenied && mounted) {
      showSnack(context,
          'Blocked by the system — opening settings so you can allow it');
      await PermissionService.openSettings();
    }
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final items =
        PermissionService.all.where((p) => p.availableHere).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Permissions 🔐')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                SectionCard(
                  child: Text(
                    'Pikanda only asks for what a feature actually needs, '
                    'and everything keeps working (minus that feature) if '
                    'you say no.',
                    style:
                        TextStyle(color: Colors.white.withValues(alpha: 0.65)),
                  ),
                ),
                for (final p in items)
                  SectionCard(
                    child: Row(
                      children: [
                        Text(p.emoji, style: const TextStyle(fontSize: 30)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.title,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700)),
                              Text(p.why,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white
                                          .withValues(alpha: 0.55))),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        _granted[p.key] == true
                            ? const Chip(
                                avatar: Icon(Icons.check_circle,
                                    color: Colors.green, size: 18),
                                label: Text('On'),
                              )
                            : FilledButton.tonal(
                                onPressed: () => _request(p),
                                child: Text(_blocked[p.key] == true
                                    ? 'Settings'
                                    : 'Allow'),
                              ),
                      ],
                    ),
                  ),
                SectionCard(
                  onTap: PermissionService.openSettings,
                  child: const Row(
                    children: [
                      Icon(Icons.settings),
                      SizedBox(width: 10),
                      Text('Open system app settings'),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
