import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/utils/geo.dart';
import '../../shared/models.dart';
import '../auth/auth_provider.dart';
import '../groups/group_provider.dart';

/// One group member's live position + computed distance from me.
class MemberDistance {
  final String userId;
  final String roleName;
  final UserLocation location;
  final double? km; // null if my own location unknown

  MemberDistance({
    required this.userId,
    required this.roleName,
    required this.location,
    this.km,
  });

  String get distanceText => km == null ? '—' : formatDistance(km!);
}

/// Streams all group members' locations, refreshing on realtime changes AND
/// on a 5s ticker (so "freshness"/distance stays current even without events).
final _locationsTickProvider = StreamProvider<int>((ref) async* {
  var i = 0;
  yield i;
  await for (final _ in Stream.periodic(const Duration(seconds: 5))) {
    yield ++i;
  }
});

final memberLocationsProvider =
    FutureProvider<List<UserLocation>>((ref) async {
  ref.watch(_locationsTickProvider); // periodic refresh
  final gid = ref.watch(activeGroupIdProvider);
  final members = ref.watch(groupMembersProvider).valueOrNull ?? [];
  if (gid == null || members.isEmpty) return [];
  final ids = members.map((m) => m.userId).toList();
  final rows = await ref
      .watch(supabaseProvider)
      .from('user_locations')
      .select()
      .inFilter('user_id', ids);
  return (rows as List)
      .map((r) => UserLocation.fromJson((r as Map).cast<String, dynamic>()))
      .toList();
});

/// Realtime subscription that invalidates the locations when any row changes.
final locationRealtimeProvider = Provider<void>((ref) {
  final channel = ref
      .watch(supabaseProvider)
      .channel('user_locations_live')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'user_locations',
        callback: (_) => ref.invalidate(memberLocationsProvider),
      )
      .subscribe();
  ref.onDispose(() => channel.unsubscribe());
});

/// My own most recent location (for distance math).
final myLocationProvider = Provider<UserLocation?>((ref) {
  final me = ref.watch(currentUserIdProvider);
  final locs = ref.watch(memberLocationsProvider).valueOrNull ?? [];
  for (final l in locs) {
    if (l.userId == me) return l;
  }
  return null;
});

/// Distances from me to every other member, nearest first.
final memberDistancesProvider = Provider<List<MemberDistance>>((ref) {
  final me = ref.watch(currentUserIdProvider);
  final myLoc = ref.watch(myLocationProvider);
  final locs = ref.watch(memberLocationsProvider).valueOrNull ?? [];
  final members = ref.watch(groupMembersProvider).valueOrNull ?? [];

  String roleOf(String uid) {
    for (final m in members) {
      if (m.userId == uid) return m.roleName;
    }
    return 'member';
  }

  final out = <MemberDistance>[];
  for (final l in locs) {
    if (l.userId == me) continue;
    final km = myLoc == null
        ? null
        : haversineKm(myLoc.lat, myLoc.lng, l.lat, l.lng);
    out.add(MemberDistance(
        userId: l.userId, roleName: roleOf(l.userId), location: l, km: km));
  }
  out.sort((a, b) => (a.km ?? 1e9).compareTo(b.km ?? 1e9));
  return out;
});
