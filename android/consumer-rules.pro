# Keep DojahKyc SDK classes from being removed by R8/ProGuard
-keep class com.dojahkyc.** { *; }
-keep class com.dojah.** { *; }

# Keep React Native native module classes
-keepclassmembers class * {
    @com.facebook.react.bridge.ReactMethod <methods>;
}

# Keep annotations
-keepattributes *Annotation*

# Keep Kotlin metadata
-keepattributes RuntimeVisibleAnnotations,RuntimeVisibleParameterAnnotations
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep React Native bridge classes
-keep class com.facebook.react.bridge.** { *; }
-keep class com.facebook.react.** { *; }
