# These are essential for React Native's internal mechanisms and module linking.
-keepclassmembers class com.facebook.react.bridge.JavaModule$$Props { *; }
-keepclassmembers class com.facebook.react.bridge.ModuleSpec { *; }
-keepclassmembers class * implements com.facebook.react.bridge.JavaScriptModule { *; }
-keepclassmembers class * implements com.facebook.react.bridge.NativeModule { *; }

# Prevents the stripping of unused methods in classes that are accessed dynamically.
-keep public class * extends com.facebook.react.bridge.ViewManager { *; }
-keep public class * extends com.facebook.react.uimanager.ViewManager { *; } # Older versions might use this

# Keep React Native module classes and their constructors.
# This is crucial for autolinking and manual linking.
-keep class * implements com.facebook.react.bridge.NativeModule {
    <init>(...);
}
-keep class * extends com.facebook.react.bridge.BaseJavaModule {
    <init>(...);
}
-keep class * extends com.facebook.react.uimanager.ViewManager {
    <init>(...);
}

# Standard dontwarn rules for common React Native dependencies
-dontwarn com.facebook.react.**
-dontwarn com.facebook.jni.**
-dontwarn com.facebook.soloader.**
-dontwarn com.facebook.yoga.**
-dontwarn javax.annotation.**


# Keep your SDK's core Kotlin classes and interfaces (likely in kyc_sdk_kotlin)
-keep class com.dojah.kyc_sdk_kotlin.domain.** { *; }
-keep class com.dojah.kyc_sdk_kotlin.core.Result
-keep interface com.dojah.** { *; }

# IMPORTANT: Keep React Native module and package classes.
-keep class com.dojahkyc.rn.** {*;}


# Keep gRPC classes
-keep class io.grpc.** { *; }

# Keep BouncyCastle classes
-keep class org.bouncycastle.** { *; }

# Keep Conscrypt classes
-keep class org.conscrypt.** { *; }

# Keep OpenJSSE classes
-keep class org.openjsse.** { *; }
