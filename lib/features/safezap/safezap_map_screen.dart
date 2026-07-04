import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../core/utils/aes_helper.dart';
import '../../shared/models.dart';
import '../../shared/widgets.dart';
import '../auth/auth_provider.dart';
import '../groups/group_provider.dart';
import 'safezap_service.dart';

class DecodedEvent {
  final String senderId;
  final String trigger; // auto_24hr | secret_code | safe_word
  final double lat;
  final double lng;
  final DateTime at;
  final bool isLive;

  DecodedEvent({
    required this.senderId,
    required this.trigger,
    required this.lat,
    required this.lng,
    required this.at,
    required this.isLive,
  });

  Color get color => switch (trigger) {
        'safe_word' => Colors.red,
        _ => isLive ? Colors.green : Colors.orange,
      };
}

/// Decodes location_events from the backend using the group AES key.
final safeZapEventsProvider = FutureProvider<List<DecodedEvent>>((ref) async {
  final gid = ref.watch(activeGroupIdProvider);
  final group = ref.watch(activeGroupProvider).valueOrNull;
  if (gid == null || group == null) return [];
  final rows = await ref
      .watch(supabaseProvider)
      .from('location_events')
      .select()
      .eq('group_id', gid)
      .order('created_at', ascending: false)
      .limit(40);
  final aes = AesHelper.forGroup(group.id, group.aesSalt);
  final out = <DecodedEvent>[];
  for (final r in (rows as List)) {
    final ev = LocationEvent.fromJson((r as Map).cast<String, dynamic>());
    final decoded = aes.decryptText(ev.encryptedCoords);
    if (decoded == null) continue;
    final parts = decoded.split(',');
    if (parts.length < 2) continue;
    final lat = double.tryParse(parts[0]);
    final lng = double.tryParse(parts[1]);
    if (lat == null || lng == null) continue;
    out.add(DecodedEvent(
      senderId: ev.senderId,
      trigger: ev.triggerType,
      lat: lat,
      lng: lng,
      at: ev.createdAt,
      isLive: ev.isLiveGps,
    ));
  }
  return out;
});

class SafeZapMapScreen extends ConsumerWidget {
  const SafeZapMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(safeZapEventsProvider);
    final members = ref.watch(groupMembersProvider).valueOrNull ?? [];
    final sz = ref.read(safeZapServiceProvider);

    String roleOf(String uid) {
      for (final m in members) {
        if (m.userId == uid) return m.roleName;
      }
      return 'member';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('SafeZap 🗺️'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettings(context, ref),
          ),
        ],
      ),
      body: events.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(emoji: '😵', message: 'Error: $e'),
        data: (list) {
          final center = list.isNotEmpty
              ? LatLng(list.first.lat, list.first.lng)
              : const LatLng(20.5937, 78.9629); // India centroid fallback
          return Column(
            children: [
              Expanded(
                child: FlutterMap(
                  options: MapOptions(initialCenter: center, initialZoom: 12),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.pikanda.app',
                    ),
                    MarkerLayer(
                      markers: [
                        for (final e in list)
                          Marker(
                            point: LatLng(e.lat, e.lng),
                            width: 44,
                            height: 44,
                            child: Icon(Icons.location_on,
                                color: e.color, size: 44),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 150,
                child: list.isEmpty
                    ? const Center(child: Text('No location events yet'))
                    : ListView(
                        children: [
                          for (final e in list.take(10))
                            ListTile(
                              dense: true,
                              leading:
                                  Icon(Icons.circle, color: e.color, size: 14),
                              title: Text(
                                  '${roleOf(e.senderId)} · ${_label(e.trigger)}'),
                              subtitle: Text(
                                  '${e.isLive ? 'Live' : 'Cached'} · ${_ago(e.at)}'),
                            ),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.red,
        onPressed: () async {
          final ok = await showDialog<bool>(
            context: context,
            builder: (dCtx) => AlertDialog(
              title: const Text('Share your location now?'),
              content: const Text(
                  'This sends your current location to everyone in the group.'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(dCtx, false),
                    child: const Text('Cancel')),
                FilledButton(
                    onPressed: () => Navigator.pop(dCtx, true),
                    child: const Text('Share now')),
              ],
            ),
          );
          if (ok == true) {
            await sz.fireTrigger('secret_code');
            ref.invalidate(safeZapEventsProvider);
            if (context.mounted) showSnack(context, 'Location shared 📍');
          }
        },
        icon: const Icon(Icons.my_location),
        label: const Text('Share location'),
      ),
    );
  }

  static String _label(String t) => switch (t) {
        'safe_word' => '🚨 Emergency',
        'secret_code' => '📍 Requested',
        _ => '⏰ 24h check-in',
      };

  static String _ago(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return 'just now';
    if (d.inHours < 1) return '${d.inMinutes}m ago';
    if (d.inDays < 1) return '${d.inHours}h ago';
    return '${d.inDays}d ago';
  }

  void _showSettings(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _SafeZapSettings(),
    );
  }
}

class _SafeZapSettings extends ConsumerStatefulWidget {
  const _SafeZapSettings();

  @override
  ConsumerState<_SafeZapSettings> createState() => _SafeZapSettingsState();
}

class _SafeZapSettingsState extends ConsumerState<_SafeZapSettings> {
  bool _enabled = false;
  bool _loading = true;
  final _phone = TextEditingController();
  final _code = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final enabled = await ref.read(safeZapServiceProvider).isEnabled();
    final profile = await ref.read(myProfileProvider.future);
    setState(() {
      _enabled = enabled;
      _phone.text = profile?.phoneNumber ?? '';
      _loading = false;
    });
  }

  @override
  void dispose() {
    _phone.dispose();
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sz = ref.read(safeZapServiceProvider);
    final isAdmin = ref.watch(isAdminProvider);

    if (_loading) {
      return const SizedBox(
          height: 200, child: Center(child: CircularProgressIndicator()));
    }

    return Padding(
      padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SafeZap settings',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(
              sz.smsSupported
                  ? 'SMS triggers work on this Android device.'
                  : 'SMS features are Android-only; location sharing over the internet still works.',
              style: TextStyle(
                  fontSize: 12, color: Colors.white.withValues(alpha: 0.5))),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Enable SafeZap'),
            subtitle: const Text('24h watchdog + secret code + safe word'),
            value: _enabled,
            onChanged: (v) async {
              await sz.setEnabled(v);
              setState(() => _enabled = v);
            },
          ),
          TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
                labelText: 'Your phone number (for SMS alerts)',
                prefixIcon: Icon(Icons.phone)),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () async {
              final uid = ref.read(currentUserIdProvider);
              if (uid != null) {
                await ref
                    .read(supabaseProvider)
                    .from('users')
                    .update({'phone_number': _phone.text.trim()}).eq('id', uid);
                ref.invalidate(myProfileProvider);
                if (context.mounted) showSnack(context, 'Saved');
              }
            },
            child: const Text('Save phone number'),
          ),
          if (isAdmin) ...[
            const Divider(height: 32),
            const Text('Group secret code',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const Text(
                'Anyone who texts this exact code to a member\'s phone triggers their location share.',
                style: TextStyle(fontSize: 12)),
            const SizedBox(height: 8),
            TextField(
              controller: _code,
              decoration: const InputDecoration(
                  labelText: 'New secret code', prefixIcon: Icon(Icons.key)),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () async {
                if (_code.text.trim().isEmpty) return;
                final gid = ref.read(activeGroupIdProvider)!;
                final uid = ref.read(currentUserIdProvider)!;
                await ref.read(supabaseProvider).from('safe_codes').upsert({
                  'group_id': gid,
                  'code': AesHelper.hashSafeCode(_code.text),
                  'created_by': uid,
                }, onConflict: 'group_id');
                _code.clear();
                if (context.mounted) showSnack(context, 'Secret code set 🔐');
              },
              child: const Text('Set secret code'),
            ),
          ],
          const SizedBox(height: 8),
          const Text('Triple-tap the 🐼⚡ logo anywhere to silently share your '
              'location in an emergency.',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}
