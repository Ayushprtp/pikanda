import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../shared/models.dart';
import '../../shared/widgets.dart';
import '../auth/auth_provider.dart';
import 'group_provider.dart';

/// Shown when the user has no active group: pick one, create one, or join.
class GroupGateScreen extends ConsumerWidget {
  const GroupGateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(myGroupsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groups'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authControllerProvider).signOut();
              await ref.read(activeGroupIdProvider.notifier).clear();
            },
          ),
        ],
      ),
      body: groups.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(
            emoji: '😵',
            message: 'Could not load groups: $e',
            actionLabel: 'Retry',
            onAction: () => ref.invalidate(myGroupsProvider)),
        data: (list) => ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            if (list.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text('🐼⚡', style: TextStyle(fontSize: 64)),
                    SizedBox(height: 12),
                    Text('Pikanda works in small private groups.\n'
                        'Create one, or join with an invite code.',
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
            for (final g in list)
              SectionCard(
                onTap: () async {
                  await ref.read(activeGroupIdProvider.notifier).setActive(g.id);
                  if (context.mounted) context.go('/');
                },
                child: Row(
                  children: [
                    CircleAvatar(
                        backgroundColor:
                            g.theme.primary.withValues(alpha: 0.35),
                        child: Text(g.name[0].toUpperCase())),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(g.name,
                              style: const TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w600)),
                          Text('Lv ${g.level} · ${g.levelName}',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withValues(alpha: 0.5))),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _showCreateSheet(context, ref),
                      icon: const Icon(Icons.add),
                      label: const Text('Create'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showJoinSheet(context, ref),
                      icon: const Icon(Icons.group_add),
                      label: const Text('Join'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateSheet(BuildContext context, WidgetRef ref) {
    final name = TextEditingController();
    final role = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Create a group',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextField(
                controller: name,
                decoration: const InputDecoration(
                    labelText: 'Group name (e.g. Pikanda, Trio)')),
            const SizedBox(height: 12),
            TextField(
                controller: role,
                decoration: const InputDecoration(
                    labelText: 'Your name in this group (e.g. Panda)')),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  if (name.text.trim().isEmpty || role.text.trim().isEmpty) {
                    return;
                  }
                  try {
                    final g = await ref
                        .read(groupControllerProvider)
                        .createGroup(name.text.trim(), role.text.trim());
                    if (sheetCtx.mounted) {
                      Navigator.pop(sheetCtx);
                      _showInviteCode(context, g);
                    }
                  } catch (e) {
                    if (sheetCtx.mounted) showSnack(sheetCtx, 'Failed: $e');
                  }
                },
                child: const Text('Create Group'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInviteCode(BuildContext context, Group g) {
    showDialog(
      context: context,
      builder: (dCtx) => AlertDialog(
        title: const Text('Group created! 🎉'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Share this invite code with your people:'),
            const SizedBox(height: 12),
            SelectableText(g.inviteCode,
                style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 6)),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(dCtx);
                dCtx.mounted ? null : null;
              },
              child: const Text('Done')),
        ],
      ),
    ).then((_) {
      if (context.mounted) context.go('/');
    });
  }

  void _showJoinSheet(BuildContext context, WidgetRef ref) {
    final code = TextEditingController();
    final role = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Join a group',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextField(
              controller: code,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                labelText: 'Invite code',
                suffixIcon: IconButton(
                  tooltip: 'Scan QR',
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: () async {
                    final scanned = await Navigator.push<String>(
                        sheetCtx,
                        MaterialPageRoute(
                            builder: (_) => const _QrScanScreen()));
                    if (scanned != null) code.text = scanned;
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
                controller: role,
                decoration: const InputDecoration(
                    labelText: 'Your name in this group (e.g. Pikachu)')),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  if (code.text.trim().isEmpty || role.text.trim().isEmpty) {
                    return;
                  }
                  try {
                    await ref
                        .read(groupControllerProvider)
                        .joinGroup(code.text.trim(), role.text.trim());
                    if (sheetCtx.mounted) Navigator.pop(sheetCtx);
                    if (context.mounted) context.go('/');
                  } catch (e) {
                    if (sheetCtx.mounted) {
                      showSnack(
                          sheetCtx,
                          e.toString().contains('INVALID_INVITE_CODE')
                              ? 'Invalid invite code'
                              : 'Failed: $e');
                    }
                  }
                },
                child: const Text('Join Group'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QrScanScreen extends StatelessWidget {
  const _QrScanScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan invite QR')),
      body: MobileScanner(
        onDetect: (capture) {
          final code = capture.barcodes.firstOrNull?.rawValue;
          if (code != null && code.isNotEmpty) {
            Navigator.pop(context, code);
          }
        },
      ),
    );
  }
}
