import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../shared/models.dart';
import '../auth/auth_provider.dart';
import '../groups/group_provider.dart';

/// Today's hidden quote: deterministic per day so the whole group scratches
/// the same message.
final dailyScratchQuoteProvider = FutureProvider<Quote?>((ref) async {
  final gid = ref.watch(activeGroupIdProvider);
  if (gid == null) return null;
  final rows = await ref
      .watch(supabaseProvider)
      .from('quotes')
      .select()
      .or('group_id.eq.$gid,group_id.is.null')
      .order('created_at');
  final quotes = (rows as List)
      .map((r) => Quote.fromJson((r as Map).cast<String, dynamic>()))
      .toList();
  if (quotes.isEmpty) return null;
  final now = DateTime.now();
  final dayN = now.difference(DateTime(now.year)).inDays;
  return quotes[(dayN + now.year) % quotes.length];
});

/// Rub-to-reveal daily surprise card for the dashboard.
class DailyScratchCard extends ConsumerStatefulWidget {
  const DailyScratchCard({super.key});

  @override
  ConsumerState<DailyScratchCard> createState() => _DailyScratchCardState();
}

class _DailyScratchCardState extends ConsumerState<DailyScratchCard> {
  final List<Offset> _scratched = [];
  bool _revealed = false;
  bool _loadedState = false;

  String get _todayKey {
    final n = DateTime.now();
    return 'scratch_${n.year}-${n.month}-${n.day}';
  }

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      if (mounted) {
        setState(() {
          _revealed = prefs.getBool(_todayKey) ?? false;
          _loadedState = true;
        });
      }
    });
  }

  Future<void> _markRevealed() async {
    if (_revealed) return;
    setState(() => _revealed = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_todayKey, true);
  }

  @override
  Widget build(BuildContext context) {
    final quote = ref.watch(dailyScratchQuoteProvider).valueOrNull;
    if (quote == null || !_loadedState) return const SizedBox.shrink();

    final content = Container(
      height: 110,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          quote.mood.color.withValues(alpha: 0.35),
          Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
        ]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${quote.mood.emoji} today\'s scratch surprise',
                style: TextStyle(
                    fontSize: 11, color: Colors.white.withValues(alpha: 0.7))),
            const SizedBox(height: 6),
            Flexible(
              child: Text(
                quote.text,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600, height: 1.3),
              ),
            ),
          ],
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: _revealed
          ? content
          : ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: GestureDetector(
                onPanUpdate: (d) {
                  setState(() => _scratched.add(d.localPosition));
                  // ~40 strokes ≈ enough rubbing → reveal fully
                  if (_scratched.length > 40) _markRevealed();
                },
                child: Stack(
                  children: [
                    content,
                    Positioned.fill(
                      child: ClipRect(
                        child: CustomPaint(
                          painter: _ScratchPainter(points: _scratched),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

/// Grey foil layer with transparent holes where the finger rubbed.
class _ScratchPainter extends CustomPainter {
  final List<Offset> points;
  _ScratchPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.saveLayer(rect, Paint());
    canvas.drawRect(rect, Paint()..color = const Color(0xFF3A3A46));

    final tp = TextPainter(
      text: const TextSpan(
          text: '🎫  scratch me!',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
        canvas,
        Offset((size.width - tp.width) / 2, (size.height - tp.height) / 2));

    final hole = Paint()..blendMode = BlendMode.clear;
    for (final p in points) {
      canvas.drawCircle(p, 22, hole);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ScratchPainter old) =>
      old.points.length != points.length;
}
