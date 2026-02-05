# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.

# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Google Play Core Library (Play Store Deferred Components)
-dontwarn com.google.android.play.core.splitcompat.**
-keep class com.google.android.play.core.splitcompat.** { *; }
-dontwarn com.google.android.play.core.splitinstall.**
-keep class com.google.android.play.core.splitinstall.** { *; }
-dontwarn com.google.android.play.core.tasks.**
-keep class com.google.android.play.core.tasks.** { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    @androidx.annotation.Keep <methods>;
}

# Keep classes used by reflection
-keepclassmembers class * {
    @androidx.annotation.Keep <fields>;
}

# Video Player
-keep class com.google.android.exoplayer2.** { *; }

# SharedPreferences
-keep class android.content.SharedPreferences { *; }

# Charts
-keep class com.flchart.** { *; }

# Keep JSON serialization classes
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Keep model classes
-keep class com.example.statistik_indonesia.models.** { *; }

# Remove logging in release builds
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int i(...);
    public static int w(...);
    public static int d(...);
    public static int e(...);
}

# Optimization
-optimizations !code/simplification/arithmetic,!code/simplification/cast,!field/*,!class/merging/*
-optimizationpasses 5
-allowaccessmodification
-dontpreverify

# The remainder of this file is identical to the non-optimized version
-dontusemixedcaseclassnames
-dontskipnonpubliclibraryclasses
-verbose
