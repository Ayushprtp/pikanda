import 'package:flutter/material.dart';

// ============================= moods =============================

enum Mood {
  happy('happy', '😊', Color(0xFF4CAF50)),
  sad('sad', '😢', Color(0xFF2196F3)),
  neutral('neutral', '😐', Color(0xFF9E9E9E)),
  angry('angry', '😠', Color(0xFFF44336)),
  anxious('anxious', '😰', Color(0xFFFFC107)),
  excited('excited', '🤩', Color(0xFF9C27B0));

  final String key;
  final String emoji;
  final Color color;
  const Mood(this.key, this.emoji, this.color);

  static Mood fromKey(String key) =>
      Mood.values.firstWhere((m) => m.key == key, orElse: () => Mood.neutral);

  String label(Map<String, String>? customLabels) =>
      customLabels?[key] ?? key[0].toUpperCase() + key.substring(1);
}

// ============================= users =============================

class AppUser {
  final String id;
  final String username;
  final String? displayName;
  final String? avatarUrl;
  final String? phoneNumber;

  AppUser({
    required this.id,
    required this.username,
    this.displayName,
    this.avatarUrl,
    this.phoneNumber,
  });

  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
        id: j['id'],
        username: j['username'] ?? '',
        displayName: j['display_name'],
        avatarUrl: j['avatar_url'],
        phoneNumber: j['phone_number'],
      );

  String get name => displayName ?? username;
}

// ============================= groups =============================

class GroupThemeConfig {
  final Color primary;
  final Color accent;
  final String fontStyle; // rounded | minimal | playful

  const GroupThemeConfig({
    this.primary = const Color(0xFFFF6B6B),
    this.accent = const Color(0xFFFFE66D),
    this.fontStyle = 'rounded',
  });

  factory GroupThemeConfig.fromJson(Map<String, dynamic>? j) {
    if (j == null) return const GroupThemeConfig();
    Color parse(String? hex, Color fallback) {
      if (hex == null) return fallback;
      final h = hex.replaceFirst('#', '');
      final v = int.tryParse(h.length == 6 ? 'FF$h' : h, radix: 16);
      return v == null ? fallback : Color(v);
    }

    return GroupThemeConfig(
      primary: parse(j['primary_color'], const Color(0xFFFF6B6B)),
      accent: parse(j['accent_color'], const Color(0xFFFFE66D)),
      fontStyle: j['font_style'] ?? 'rounded',
    );
  }

  Map<String, dynamic> toJson() => {
        'primary_color':
            '#${primary.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
        'accent_color':
            '#${accent.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
        'font_style': fontStyle,
      };

  String get fontFamily => switch (fontStyle) {
        'minimal' => 'Montserrat',
        'playful' => 'Pandastudio',
        _ => 'SF',
      };
}

class Group {
  final String id;
  final String name;
  final String inviteCode;
  final String? createdBy;
  final GroupThemeConfig theme;
  final int xp;
  final int level;
  final String levelName;
  final String aesSalt;
  final bool moodAlertEnabled;
  final DateTime createdAt;

  Group({
    required this.id,
    required this.name,
    required this.inviteCode,
    this.createdBy,
    required this.theme,
    required this.xp,
    required this.level,
    required this.levelName,
    required this.aesSalt,
    required this.moodAlertEnabled,
    required this.createdAt,
  });

  factory Group.fromJson(Map<String, dynamic> j) => Group(
        id: j['id'],
        name: j['name'],
        inviteCode: j['invite_code'] ?? '',
        createdBy: j['created_by'],
        theme: GroupThemeConfig.fromJson(
            (j['theme_config'] as Map?)?.cast<String, dynamic>()),
        xp: j['xp'] ?? 0,
        level: j['level'] ?? 1,
        levelName: j['level_name'] ?? 'Strangers',
        aesSalt: j['aes_salt'] ?? '',
        moodAlertEnabled: j['mood_alert_enabled'] ?? true,
        createdAt: DateTime.parse(j['created_at']),
      );

  /// XP needed to reach [level]: inverse of level = 1 + floor(sqrt(xp/50)).
  int get xpForNextLevel => 50 * level * level;
  double get levelProgress =>
      ((xp - 50 * (level - 1) * (level - 1)) /
              (xpForNextLevel - 50 * (level - 1) * (level - 1)))
          .clamp(0.0, 1.0);
}

class GroupMember {
  final String id;
  final String groupId;
  final String userId;
  final String roleName;
  final bool isAdmin;
  final DateTime joinedAt;
  final AppUser? user;

  GroupMember({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.roleName,
    required this.isAdmin,
    required this.joinedAt,
    this.user,
  });

  factory GroupMember.fromJson(Map<String, dynamic> j) => GroupMember(
        id: j['id'],
        groupId: j['group_id'],
        userId: j['user_id'],
        roleName: j['role_name'],
        isAdmin: j['is_admin'] ?? false,
        joinedAt: DateTime.parse(j['joined_at']),
        user: j['users'] != null
            ? AppUser.fromJson((j['users'] as Map).cast<String, dynamic>())
            : null,
      );
}

// ============================= mood data =============================

class MoodEntry {
  final String id;
  final String userId;
  final String groupId;
  final Mood mood;
  final DateTime loggedAt;

  MoodEntry({
    required this.id,
    required this.userId,
    required this.groupId,
    required this.mood,
    required this.loggedAt,
  });

  factory MoodEntry.fromJson(Map<String, dynamic> j) => MoodEntry(
        id: j['id'],
        userId: j['user_id'],
        groupId: j['group_id'],
        mood: Mood.fromKey(j['mood']),
        loggedAt: DateTime.parse(j['logged_at']).toLocal(),
      );
}

class Quote {
  final String id;
  final String? groupId;
  final Mood mood;
  final String text;

  Quote({required this.id, this.groupId, required this.mood, required this.text});

  factory Quote.fromJson(Map<String, dynamic> j) => Quote(
        id: j['id'],
        groupId: j['group_id'],
        mood: Mood.fromKey(j['mood']),
        text: j['text'],
      );
}

class Song {
  final String id;
  final String? groupId;
  final Mood mood;
  final String title;
  final String? artist;
  final String url;
  final String platform;

  Song({
    required this.id,
    this.groupId,
    required this.mood,
    required this.title,
    this.artist,
    required this.url,
    required this.platform,
  });

  factory Song.fromJson(Map<String, dynamic> j) => Song(
        id: j['id'],
        groupId: j['group_id'],
        mood: Mood.fromKey(j['mood']),
        title: j['title'],
        artist: j['artist'],
        url: j['url'],
        platform: j['platform'],
      );
}

class StreakInfo {
  final int currentStreak;
  final int longestStreak;
  final int dareStreak;
  final int longestDareStreak;
  final DateTime? lastCheckin;
  final int freezeTokens;

  StreakInfo({
    required this.currentStreak,
    required this.longestStreak,
    required this.dareStreak,
    required this.longestDareStreak,
    this.lastCheckin,
    required this.freezeTokens,
  });

  factory StreakInfo.fromJson(Map<String, dynamic> j) => StreakInfo(
        currentStreak: j['current_streak'] ?? 0,
        longestStreak: j['longest_streak'] ?? 0,
        dareStreak: j['dare_streak'] ?? 0,
        longestDareStreak: j['longest_dare_streak'] ?? 0,
        lastCheckin: j['last_checkin'] != null
            ? DateTime.tryParse(j['last_checkin'])
            : null,
        freezeTokens: j['freeze_tokens'] ?? 0,
      );

  static StreakInfo empty() => StreakInfo(
      currentStreak: 0,
      longestStreak: 0,
      dareStreak: 0,
      longestDareStreak: 0,
      freezeTokens: 1);
}

// ============================= zaps =============================

class Zap {
  final String id;
  final String groupId;
  final String senderId;
  final String? receiverId;
  final String? imageUrl;
  final String? caption;
  final String? emoji;
  final List<dynamic>? doodleData;
  final bool seen;
  final DateTime createdAt;
  final List<ZapReaction> reactions;
  final VoiceNote? voiceNote;

  Zap({
    required this.id,
    required this.groupId,
    required this.senderId,
    this.receiverId,
    this.imageUrl,
    this.caption,
    this.emoji,
    this.doodleData,
    required this.seen,
    required this.createdAt,
    this.reactions = const [],
    this.voiceNote,
  });

  factory Zap.fromJson(Map<String, dynamic> j) => Zap(
        id: j['id'],
        groupId: j['group_id'],
        senderId: j['sender_id'],
        receiverId: j['receiver_id'],
        imageUrl: j['image_url'],
        caption: j['caption'],
        emoji: j['emoji'],
        doodleData: (j['doodle_data'] as Map?)?['strokes'] as List<dynamic>?,
        seen: j['seen'] ?? false,
        createdAt: DateTime.parse(j['created_at']).toLocal(),
        reactions: (j['zap_reactions'] as List? ?? [])
            .map((r) => ZapReaction.fromJson((r as Map).cast<String, dynamic>()))
            .toList(),
        voiceNote: (j['voice_notes'] as List? ?? []).isNotEmpty
            ? VoiceNote.fromJson(
                ((j['voice_notes'] as List).first as Map).cast<String, dynamic>())
            : null,
      );
}

class VoiceNote {
  final String id;
  final String zapId;
  final String storageUrl;
  final int durationSeconds;

  VoiceNote({
    required this.id,
    required this.zapId,
    required this.storageUrl,
    required this.durationSeconds,
  });

  factory VoiceNote.fromJson(Map<String, dynamic> j) => VoiceNote(
        id: j['id'],
        zapId: j['zap_id'],
        storageUrl: j['storage_url'],
        durationSeconds: j['duration_seconds'] ?? 0,
      );
}

class ZapReaction {
  final String zapId;
  final String userId;
  final String emoji;

  ZapReaction({required this.zapId, required this.userId, required this.emoji});

  factory ZapReaction.fromJson(Map<String, dynamic> j) => ZapReaction(
        zapId: j['zap_id'],
        userId: j['user_id'],
        emoji: j['emoji'],
      );
}

// ============================= daily =============================

class ThoughtOfDay {
  final String id;
  final String thought;
  final DateTime date;

  ThoughtOfDay({required this.id, required this.thought, required this.date});

  factory ThoughtOfDay.fromJson(Map<String, dynamic> j) => ThoughtOfDay(
      id: j['id'], thought: j['thought'], date: DateTime.parse(j['date']));
}

class Dare {
  final String id;
  final String groupId;
  final String dareText;
  final DateTime date;
  final List<String> completedBy;

  Dare({
    required this.id,
    required this.groupId,
    required this.dareText,
    required this.date,
    this.completedBy = const [],
  });

  factory Dare.fromJson(Map<String, dynamic> j) => Dare(
        id: j['id'],
        groupId: j['group_id'],
        dareText: j['dare_text'],
        date: DateTime.parse(j['date']),
        completedBy: (j['dare_completions'] as List? ?? [])
            .map((c) => (c as Map)['user_id'] as String)
            .toList(),
      );
}

class ScheduledMessage {
  final String id;
  final String groupId;
  final String message;
  final String sendTime; // HH:mm:ss
  final String recurrence;
  final bool isActive;

  ScheduledMessage({
    required this.id,
    required this.groupId,
    required this.message,
    required this.sendTime,
    required this.recurrence,
    required this.isActive,
  });

  factory ScheduledMessage.fromJson(Map<String, dynamic> j) => ScheduledMessage(
        id: j['id'],
        groupId: j['group_id'],
        message: j['message'],
        sendTime: j['send_time'],
        recurrence: j['recurrence'],
        isActive: j['is_active'] ?? true,
      );
}

// ============================= vibe =============================

class VibeCheck {
  final String id;
  final String groupId;
  final DateTime expiresAt;
  final bool isRevealed;
  final DateTime createdAt;
  final List<VibeCheckResponse> responses;

  VibeCheck({
    required this.id,
    required this.groupId,
    required this.expiresAt,
    required this.isRevealed,
    required this.createdAt,
    this.responses = const [],
  });

  factory VibeCheck.fromJson(Map<String, dynamic> j) => VibeCheck(
        id: j['id'],
        groupId: j['group_id'],
        expiresAt: DateTime.parse(j['expires_at']).toLocal(),
        isRevealed: j['is_revealed'] ?? false,
        createdAt: DateTime.parse(j['created_at']).toLocal(),
        responses: (j['vibe_check_responses'] as List? ?? [])
            .map((r) =>
                VibeCheckResponse.fromJson((r as Map).cast<String, dynamic>()))
            .toList(),
      );
}

class VibeCheckResponse {
  final String userId;
  final Mood mood;

  VibeCheckResponse({required this.userId, required this.mood});

  factory VibeCheckResponse.fromJson(Map<String, dynamic> j) =>
      VibeCheckResponse(userId: j['user_id'], mood: Mood.fromKey(j['mood']));
}

class VibeSyncSession {
  final String id;
  final String groupId;
  final String songUrl;
  final String? songTitle;
  final DateTime startsAt;

  VibeSyncSession({
    required this.id,
    required this.groupId,
    required this.songUrl,
    this.songTitle,
    required this.startsAt,
  });

  factory VibeSyncSession.fromJson(Map<String, dynamic> j) => VibeSyncSession(
        id: j['id'],
        groupId: j['group_id'],
        songUrl: j['song_url'],
        songTitle: j['song_title'],
        startsAt: DateTime.parse(j['starts_at']).toLocal(),
      );
}

// ============================= capsules / badges =============================

class MemoryCapsule {
  final String id;
  final String groupId;
  final String? createdBy;
  final String? title;
  final String? content;
  final String? imageUrl;
  final DateTime unlockAt;
  final bool isUnlocked;
  final DateTime createdAt;

  MemoryCapsule({
    required this.id,
    required this.groupId,
    this.createdBy,
    this.title,
    this.content,
    this.imageUrl,
    required this.unlockAt,
    required this.isUnlocked,
    required this.createdAt,
  });

  factory MemoryCapsule.fromJson(Map<String, dynamic> j) => MemoryCapsule(
        id: j['id'],
        groupId: j['group_id'],
        createdBy: j['created_by'],
        title: j['title'],
        content: j['content'],
        imageUrl: j['image_url'],
        unlockAt: DateTime.parse(j['unlock_at']).toLocal(),
        isUnlocked: j['is_unlocked'] ?? false,
        createdAt: DateTime.parse(j['created_at']).toLocal(),
      );
}

class UserBadge {
  final String userId;
  final String badgeKey;
  final DateTime earnedAt;

  UserBadge({required this.userId, required this.badgeKey, required this.earnedAt});

  factory UserBadge.fromJson(Map<String, dynamic> j) => UserBadge(
        userId: j['user_id'],
        badgeKey: j['badge_key'],
        earnedAt: DateTime.parse(j['earned_at']).toLocal(),
      );
}

/// All badge definitions, keyed by badge_key.
class BadgeDef {
  final String key;
  final String emoji;
  final String title;
  final String description;
  const BadgeDef(this.key, this.emoji, this.title, this.description);

  static const all = [
    BadgeDef('seven_day_streak', '🔥', '7 Day Streak', '7 consecutive check-in days'),
    BadgeDef('first_spark', '⚡', 'First Spark', 'Sent your first Zap'),
    BadgeDef('memory_keeper', '📦', 'Memory Keeper', 'Created your first capsule'),
    BadgeDef('always_sunny', '😊', 'Always Sunny', '30 days of happy moods'),
    BadgeDef('whisperer', '🤍', 'Whisperer', 'Sent your first whisper'),
    BadgeDef('dare_devil', '💪', 'Dare Devil', 'Completed 7 dares'),
    BadgeDef('voice_of_group', '🎙️', 'Voice of the Group', 'Sent 10 voice zaps'),
    BadgeDef('founding_member', '👑', 'Founding Member', 'In the group from day 1'),
    BadgeDef('first_win', '🏆', 'Champion', 'Won your first minigame'),
    BadgeDef('pet_parent', '🐾', 'Pet Parent', 'Helped your pet evolve'),
  ];

  static BadgeDef byKey(String key) => all.firstWhere((b) => b.key == key,
      orElse: () => BadgeDef(key, '🏅', key, 'Special badge'));
}

class MonthlyHighlight {
  final String id;
  final DateTime month;
  final String? topZapId;
  final DateTime? mostActiveDay;
  final Map<String, dynamic>? summary;

  MonthlyHighlight({
    required this.id,
    required this.month,
    this.topZapId,
    this.mostActiveDay,
    this.summary,
  });

  factory MonthlyHighlight.fromJson(Map<String, dynamic> j) => MonthlyHighlight(
        id: j['id'],
        month: DateTime.parse(j['month']),
        topZapId: j['top_zap_id'],
        mostActiveDay: j['most_active_day'] != null
            ? DateTime.tryParse(j['most_active_day'])
            : null,
        summary: (j['summary'] as Map?)?.cast<String, dynamic>(),
      );
}

// ============================= pets =============================

enum PetSpecies {
  panda('panda', '🐼', 'Panda'),
  pika('pika', '⚡', 'Pika'),
  bunny('bunny', '🐰', 'Bunny'),
  cat('cat', '🐱', 'Cat'),
  penguin('penguin', '🐧', 'Penguin'),
  dragon('dragon', '🐉', 'Dragon');

  final String key;
  final String emoji;
  final String label;
  const PetSpecies(this.key, this.emoji, this.label);

  static PetSpecies fromKey(String k) =>
      PetSpecies.values.firstWhere((s) => s.key == k, orElse: () => PetSpecies.panda);
}

class Pet {
  final String id;
  final String groupId;
  final String name;
  final PetSpecies species;
  final String stage; // egg | baby | teen | adult
  final int hunger;
  final int happiness;
  final int energy;
  final int cleanliness;
  final int xp;
  final int level;

  Pet({
    required this.id,
    required this.groupId,
    required this.name,
    required this.species,
    required this.stage,
    required this.hunger,
    required this.happiness,
    required this.energy,
    required this.cleanliness,
    required this.xp,
    required this.level,
  });

  factory Pet.fromJson(Map<String, dynamic> j) => Pet(
        id: j['id'],
        groupId: j['group_id'],
        name: j['name'],
        species: PetSpecies.fromKey(j['species']),
        stage: j['stage'],
        hunger: j['hunger'] ?? 0,
        happiness: j['happiness'] ?? 0,
        energy: j['energy'] ?? 0,
        cleanliness: j['cleanliness'] ?? 0,
        xp: j['xp'] ?? 0,
        level: j['level'] ?? 0,
      );

  String get displayEmoji => stage == 'egg' ? '🥚' : species.emoji;

  double get stageScale => switch (stage) {
        'egg' => 0.7,
        'baby' => 0.8,
        'teen' => 1.0,
        _ => 1.25,
      };

  String get moodText {
    if (stage == 'egg') return 'Waiting to hatch… keep caring! 🥚';
    if (hunger < 25) return '$name is starving! 🍽️';
    if (happiness < 25) return '$name feels lonely… 🥺';
    if (cleanliness < 25) return '$name needs a bath! 🛁';
    if (energy < 25) return '$name is sleepy… 😴';
    if (hunger > 70 && happiness > 70) return '$name is thriving! ✨';
    return '$name is doing okay 🙂';
  }

  /// XP for next level: level = floor(sqrt(xp/20)) → next at 20*(level+1)^2.
  int get xpForNextLevel => 20 * (level + 1) * (level + 1);
  double get levelProgress {
    final base = 20 * level * level;
    return ((xp - base) / (xpForNextLevel - base)).clamp(0.0, 1.0);
  }
}

// ============================= games =============================

enum GameType {
  tictactoe('tictactoe', '⭕', 'Tic-Tac-Toe', 2),
  rps('rps', '✂️', 'Rock Paper Scissors', 2),
  memoryMatch('memory_match', '🃏', 'Memory Match', 2),
  tapRace('tap_race', '👆', 'Tap Race', 8),
  wordGuess('word_guess', '🔤', 'Word Guess', 8),
  connect4('connect4', '🔴', 'Connect Four', 2),
  reactionDuel('reaction_duel', '⚡', 'Reaction Duel', 2),
  battleship('battleship', '🚢', 'Battleship', 2);

  final String key;
  final String emoji;
  final String label;
  final int defaultMaxPlayers;
  const GameType(this.key, this.emoji, this.label, this.defaultMaxPlayers);

  static GameType fromKey(String k) =>
      GameType.values.firstWhere((g) => g.key == k, orElse: () => GameType.tictactoe);
}

class GameSession {
  final String id;
  final String groupId;
  final GameType gameType;
  final String status; // lobby | active | finished | cancelled
  final String? createdBy;
  final Map<String, dynamic> state;
  final String? currentTurn;
  final String? winnerId;
  final int maxPlayers;
  final DateTime createdAt;

  GameSession({
    required this.id,
    required this.groupId,
    required this.gameType,
    required this.status,
    this.createdBy,
    required this.state,
    this.currentTurn,
    this.winnerId,
    required this.maxPlayers,
    required this.createdAt,
  });

  factory GameSession.fromJson(Map<String, dynamic> j) => GameSession(
        id: j['id'],
        groupId: j['group_id'],
        gameType: GameType.fromKey(j['game_type']),
        status: j['status'],
        createdBy: j['created_by'],
        state: (j['state'] as Map? ?? {}).cast<String, dynamic>(),
        currentTurn: j['current_turn'],
        winnerId: j['winner_id'],
        maxPlayers: j['max_players'] ?? 2,
        createdAt: DateTime.parse(j['created_at']).toLocal(),
      );
}

class GamePlayer {
  final String sessionId;
  final String userId;
  final int playerIndex;
  final int score;

  GamePlayer({
    required this.sessionId,
    required this.userId,
    required this.playerIndex,
    required this.score,
  });

  factory GamePlayer.fromJson(Map<String, dynamic> j) => GamePlayer(
        sessionId: j['session_id'],
        userId: j['user_id'],
        playerIndex: j['player_index'] ?? 0,
        score: j['score'] ?? 0,
      );
}

class GameMove {
  final int id;
  final String sessionId;
  final String userId;
  final Map<String, dynamic> move;
  final DateTime createdAt;

  GameMove({
    required this.id,
    required this.sessionId,
    required this.userId,
    required this.move,
    required this.createdAt,
  });

  factory GameMove.fromJson(Map<String, dynamic> j) => GameMove(
        id: j['id'],
        sessionId: j['session_id'],
        userId: j['user_id'],
        move: (j['move'] as Map).cast<String, dynamic>(),
        createdAt: DateTime.parse(j['created_at']).toLocal(),
      );
}

// ============================= extras =============================

class DailyQuestion {
  final String id;
  final String groupId;
  final String question;
  final DateTime date;
  final List<DailyQuestionAnswer> answers;

  DailyQuestion({
    required this.id,
    required this.groupId,
    required this.question,
    required this.date,
    this.answers = const [],
  });

  factory DailyQuestion.fromJson(Map<String, dynamic> j) => DailyQuestion(
        id: j['id'],
        groupId: j['group_id'],
        question: j['question'],
        date: DateTime.parse(j['date']),
        answers: (j['daily_question_answers'] as List? ?? [])
            .map((a) =>
                DailyQuestionAnswer.fromJson((a as Map).cast<String, dynamic>()))
            .toList(),
      );
}

class DailyQuestionAnswer {
  final String userId;
  final String answer;

  DailyQuestionAnswer({required this.userId, required this.answer});

  factory DailyQuestionAnswer.fromJson(Map<String, dynamic> j) =>
      DailyQuestionAnswer(userId: j['user_id'], answer: j['answer']);
}

class BucketItem {
  final String id;
  final String title;
  final String? emoji;
  final bool isDone;

  BucketItem({required this.id, required this.title, this.emoji, required this.isDone});

  factory BucketItem.fromJson(Map<String, dynamic> j) => BucketItem(
        id: j['id'],
        title: j['title'],
        emoji: j['emoji'],
        isDone: j['is_done'] ?? false,
      );
}

class CountdownEvent {
  final String id;
  final String title;
  final String? emoji;
  final DateTime eventDate;
  final bool repeatsYearly;

  CountdownEvent({
    required this.id,
    required this.title,
    this.emoji,
    required this.eventDate,
    required this.repeatsYearly,
  });

  factory CountdownEvent.fromJson(Map<String, dynamic> j) => CountdownEvent(
        id: j['id'],
        title: j['title'],
        emoji: j['emoji'],
        eventDate: DateTime.parse(j['event_date']),
        repeatsYearly: j['repeats_yearly'] ?? true,
      );

  DateTime get nextOccurrence {
    final now = DateTime.now();
    if (!repeatsYearly) return eventDate;
    var next = DateTime(now.year, eventDate.month, eventDate.day);
    if (next.isBefore(DateTime(now.year, now.month, now.day))) {
      next = DateTime(now.year + 1, eventDate.month, eventDate.day);
    }
    return next;
  }

  int get daysLeft =>
      nextOccurrence.difference(DateTime.now()).inHours ~/ 24;
}

// ============================= safezap =============================

class LocationEvent {
  final String id;
  final String groupId;
  final String senderId;
  final String triggerType; // auto_24hr | secret_code | safe_word
  final String encryptedCoords;
  final bool isLiveGps;
  final DateTime createdAt;

  LocationEvent({
    required this.id,
    required this.groupId,
    required this.senderId,
    required this.triggerType,
    required this.encryptedCoords,
    required this.isLiveGps,
    required this.createdAt,
  });

  factory LocationEvent.fromJson(Map<String, dynamic> j) => LocationEvent(
        id: j['id'],
        groupId: j['group_id'],
        senderId: j['sender_id'],
        triggerType: j['trigger_type'],
        encryptedCoords: j['encrypted_coords'],
        isLiveGps: j['is_live_gps'] ?? true,
        createdAt: DateTime.parse(j['created_at']).toLocal(),
      );
}

class UserLocation {
  final String userId;
  final double lat;
  final double lng;
  final DateTime updatedAt;
  final bool isSharing;
  final int? battery;
  final double? speed;

  UserLocation({
    required this.userId,
    required this.lat,
    required this.lng,
    required this.updatedAt,
    this.isSharing = false,
    this.battery,
    this.speed,
  });

  factory UserLocation.fromJson(Map<String, dynamic> j) => UserLocation(
        userId: j['user_id'],
        lat: (j['lat'] as num).toDouble(),
        lng: (j['lng'] as num).toDouble(),
        updatedAt: DateTime.parse(j['updated_at']).toLocal(),
        isSharing: j['is_sharing'] ?? false,
        battery: j['battery'],
        speed: (j['speed'] as num?)?.toDouble(),
      );

  /// A member is "live" if their location was updated in the last 2 minutes.
  bool get isLive =>
      DateTime.now().difference(updatedAt).inSeconds < 120;

  String get freshness {
    final d = DateTime.now().difference(updatedAt);
    if (d.inSeconds < 20) return 'live now';
    if (d.inMinutes < 1) return '${d.inSeconds}s ago';
    if (d.inHours < 1) return '${d.inMinutes}m ago';
    if (d.inDays < 1) return '${d.inHours}h ago';
    return '${d.inDays}d ago';
  }
}
