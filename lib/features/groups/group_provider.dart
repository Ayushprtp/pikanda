import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/models.dart';
import '../auth/auth_provider.dart';

/// All groups the user belongs to.
final myGroupsProvider = FutureProvider<List<Group>>((ref) async {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return [];
  final rows = await ref
      .watch(supabaseProvider)
      .from('group_members')
      .select('group_id, groups(*)')
      .eq('user_id', uid);
  return (rows as List)
      .where((r) => r['groups'] != null)
      .map((r) => Group.fromJson((r['groups'] as Map).cast<String, dynamic>()))
      .toList();
});

/// Currently active group id (persisted).
class ActiveGroupNotifier extends Notifier<String?> {
  @override
  String? build() {
    _load();
    return null;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('active_group_id');
    if (id != null) state = id;
  }

  Future<void> setActive(String groupId) async {
    state = groupId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('active_group_id', groupId);
  }

  Future<void> clear() async {
    state = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('active_group_id');
  }
}

final activeGroupIdProvider =
    NotifierProvider<ActiveGroupNotifier, String?>(ActiveGroupNotifier.new);

/// The active group row (refreshed on demand).
final activeGroupProvider = FutureProvider<Group?>((ref) async {
  final gid = ref.watch(activeGroupIdProvider);
  if (gid == null) return null;
  final row = await ref
      .watch(supabaseProvider)
      .from('groups')
      .select()
      .eq('id', gid)
      .maybeSingle();
  return row == null ? null : Group.fromJson(row);
});

/// Members of the active group with profiles.
final groupMembersProvider = FutureProvider<List<GroupMember>>((ref) async {
  final gid = ref.watch(activeGroupIdProvider);
  if (gid == null) return [];
  final rows = await ref
      .watch(supabaseProvider)
      .from('group_members')
      .select('*, users(*)')
      .eq('group_id', gid)
      .order('joined_at');
  return (rows as List)
      .map((r) => GroupMember.fromJson((r as Map).cast<String, dynamic>()))
      .toList();
});

/// My membership row in the active group (role name, admin flag).
final myMembershipProvider = Provider<GroupMember?>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  final members = ref.watch(groupMembersProvider).valueOrNull;
  if (uid == null || members == null) return null;
  for (final m in members) {
    if (m.userId == uid) return m;
  }
  return null;
});

final isAdminProvider =
    Provider<bool>((ref) => ref.watch(myMembershipProvider)?.isAdmin ?? false);

/// Custom mood labels for the active group.
final moodLabelsProvider = FutureProvider<Map<String, String>>((ref) async {
  final gid = ref.watch(activeGroupIdProvider);
  if (gid == null) return {};
  final row = await ref
      .watch(supabaseProvider)
      .from('group_mood_config')
      .select('config')
      .eq('group_id', gid)
      .maybeSingle();
  if (row == null) return {};
  final cfg = row['config'];
  final map = cfg is String ? jsonDecode(cfg) : cfg;
  return (map as Map).map((k, v) => MapEntry(k.toString(), v.toString()));
});

class GroupController {
  final Ref ref;
  GroupController(this.ref);

  Future<Group> createGroup(String name, String roleName) async {
    final row = await ref.read(supabaseProvider).rpc('create_group',
        params: {'p_name': name, 'p_role_name': roleName});
    final g = Group.fromJson((row as Map).cast<String, dynamic>());
    await ref.read(activeGroupIdProvider.notifier).setActive(g.id);
    ref.invalidate(myGroupsProvider);
    return g;
  }

  Future<Group> joinGroup(String inviteCode, String roleName) async {
    final row = await ref.read(supabaseProvider).rpc('join_group',
        params: {'p_invite_code': inviteCode, 'p_role_name': roleName});
    final g = Group.fromJson((row as Map).cast<String, dynamic>());
    await ref.read(activeGroupIdProvider.notifier).setActive(g.id);
    ref.invalidate(myGroupsProvider);
    return g;
  }

  void refreshAll() {
    ref.invalidate(myGroupsProvider);
    ref.invalidate(activeGroupProvider);
    ref.invalidate(groupMembersProvider);
    ref.invalidate(moodLabelsProvider);
  }
}

final groupControllerProvider = Provider((ref) => GroupController(ref));
