/// Central app configuration.
///
/// The Supabase anon key is a *publishable* key — data is protected by
/// Row Level Security, not by hiding this key. Override at build time with:
/// flutter build apk --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
class AppConfig {
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://byjcsfdgeptejgsstbrb.supabase.co',
  );

  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ5amNzZmRnZXB0ZWpnc3N0YnJiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzcxMDI2NzMsImV4cCI6MjA5MjY3ODY3M30.2hXhFBMhlC_HEacqEhJRcOKvTbqn3cKbLVTg3zKLa24',
  );

  static const appName = 'Pikanda';

  /// SafeZap SMS payload prefix.
  static const safezapPrefix = 'PKD:v1:';
}
