import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models.dart';
import '../../shared/widgets.dart';
import '../auth/auth_provider.dart';
import '../groups/group_provider.dart';
import '../mood/mood_provider.dart';

String _todayIso() {
  final now = DateTime.now().toUtc();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
}

final _thoughtProvider = FutureProvider<ThoughtOfDay?>((ref) async {
  final gid = ref.watch(activeGroupIdProvider);
  if (gid == null) return null;
  final row = await ref
      .watch(supabaseProvider)
      .from('thought_of_day')
      .select()
      .eq('group_id', gid)
      .eq('date', _todayIso())
      .maybeSingle();
  return row == null ? null : ThoughtOfDay.fromJson(row);
});

final _dareProvider = FutureProvider<Dare?>((ref) async {
  final gid = ref.watch(activeGroupIdProvider);
  if (gid == null) return null;
  final row = await ref
      .watch(supabaseProvider)
      .from('dares')
      .select('*, dare_completions(user_id)')
      .eq('group_id', gid)
      .eq('date', _todayIso())
      .maybeSingle();
  return row == null ? null : Dare.fromJson(row);
});

final _morningMessagesProvider =
    FutureProvider<List<ScheduledMessage>>((ref) async {
  final gid = ref.watch(activeGroupIdProvider);
  if (gid == null) return [];
  final rows = await ref
      .watch(supabaseProvider)
      .from('scheduled_messages')
      .select()
      .eq('group_id', gid)
      .eq('is_active', true)
      .order('send_time');
  return (rows as List)
      .map((r) => ScheduledMessage.fromJson((r as Map).cast<String, dynamic>()))
      .toList();
});

final _dailyQuestionProvider = FutureProvider<DailyQuestion?>((ref) async {
  final gid = ref.watch(activeGroupIdProvider);
  if (gid == null) return null;
  final row = await ref
      .watch(supabaseProvider)
      .from('daily_questions')
      .select('*, daily_question_answers(*)')
      .eq('group_id', gid)
      .eq('date', _todayIso())
      .maybeSingle();
  return row == null ? null : DailyQuestion.fromJson(row);
});

const _fallbackQuestions = [
  'What made you smile today?',
  'If today had a soundtrack, what song would it be?',
  'What tiny thing are you grateful for right now?',
  'What would you do with one free hour today?',
  'Describe your day in exactly three words.',
  'What is something you want to tell your future self?',
  'Who did you think about the most today?',
];

class DailyScreen extends ConsumerStatefulWidget {
  const DailyScreen({super.key});

  @override
  ConsumerState<DailyScreen> createState() => _DailyScreenState();
}

class _DailyScreenState extends ConsumerState<DailyScreen> {
  late final ConfettiController _confetti =
      ConfettiController(duration: const Duration(seconds: 2));

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  Future<void> _completeDare(Dare dare) async {
    final uid = ref.read(currentUserIdProvider)!;
    try {
      await ref.read(supabaseProvider).from('dare_completions').insert({
        'dare_id': dare.id,
        'user_id': uid,
      });
      _confetti.play();
      ref.invalidate(_dareProvider);
      ref.invalidate(myStreakProvider);
    } catch (e) {
      if (mounted) showSnack(context, 'Already done or failed: $e');
    }
  }

  Future<void> _answerQuestion(DailyQuestion? q) async {
    final gid = ref.read(activeGroupIdProvider)!;
    final uid = ref.read(currentUserIdProvider)!;
    final sb = ref.read(supabaseProvider);
    final controller = TextEditingController();

    // Create today's question if nobody has yet (rotating fallback).
    String questionId;
    String questionText;
    if (q == null) {
      final dayIndex =
          DateTime.now().difference(DateTime(2026)).inDays;
      questionText = _fallbackQuestions[dayIndex % _fallbackQuestions.length];
      final row = await sb
          .from('daily_questions')
          .upsert({
            'group_id': gid,
            'question': questionText,
            'date': _todayIso(),
            'created_by': uid,
          }, onConflict: 'group_id,date')
          .select()
          .single();
      questionId = row['id'];
    } else {
      questionId = q.id;
      questionText = q.question;
    }

    if (!mounted) return;
    await showModalBottomSheet(
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
            Text(questionText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            TextField(
                controller: controller,
                maxLines: 3,
                minLines: 1,
                decoration:
                    const InputDecoration(hintText: 'Your answer…')),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  if (controller.text.trim().isEmpty) return;
                  await sb.from('daily_question_answers').upsert({
                    'question_id': questionId,
                    'user_id': uid,
                    'answer': controller.text.trim(),
                  }, onConflict: 'question_id,user_id');
                  if (sheetCtx.mounted) Nav