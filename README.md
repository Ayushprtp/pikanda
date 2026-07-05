# Pikanda 🐼⚡

A private social + safety app for close friend groups, built with **Flutter** and
**Supabase**. Every group is its own little world: log moods, zap photos, keep
streaks, raise a shared pet, play multiplayer games, and stay safe with
location sharing — all in a space that's just yours.

> _"Don't Forget Me Bae… I Will Miss Uhh… <3"_ — where it all started.

---

## ✨ Features

### Core
- **Groups** — anyone can create a group and become its admin. Join with a
  6-char invite code (or scan a QR). Each member picks their own display name
  ("role") per group — Panda, Pikachu, Manisha, whatever fits.
- **Per-group theme** — admins set the colour palette + font; the whole app
  re-themes live.
- **Moods** — 6 moods, each check-in returns a random quote + song for that mood.
  Custom mood labels per group ("Happy" → "Pikachu Energy ⚡").
- **Mood calendar** — GitHub-contribution-style grid, tap any day to revisit.
- **Profile aura** — an animated ring around your avatar, colour computed from
  your last 30 days of moods.
- **Streaks** — Duolingo-style flame with auto-applied freeze tokens (1/week).

### Social
- **Zaps** — photo + finger doodle + caption + emoji + 10-second voice note
  (with waveform). Realtime inbox, 8-emoji reactions, and a home-screen widget.
- **Poke** — one tap, instant push notification.
- **Whisper** — one-way anonymous messages; the sender id is AES-encrypted
  client-side, so not even the database knows who sent it.
- **Daily** — admin-scheduled morning/night messages, thought of the day, and a
  dare of the day (confetti when you complete it, with its own dare streak).
- **Vibe Check** — everyone drops their current mood; results reveal to all at
  once (pie chart). **Vibe Sync** starts the same song on everyone's phone.

### Fun & keepsakes
- **Group Pet 🐼** — adopt a panda / pika / bunny / cat / penguin / dragon.
  Everyone feeds, plays, cleans and puts it to sleep together; stats decay over
  time, and it grows egg → baby → teen → adult.
- **Multiplayer minigames** (realtime, over Supabase) — Tic-Tac-Toe, Rock Paper
  Scissors (best of 5), Memory Match, Tap Race (everyone at once), and a
  Wordle-style Word Guess. Lobby/join flow, live moves, and a group leaderboard.
- **Memory capsules** — bury a photo + note; it stays sealed for N days, then
  unlocks for the whole group.
- **Badges**, **group XP & levels** (Strangers → Soulmates), **stats** +
  "this day last year" + monthly highlights.
- **Bucket list** & **countdowns** (birthdays / anniversaries).

### Safety — SafeZap (Android)
Personal-safety location sharing within your own group, three triggers:
1. **24h watchdog** — if you don't open the app for 24h, it shares your location.
2. **Secret code** — texting the group's secret word to your phone shares it.
3. **Safe word** — triple-tap the 🐼⚡ logo anywhere to silently share it.

Coordinates are **AES-256 encrypted** with a per-group key before ever leaving
the device (SMS payload `PKD:v1:<enc>:<flag>`), and a decrypted view is shown on
an OpenStreetMap map. iOS gets everything except the SMS triggers.

---

## 🏗️ Architecture

```
lib/
├── main.dart                      # bootstrap: Supabase, notifications, workmanager
├── core/
│   ├── config.dart                # Supabase URL/key (override via --dart-define)
│   ├── router.dart                # GoRouter + auth/group redirect
│   ├── theme.dart                 # per-group ThemeData
│   ├── services/                  # notifications, location, home-widget
│   └── utils/                     # AES helper, haversine
├── shared/
│   ├── models.dart                # all data models + enums
│   └── widgets.dart               # SectionCard, AuraRing, PikandaLogo, …
└── features/                      # one folder per feature (Riverpod providers + screens)
    ├── auth/ groups/ mood/ streaks/ zap/ whisper/ daily/ vibe/
    ├── capsule/ stats/ pets/ games/ safezap/ widget/ admin/ extras/
```

- **State:** Riverpod. **Navigation:** GoRouter. **Backend:** Supabase
  (Postgres + RLS + Realtime + Storage + Edge Functions).
- Every table has **Row Level Security** — you can only ever read/write your own
  group's data. Writes that need invariants (mood streaks, game moves, pet care,
  group creation) go through `security definer` Postgres functions.

### Backend (`supabase/`)
- `migrations/` — 11 SQL migrations: schema, RLS, triggers (XP, badges,
  notifications), and `pg_cron` jobs (scheduled messages, capsule unlock, streak
  freeze, mood-pattern alerts, badges, monthly highlights, pet decay, vibe
  reveal, notification queue).
- `functions/send-fcm/` — Edge Function that drains `notification_queue` and
  delivers pushes via FCM HTTP v1.

---

## 🚀 Getting started

```bash
flutter pub get
flutter run
```

### Configuration
The bundled Supabase anon key is a **publishable** key — data is protected by RLS,
not by hiding it. To point at your own project:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

### Push notifications (optional)
Notifications work end-to-end once you add a Firebase service-account JSON to the
`app_config` table (key `fcm_service_account`). Without it, the app still works
fully — realtime updates carry everything; only background pushes are disabled.

### Applying the backend to a fresh Supabase project
Run the files in `supabase/migrations/` in order, then deploy
`supabase/functions/send-fcm`. `pg_cron` and `pg_net` extensions are enabled by
the migrations.

## 📲 Building for every Android device

```bash
# One APK per CPU type (smallest downloads — recommended for sharing):
flutter build apk --release --split-per-abi
# → app-arm64-v8a-release.apk (most phones)
# → app-armeabi-v7a-release.apk (older/budget phones)
# → app-x86_64-release.apk (emulators)

# Or one universal APK that runs everywhere:
flutter build apk --release
```

Release builds are minified + resource-shrunk (R8, rules in
`android/app/proguard-rules.pro`), signed with the debug key by default so
they're installable immediately — swap in a real upload keystore before a
Play Store release. `minSdk 23` (Android 6.0+) covers effectively every
device in use.

## 🐦 Shorebird code push (OTA patches)

The app ships with [Shorebird](https://shorebird.dev) support
(`shorebird.yaml` app_id `9c9a97dd…`, auto-update on launch, plus a manual
**More → Check for updates** button in-app).

```bash
# one-time setup on your machine
shorebird login

# cut a release users install (Play Store / APK):
shorebird release android

# later: push a Dart-code fix over the air — users get it without reinstalling
shorebird patch android
```

There's also a GitHub Actions workflow (`.github/workflows/shorebird.yml`)
that can run `release`/`patch` from the Actions tab — add a `SHOREBIRD_TOKEN`
repo secret (from `shorebird login:ci`) to enable it. Note: patches only
apply to builds made with `shorebird release`, not plain `flutter build`.

## 🔐 Permissions

The app requests only what each feature needs, in context, and everything
degrades gracefully when denied. **More → Permissions** shows the live status
of every permission (notifications, location, background location, camera,
microphone, SMS) with one-tap grant / open-settings.

---

## 🔒 Security notes
- All data access is gated by Row Level Security, scoped to group membership.
- Whisper sender ids and SafeZap coordinates are AES-256 encrypted with a
  per-group key derived from `group_id + salt`.
- Safe codes are stored as SHA-256 hashes — the plaintext never touches the DB.
