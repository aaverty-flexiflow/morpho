# Flutter-specific rules
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep notification service classes
-keep class com.dexterous.** { *; }

# Keep SQLite / Drift
-keep class com.almworks.sqlite4java.** { *; }
