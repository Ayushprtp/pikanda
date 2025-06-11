# Required for just_audio/ExoPlayer playback on Android
-keep class com.google.android.exoplayer2.** { *; }
-keep class com.google.android.exoplayer2.ui.** { *; }
-keep class com.ryanheise.just_audio.** { *; }
-keep class com.google.common.** { *; }
-keep class androidx.media3.** { *; }

# Keep Flutter plugin registrant
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }

# Required for reflection and serialization used by ExoPlayer
-keepclassmembers class * {
    @androidx.annotation.Keep *;
}

# Sometimes needed for audio focus and notification
-keep class android.support.v4.media.session.** { *; }
-keep class android.support.v4.media.MediaBrowserServiceCompat { *; }