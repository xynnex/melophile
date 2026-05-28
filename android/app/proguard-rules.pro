# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Just Audio & Audio Service
-keep class com.ryanheise.audioservice.** { *; }
-keep class com.ryanheise.just_audio.** { *; }
-dontwarn com.ryanheise.audioservice.**
-dontwarn com.ryanheise.just_audio.**

# Hive
-keep class com.mongodb.client.model.** { *; }
-dontwarn com.mongodb.client.model.**
-keep class io.hive.** { *; }

# General Android
-keep class android.support.v4.app.CoreComponentFactory

# Keep annotation classes
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod
