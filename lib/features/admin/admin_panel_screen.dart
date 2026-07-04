import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../core/utils/aes_helper.dart';
import '../../shared/models.dart';
import '../../shared/widgets.dart';
import '../auth/auth_provider.dart';
import '../groups/group_provider.dart';

class AdminPanelScreen extends ConsumerWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isAdminProvider);
    if (!isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin')),
        body: const EmptyState(emoji: '🔒', message: 'Admins only'),
      );
    }
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Panel 🛠️'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Quotes'),
              Tab(text: 'Songs'),
              Tab(text: 'Members'),
              Tab(text: 'Theme'),
              Tab(text: 'Mood Labels'),
              Tab(text: 'Safe Code'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _QuotesTab(),
            _SongsTab(),
            _MembersTab(),
            _ThemeTab(),
            _MoodLabelsTab(),
            _SafeCodeTab(),
          ],
        ),
      ),
    );
  }
}

// ---------------------------- Quotes ----------------------------

final _groupQuotesProvider = FutureProvider<List<Quote>>((ref) async {
  final gid = ref.watch(activeGroupIdProvider);
  if (gid == null) return [];
  final rows = await ref
      .watch(supabaseProvider)
      .from('quotes')
      .select()
      .eq('group_id', gid)
      .order('created_at', ascending: false);
  return (rows as List)
      .map((r) => Quote.fromJson((r as Map).cast<String, dynamic>()))
      .toList();
});

class _QuotesTab extends ConsumerWidget {
  const _QuotesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quotes = ref.watch(_groupQuotesProvider);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addQuote(context, ref),
        child: const Icon(Icons.add),
      ),
      body: quotes.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(emoji: '😵', message: 'Error: $e'),
        data: (list) => list.isEmpty
            ? const EmptyState(
                emoji: '💬', message: 'Add custom quotes for each mood')
            : ListView(
                children: [
                  for (final q in list)
                    Dismissible(
                      key: ValueKey(q.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) async {
                        await ref
                            .read(supabaseProvider)
                            .from('quotes')
                            .delete()
                            .eq('id', q.id);
                        ref.invalidate(_groupQuotesProvider);
                      },
                      child: ListTile(
                        leading: Text(q.mood.emoji,
                            style: const TextStyle(fontSize: 24)),
                        title: Text(q.text),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  void _addQuote(BuildContext context, WidgetRef ref) {
    final text = TextEditingController();
    Mood mood = Mood.happy;
    showDialog(
      context: context,
      builder: (dCtx) => StatefulBuilder(
        builder: (dCtx, setLocal) => AlertDialog(
          title: const Text('Add quote'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                spacing: 6,
                children: [
                  for (final m in Mood.values)
                    ChoiceChip(
                      label: Text(m.emoji),
                      selected: mood == m,
                      onSelected: (_) => setLocal(() => mood = m),
                    ),
                ],
              ),
              TextField(
                  controller: text,
                  maxLines: 3,
                  minLines: 1,
                  decoration: const InputDecoration(hintText: 'Quote text')),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dCtx),
                child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                if (text.text.trim().isEmpty) return;
                final gid = ref.read(activeGroupIdProvider)!;
                final uid = ref.read(currentUserIdProvider)!;
                await ref.read(supabaseProvider).from('quotes').insert({
                  'group_id': gid,
                  'mood': mood.key,
                  'text': text.text.trim(),
                  'added_by': uid,
                });
                ref.invalidate(_groupQuotesProvider);
                if (dCtx.mounted) Navigator.pop(dCtx);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------- Songs ----------------------------

final _groupSongsProvider = FutureProvider<List<Song>>((ref) async {
  final gid = ref.watch(activeGroupIdProvider);
  if (gid == null) return [];
  final rows = await ref
      .watch(supabaseProvider)
      .from('songs')
      .select()
      .eq('group_id', gid)
      .order('created_at', ascending: false);
  return (rows as List)
      .map((r) => Song.fromJson((r as Map).cast<String, dynamic>()))
      .toList();
});

class _SongsTab extends ConsumerWidget {
  const _SongsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songs = ref.watch(_groupSongsProvider);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addSong(context, ref),
        child: const Icon(Icons.add),
      ),
      body: songs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(emoji: '😵', message: 'Error: $e'),
        data: (list) => list.isEmpty
            ? const EmptyState(
                emoji: '🎵',
                message: 'Add Spotify/YouTube songs per mood.\n'
                    'These power mood results and Vibe Sync.')
            : ListView(
                children: [
                  for (final s in list)
                    Dismissible(
                      key: ValueKey(s.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) async {
                        await ref
                            .read(supabaseProvider)
                            .from('songs')
                            .delete()
                            .eq('id', s.id);
                        ref.invalidate(_groupSongsProvider);
                      },
                      child: ListTile(
                        leading: Text(
                            '${s.mood.emoji}${s.platform == 'spotify' ? '🎧' : '▶️'}'),
                        title: Text(s.title),
                        subtitle: Text(s.artist ?? s.url),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  void _addSong(BuildContext context, WidgetRef ref) {
    final title = TextEditingController();
    final artist = TextEditingController();
    final url = TextEditingController();
    Mood mood = Mood.happy;
    String platform = 'youtube';
    showDialog(
      context: context,
      builder: (dCtx) => StatefulBuilder(
        builder: (dCtx, setLocal) => AlertDialog(
          title: const Text('Add song'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  spacing: 6,
                  children: [
                    for (final m in Mood.values)
                      ChoiceChip(
                        label: Text(m.emoji),
                        selected: mood == m,
                        onSelected: (_) => setLocal(() => mood = m),
                      ),
                  ],
                ),
                TextField(
                    controller: title,
                    decoration: const InputDecoration(labelText: 'Title')),
                TextField(
                    controller: artist,
                    decoration: const InputDecoration(labelText: 'Artist')),
                TextField(
                    controller: url,
                    decoration:
                        const InputDecoration(labelText: 'Spotify/YouTube URL')),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'youtube', label: Text('YouTube')),
                    ButtonSegment(value: 'spotify', label: Text('Spotify')),
                  ],
                  selected: {platform},
                  onSelectionChanged: (s) =>
                      setLocal(() => platform = s.first),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dCtx),
                child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                if (title.text.trim().isEmpty || url.text.trim().isEmpty) {
                  return;
                }
                final gid = ref.read(activeGroupIdProvider)!;
                final uid = ref.read(currentUserIdProvider)!;
                await ref.read(supabaseProvider).from('songs').insert({
                  'group_id': gid,
                  'mood': mood.key,
                  'title': title.text.trim(),
                  'artist': artist.text.trim(),
                  'url': url.text.trim(),
                  'platform': platform,
                  'added_by': uid,
                });
                ref.invalidate(_groupSongsProvider);
                if (dCtx.mounted) Navigator.pop(dCtx);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------- Members ----------------------------

class _MembersTab extends ConsumerWidget {
  const _MembersTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final members = ref.watch(groupMembersProvider);
    final group = ref.watch(activeGroupProvider).valueOrNull;
    final myId = ref.watch(currentUserIdProvider);

    return members.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => EmptyState(emoji: '😵', message: 'Error: $e'),
      data: (list) => ListView(
        children: [
          if (group != null)
            SectionCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Invite code',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                        SelectableText(group.inviteCode,
                            style: const TextStyle(
                                fontSize: 24, letterSpacing: 4)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(
                          ClipboardData(text: group.inviteCode));
                      showSnack(context, 'Copied');
                    },
                  ),
                ],
              ),
            ),
          for (final m in list)
            ListTile(
              leading: MemberAvatar(member: m, radius: 20),
              title: Text(m.roleName),
              subtitle: Text(m.user?.username ?? ''),
              trailing: Wrap(
                spacing: 4,
                children: [
                  if (m.isAdmin) const Chip(label: Text('Admin')),
                  if (m.userId != myId)
                    PopupMenuButton<String>(
                      onSelected: (v) async {
                        if (v == 'promote') {
                          await ref
                              .read(supabaseProvider)
                              .from('group_members')
                              .update({'is_admin': !m.isAdmin}).eq('id', m.id);
                        } else if (v == 'remove') {
                          await ref
                              .read(supabaseProvider)
                              .from('group_members')
                              .delete()
                              .eq('id', m.id);
                        }
                        ref.invalidate(groupMembersProvider);
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem(
                            value: 'promote',
                            child: Text(m.isAdmin
                                ? 'Demote from admin'
                                : 'Make admin')),
                        const PopupMenuItem(
                            value: 'remove', child: Text('Remove member')),
                      ],
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------- Theme ----------------------------

class _ThemeTab extends ConsumerStatefulWidget {
  const _ThemeTab();

  @override
  ConsumerState<_ThemeTab> createState() => _ThemeTabState();
}

class _ThemeTabState extends ConsumerState<_ThemeTab> {
  static const _presets = [
    (Color(0xFFFF6B6B), Color(0xFFFFE66D), 'Coral'),
    (Color(0xFF9C27B0), Color(0xFFE040FB), 'Purple'),
    (Color(0xFF00BCD4), Color(0xFF80DEEA), 'Ocean'),
    (Color(0xFF4CAF50), Color(0xFFC5E1A5), 'Forest'),
    (Color(0xFFFF9800), Color(0xFFFFE0B2), 'Sunset'),
    (Color(0xFFE91E63), Color(0xFFF8BBD0), 'Bubblegum'),
  ];

  Future<void> _apply(Color primary, Color accent, String font) async {
    final gid = ref.read(activeGroupIdProvider)!;
    final cfg = GroupThemeConfig(primary: primary, accent: accent, fontStyle: font);
    await ref
        .read(supabaseProvider)
        .from('groups')
        .update({'theme_config': cfg.toJson()}).eq('id', gid);
    ref.read(groupControllerProvider).refreshAll();
    if (mounted) showSnack(context, 'Theme updated 🎨');
  }

  @override
  Widget build(BuildContext context) {
    final group = ref.watch(activeGroupProvider).valueOrNull;
    final currentFont = group?.theme.fontStyle ?? 'rounded';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Colour theme',
            style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final (primary, accent, name) in _presets)
              GestureDetector(
                onTap: () => _apply(primary, accent, currentFont),
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [primary, accent]),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: group?.theme.primary == primary
                                ? Colors.white
                                : Colors.transparent,
                            width: 3),
                      ),
                    ),
                    Text(name, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
          ],
        ),
        const Divider(height: 32),
        const Text('Font style', style: TextStyle(fontWeight: FontWeight.w700)),
        for (final font in ['rounded', 'minimal', 'playful'])
          RadioListTile<String>(
            title: Text(font),
            value: font,
            // ignore: deprecated_member_use
            groupValue: currentFont,
            // ignore: deprecated_member_use
            onChanged: (v) {
              if (v != null && group != null) {
                _apply(group.theme.primary, group.theme.accent, v);
              }
            },
          ),
      ],
    );
  }
}

// ---------------------------- Mood Labels ----------------------------

class _MoodLabelsTab extends ConsumerStatefulWidget {
  const _MoodLabelsTab();

  @override
  ConsumerState<_MoodLabelsTab> createState() => _MoodLabelsTabState();
}

class _MoodLabelsTabState extends ConsumerState<_MoodLabelsTab> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    for (final m in Mood.values) {
      _controllers[m.key] = TextEditingController();
    }
    _load();
  }

  Future<void> _load() async {
    final labels = await ref.read(moodLabelsProvider.future);
    for (final m in Mood.values) {
      _controllers[m.key]!.text = labels[m.key] ?? '';
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final gid = ref.read(activeGroupIdProvider)!;
    final config = <String, String>{};
    for (final m in Mood.values) {
      final v = _controllers[m.key]!.text.trim();
      if (v.isNotEmpty) config[m.key] = v;
    }
    await ref.read(supabaseProvider).from('group_mood_config').upsert({
      'group_id': gid,
      'config': jsonEncode(config),
    }, onConflict: 'group_id');
    ref.invalidate(moodLabelsProvider);
    if (mounted) showSnack(context, 'Mood labels saved');
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Rename moods for your group',
            style: TextStyle(fontWeight: FontWeight.w700)),
        const Text('e.g. Happy → "Pikachu Energy ⚡"',
            style: TextStyle(fontSize: 12)),
        const SizedBox(height: 12),
        for (final m in Mood.values)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: TextField(
              controller: _controllers[m.key],
              decoration: InputDecoration(
                prefixText: '${m.emoji}  ',
                labelText: 'Label for ${m.key}',
              ),
            ),
          ),
        const SizedBox(height: 16),
        FilledButton(onPressed: _save, child: const Text('Save labels')),
      ],
    );
  }
}

// ---------------------------- Safe Code ----------------------------

class _SafeCodeTab extends ConsumerStatefulWidget {
  const _SafeCodeTab();

  @override
  ConsumerState<_SafeCodeTab> createState() => _SafeCodeTabState();
}

class _SafeCodeTabState extends ConsumerState<_SafeCodeTab> {
  final _code = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Group safe code 🔐',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text(
          'Set a secret word. If anyone texts this exact word to a group '
          'member\'s phone, that member\'s location is silently shared with '
          'the whole group (Android SMS feature). The code is stored hashed — '
          'even we cannot read it.',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.65)),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _code,
          decoration: const InputDecoration(
              labelText: 'New safe code', prefixIcon: Icon(Icons.key)),
        ),
        const SizedBox(height: 12),
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
            if (context.mounted) showSnack(context, 'Safe code set 🔐');
          },
          child: const Text('Set safe code'),
        ),
      ],
    );
  }
}
