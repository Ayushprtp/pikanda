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
# ============ Pikanda plugin keep rules (R8 release builds) ============

# flutter_local_notifications (gson reflection on scheduled notifications)
-keep class com.dexterous.** { *; }
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken

# workmanager background dispatcher
-keep class dev.fluttercommunity.workmanager.** { *; }

# another_telephony (SafeZap SMS, background receivers)
-keep class com.shounakmulay.telephony.** { *; }

# mobile_scanner / ML Kit barcode
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.vision.** { *; }
-dontwarn com.google.mlkit.**

# home_widget (widget provider reflection)
-keep class es.antonborri.home_widget.** { *; }
-keep class com.ayushprtp.pikanda.DistanceWidgetProvider { *; }

# geolocator
-keep class com.baseflow.geolocator.** { *; }

# Play Core (deferred components referenced by Flutter engine)
-dontwarn com.google.android.play.core.**

# Keep Flutter wrapper + engine entry points
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
