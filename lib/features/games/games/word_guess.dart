import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models.dart';
import '../../auth/auth_provider.dart';
import '../game_provider.dart';
import 'game_common.dart';

/// Collaborative word guess (Wordle-style, whole group races to solve).
/// state = { "answer": "PANDA", "guesses":[{uid,word}], "solvedBy": uid }
class WordGuessBoard extends ConsumerStatefulWidget {
  final GameSession session;
  final List<GamePlayer> players;
  final List<GroupMember> members;

  const WordGuessBoard({
    super.key,
    required this.session,
    required this.players,
    required this.members,
  });

  @override
  ConsumerState<WordGuessBoard> createState() => _WordGuessBoardState();
}

class _WordGuessBoardState extends ConsumerState<WordGuessBoard>
    with GameBoardHelpers {
  @override
  List<GroupMember> get members => widget.members;

  static const _words = [
    'PANDA','PIKAA','HEART','SMILE','MUSIC','DREAM','HAPPY','LUCKY',
    'SUGAR','HONEY','CANDY','BLISS','CHARM','SWEET','GLOWS','SPARK',
  ];

  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Host seeds the answer.
    if (widget.session.state['answer'] == null &&
        widget.session.createdBy == ref.read(currentUserIdProvider)) {
      final answer = _words[Random(widget.session.id.hashCode) .nextInt(_words.length)];
      ref.read(gameControllerProvider).submitMove(
        widget.session.id,
        {'seed': true},
        newState: {'answer': answer, 'guesses': []},
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Wordle scoring: 2 = right spot, 1 = wrong spot, 0 = absent.
  List<int> _score(String guess, String answer) {
    final res = List.filled(5, 0);
    final ans = answer.split('');
    final used = List.filled(5, false);
    for (var i = 0; i < 5; i++) {
      if (guess[i] == ans[i]) {
        res[i] = 2;
        used[i] = true;
      }
    }
    for (var i = 0; i < 5; i++) {
      if (res[i] == 2) continue;
      for (var j = 0; j < 5; j++) {
        if (!used[j] && guess[i] == ans[j]) {
          res[i] = 1;
          used[j] = true;
          break;
        }
      }
    }
    return res;
  }

  @override
  Widget build(BuildContext context) {
    final myId = ref.watch(currentUserIdProvider)!;
    final answer = (widget.session.state['answer'] ?? '') as String;
    final guesses = ((widget.session.state['guesses'] as List?) ?? [])
        .map((g) => (g as Map).cast<String, dynamic>())
        .toList();

    if (answer.isEmpty) {
      return const Center(child: Text('Setting up the word… ⏳'));
    }

    Future<void> submit() async {
      final word = _controller.text.trim().toUpperCase();
      if (word.length != 5) return;
      _controller.clear();
      final newGuesses = [
        ...guesses,
        {'uid': myId, 'word': word}
      ];
      final solved = word == answer;
      await ref.read(gameControllerProvider).submitMove(
            widget.session.id,
            {'guess': word},
            newState: {
              'answer': answer,
              'guesses': newGuesses,
              if (solved) 'solvedBy': myId,
            },
            finish: solved,
            winner: solved ? myId : null,
            scores: solved ? {myId: 1} : null,
          );
    }

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(12),
          child: Text('Guess the 5-letter word — whole group races!',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w700)),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              for (final g in guesses.reversed)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(roleOf(g['uid']),
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.5))),
                      Row(
                        children: [
                          for (var i = 0; i < (g['word'] as String).length; i++)
                            _LetterTile(
                                letter: (g['word'] as String)[i],
                                score: _score(g['word'], answer)[i]),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 5,
                  decoration: const InputDecoration(
                      hintText: '5 letters', counterText: ''),
                  onSubmitted: (_) => submit(),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(onPressed: submit, child: const Text('Guess')),
            ],
          ),
        ),
      ],
    );
  }
}

class _LetterTile extends StatelessWidget {
  final String letter;
  final int score;
  const _LetterTile({required this.letter, required this.score});

  @override
  Widget build(BuildContext context) {
    final color = switch (score) {
      2 => Colors.green,
      1 => Colors.amber,
      _ => Colors.white.withValues(alpha: 0.12),
    };
    return Container(
      width: 40,
      height: 40,
      margin: const EdgeInsets.all(2),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
      child: Center(
        child: Text(letter,
            style:
                const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
      ),
    );
  }
}
