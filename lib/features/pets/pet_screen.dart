import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models.dart';
import '../../shared/widgets.dart';
import 'pet_provider.dart';

/// Full-screen route wrapper.
class PetScreen extends StatelessWidget {
  const PetScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Group Pet 🐾')),
        body: const PetBody(),
      );
}

/// The Pet tab body (also embedded in the home shell).
class PetBody extends ConsumerWidget {
  const PetBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(petRealtimeProvider);
    final pet = ref.watch(petProvider);

    return pet.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => EmptyState(emoji: '😵', message: 'Error: $e'),
      data: (p) => p == null ? const _AdoptView() : _PetView(pet: p),
    );
  }
}

class _AdoptView extends ConsumerStatefulWidget {
  const _AdoptView();

  @override
  ConsumerState<_AdoptView> createState() => _AdoptViewState();
}

class _AdoptViewState extends ConsumerState<_AdoptView> {
  final _name = TextEditingController();
  PetSpecies _species = PetSpecies.panda;
  bool _busy = false;

  Future<void> _adopt() async {
    if (_name.text.trim().isEmpty) {
      showSnack(context, 'Give your pet a name!');
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(petControllerProvider).adopt(_name.text.trim(), _species);
    } catch (e) {
      if (mounted) {
        showSnack(context, 'Failed: $e');
        setState(() => _busy = false);
      }
    }
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 12),
        const Center(child: Text('🥚', style: TextStyle(fontSize: 80))),
        const SizedBox(height: 12),
        const Center(
          child: Text('Adopt a group pet',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text(
              'Everyone in the group cares for it together.\n'
              'Feed, play, clean and let it sleep — watch it hatch and grow!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (final s in PetSpecies.values)
              GestureDetector(
                onTap: () => setState(() => _species = s),
                child: Container(
                  margin: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _species == s
                        ? Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.25)
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                        color: _species == s
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                        width: 2),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(s.emoji, style: const TextStyle(fontSize: 40)),
                      Text(s.label, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _name,
          decoration: const InputDecoration(labelText: 'Name your pet'),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: _busy ? null : _adopt,
          icon: const Icon(Icons.egg_alt),
          label: Text(_busy ? 'Adopting…' : 'Adopt ${_species.label}'),
        ),
      ],
    );
  }
}

class _PetView extends ConsumerStatefulWidget {
  final Pet pet;
  const _PetView({required this.pet});

  @override
  ConsumerState<_PetView> createState() => _PetViewState();
}

class _PetViewState extends ConsumerState<_PetView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounce = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1600))
    ..repeat(reverse: true);
  bool _acting = false;

  @override
  void dispose() {
    _bounce.dispose();
    super.dispose();
  }

  Future<void> _care(String action, String verb) async {
    setState(() => _acting = true);
    final err = await ref.read(petControllerProvider).care(widget.pet.id, action);
    if (!mounted) return;
    setState(() => _acting = false);
    if (err == 'COOLDOWN') {
      showSnack(context, 'You just did that — give it a few minutes 🕒');
    } else if (err != null) {
      showSnack(context, 'Failed: $err');
    } else {
      showSnack(context, '$verb ${widget.pet.name} 💕');
    }
  }

  @override
  Widget build(BuildContext context) {
    final pet = widget.pet;
    final careLog = ref.watch(petCareLogProvider(pet.id));

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: [
        // ---- pet stage ----
        SectionCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              AnimatedBuilder(
                animation: _bounce,
                builder: (_, child) => Transform.translate(
                  offset: Offset(0, sin(_bounce.value * pi) * -10),
                  child: Transform.scale(
                      scale: pet.stageScale, child: child),
                ),
                child: Text(pet.displayEmoji,
                    style: const TextStyle(fontSize: 96)),
              ),
              const SizedBox(height: 8),
              Text(pet.name,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w800)),
              Text('${pet.species.label} · ${pet.stage} · Lv ${pet.level}',
                  style:
                      TextStyle(color: Colors.white.withValues(alpha: 0.55))),
              const SizedBox(height: 6),
              Text(pet.moodText,
                  style: const TextStyle(fontStyle: FontStyle.italic)),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: pet.levelProgress,
                  minHeight: 8,
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              Text('${pet.xp} XP → next stage',
                  style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.4))),
            ],
          ),
        ),
        // ---- stats ----
        SectionCard(
          child: Column(
            children: [
              StatBar(
                  label: 'Hunger',
                  emoji: '🍖',
                  value: pet.hunger,
                  color: Colors.orange),
              StatBar(
                  label: 'Happiness',
                  emoji: '😊',
                  value: pet.happiness,
                  color: Colors.pinkAccent),
              StatBar(
                  label: 'Energy',
                  emoji: '⚡',
                  value: pet.energy,
                  color: Colors.yellow),
              StatBar(
                  label: 'Cleanliness',
                  emoji: '🛁',
                  value: pet.cleanliness,
                  color: Colors.lightBlueAccent),
            ],
          ),
        ),
        // ---- care actions ----
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 0.95,
            children: [
              _CareButton('🍖', 'Feed', _acting ? null : () => _care('feed', 'Fed')),
              _CareButton('🎾', 'Play', _acting ? null : () => _care('play', 'Played with')),
              _CareButton('🛁', 'Clean', _acting ? null : () => _care('clean', 'Cleaned')),
              _CareButton('😴', 'Sleep', _acting ? null : () => _care('sleep', 'Tucked in')),
            ],
          ),
        ),
        // ---- care log ----
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Recent care',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              careLog.when(
                loading: () => const Padding(
                    padding: EdgeInsets.all(8),
                    child: LinearProgressIndicator()),
                error: (_, __) => const Text('—'),
                data: (log) => log.isEmpty
                    ? Text('No care yet — be the first!',
                        style:
                            TextStyle(color: Colors.white.withValues(alpha: 0.5)))
                    : Column(
                        children: [
                          for (final a in log.take(8))
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                children: [
                                  Text(_actionEmoji(a['action'])),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${a['users']?['display_name'] ?? a['users']?['username'] ?? 'Someone'} ${_actionVerb(a['action'])}',
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  String _actionEmoji(String a) => switch (a) {
        'feed' => '🍖',
        'play' => '🎾',
        'clean' => '🛁',
        _ => '😴',
      };
  String _actionVerb(String a) => switch (a) {
        'feed' => 'fed the pet',
        'play' => 'played',
        'clean' => 'cleaned up',
        _ => 'tucked it in',
      };
}

class _CareButton extends StatelessWidget {
  final String emoji;
  final String label;
  final VoidCallback? onTap;
  const _CareButton(this.emoji, this.label, this.onTap);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 30)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
