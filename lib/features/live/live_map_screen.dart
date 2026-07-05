import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:vibration/vibration.dart';

import '../../features/widget/home_widget_service.dart';
import '../../shared/widgets.dart';
import '../auth/auth_provider.dart';
import '../groups/group_provider.dart';
import 'live_location_service.dart';
import 'live_provider.dart';

/// Live map + real-time distance to every group member.
class LiveMapScreen extends ConsumerStatefulWidget {
  const LiveMapScreen({super.key});

  @override
  ConsumerState<LiveMapScreen> createState() => _LiveMapScreenState();
}

class _LiveMapScreenState extends ConsumerState<LiveMapScreen> {
  final _map = MapController();
  bool _sharing = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    LiveLocationService.instance.isSharing().then((v) {
      if (mounted) {
        setState(() {
          _sharing = v;
          _loading = false;
        });
      }
    });
  }

  Future<void> _toggleShare(bool v) async {
    setState(() => _sharing = v);
    await LiveLocationService.instance.setSharing(v);
    if (v && mounted) {
      showSnack(context, 'Live location on — your people can see you 📍');
    } else if (mounted) {
      showSnack(context, 'Live location off');
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(locationRealtimeProvider); // keep realtime alive
    final distances = ref.watch(memberDistancesProvider);
    final myLoc = ref.watch(myLocationProvider);
    final myId = ref.watch(currentUserIdProvider);
    final members = ref.watch(groupMembersProvider).valueOrNull ?? [];

    // Feed nearest-distance into the ongoing notification + home widget.
    if (_sharing && distances.isNotEmpty && distances.first.km != null) {
      final n = distances.first;
      LiveLocationService.instance.updateOngoingNotification(
          nearestName: n.roleName, distanceText: n.distanceText);
      if (myLoc != null) {
        HomeWidgetService.updateDistances(
          myLat: myLoc.lat,
          myLng: myLoc.lng,
          members: [
            for (final d in distances)
              (name: d.roleName, lat: d.location.lat, lng: d.location.lng)
          ],
        );
      }
    }

    final center = myLoc != null
        ? LatLng(myLoc.lat, myLoc.lng)
        : distances.isNotEmpty
            ? LatLng(distances.first.location.lat, distances.first.location.lng)
            : const LatLng(20.5937, 78.9629);

    return Scaffold(
      appBar: AppBar(title: const Text('Live Map 📍')),
      body: Column(
        children: [
          if (!_loading)
            SwitchListTile(
              secondary: Icon(_sharing ? Icons.location_on : Icons.location_off,
                  color: _sharing
                      ? Theme.of(context).colorScheme.primary
                      : null),
              title: const Text('Share my live location'),
              subtitle: Text(_sharing
                  ? 'Your people see your position in real time'
                  : 'Turn on to share where you are'),
              value: _sharing,
              onChanged: _toggleShare,
            ),
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _map,
                  options: MapOptions(initialCenter: center, initialZoom: 12),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.pikanda.app',
                    ),
                    MarkerLayer(
                      markers: [
                        if (myLoc != null)
                          Marker(
                            point: LatLng(myLoc.lat, myLoc.lng),
                            width: 60,
                            height: 60,
                            child: const _PinLabel(
                                emoji: '🙂', label: 'you', live: true),
                          ),
                        for (final d in distances)
                          Marker(
                            point: LatLng(
                                d.location.lat, d.location.lng),
                            width: 72,
                            height: 60,
                            child: _PinLabel(
                                emoji: '🐼',
                                label: d.roleName,
                                live: d.location.isLive),
                          ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: FloatingActionButton.small(
                    onPressed: myLoc == null
                        ? null
                        : () => _map.move(
                            LatLng(myLoc.lat, myLoc.lng), 14),
                    child: const Icon(Icons.my_location),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: distances.isEmpty
                ? EmptyState(
                    emoji: '🗺️',
                    message: myLoc == null
                        ? 'Turn on live location to see distances'
                        : 'No one else is sharing yet')
                : ListView(
                    children: [
                      for (final d in distances)
                        Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: d.location.isLive
                                  ? Colors.green.withValues(alpha: 0.3)
                                  : Colors.grey.withValues(alpha: 0.3),
                              child: Text(d.roleName.isEmpty
                                  ? '?'
                                  : d.roleName[0].toUpperCase()),
                            ),
                            title: Text(d.roleName),
                            subtitle: Row(
                              children: [
                                Icon(Icons.circle,
                                    size: 8,
                                    color: d.location.isLive
                                        ? Colors.green
                                        : Colors.grey),
                                const SizedBox(width: 4),
                                Text(d.location.isLive
                                    ? 'live · ${d.location.freshness}'
                                    : d.location.freshness),
                                if (d.location.battery != null) ...[
                                  const SizedBox(width: 8),
                                  Text('🔋${d.location.battery}%'),
                                ],
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(d.distanceText,
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800)),
                                const Text('away',
                                    style: TextStyle(fontSize: 11)),
                              ],
                            ),
                            onTap: () async {
                              // "Thinking of you" nudge with a heartbeat buzz.
                              final target = members.firstWhere(
                                  (m) => m.userId == d.userId,
                                  orElse: () => members.first);
                              await ref.read(supabaseProvider).from('pokes').insert({
                                'group_id': target.groupId,
                                'from_user': myId,
                                'to_user': d.userId,
                              });
                              if (await Vibration.hasVibrator()) {
                                Vibration.vibrate(
                                    pattern: [0, 120, 80, 120, 80, 300]);
                              }
                              if (context.mounted) {
                                showSnack(context,
                                    'Sent ${d.roleName} a 💓 thinking-of-you');
                              }
                            },
                          ),
                        ),
                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: Text('Tap a person to send a 💓 nudge',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _PinLabel extends StatelessWidget {
  final String emoji;
  final String label;
  final bool live;
  const _PinLabel(
      {required this.emoji, required this.label, required this.live});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(
            color: live ? Colors.green.shade700 : Colors.grey.shade700,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(label,
              style: const TextStyle(fontSize: 10, color: Colors.white)),
        ),
        Text(emoji, style: const TextStyle(fontSize: 26)),
      ],
    );
  }
}
