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
-keep @com.facebook.react.module.model.ReactModule annotation interface * { ; }
-keep class * implements com.facebook.react.bridge.NativeModule {
    <init>(...);
}
-keep class * extends com.facebook.react.bridge.BaseJavaModule {
    <init>(...);
}
-keep class * extends com.facebook.react.uimanager.ViewManager {
    <init>(...);
}

# Allow obfuscation of the React Native JNI/C++ glue code
-dontobfuscate public class * extends com.facebook.proguard.annotations.DoNotStrip {}
-dontshrink public class * extends com.facebook.proguard.annotations.DoNotStrip {}
-dontoptimize public class * extends com.facebook.proguard.annotations.DoNotStrip {}

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

-keep class com.dojahkyc.rn.** {*;}


# Keep gRPC classes
-keep class io.grpc.** { *; }

# Keep BouncyCastle classes
-keep class org.bouncycastle.** { *; }

# Keep Conscrypt classes
-keep class org.conscrypt.** { *; }

# Keep OpenJSSE classes
-keep class org.openjsse.** { *; }


# Keep gRPC-related classes
-keep class io.grpc.** { *; }
-keep class com.google.android.libraries.places.** { *; }


-keepnames class io.grpc.internal.**
-keepclassmembers class io.grpc.internal.** { *; }
-dontwarn io.grpc.**


#For retrofit
-keepattributes Signature, InnerClasses, EnclosingMethod
-keepattributes RuntimeVisibleAnnotations, RuntimeVisibleParameterAnnotations
-keepattributes AnnotationDefault
-keepclassmembers,allowshrinking,allowobfuscation interface * {
    @retrofit2.http.* <methods>;
}
-dontwarn javax.annotation.**
-dontwarn kotlin.Unit
-dontwarn retrofit2.KotlinExtensions
-dontwarn retrofit2.KotlinExtensions$*
-if interface * { @retrofit2.http.* <methods>; }
-keep,allowobfuscation interface <1>
-keep,allowobfuscation,allowshrinking interface retrofit2.Call
-keep,allowobfuscation,allowshrinking class retrofit2.Response
-keep,allowobfuscation,allowshrinking class kotlin.coroutines.Continuation

#For Okio
-dontwarn org.codehaus.mojo.animal_sniffer.*

#For Gson
-keep class sun.misc.Unsafe { *; }
-keep class com.google.gson.examples.android.model.** { *; }

#For Glide
-keep public class * implements com.bumptech.glide.module.GlideModule
-keep class * extends com.bumptech.glide.module.AppGlideModule {
 <init>(...);
}
-keep public enum com.bumptech.glide.load.ImageHeaderParser$** {
  **[] $VALUES;
  public *;
}
-keep class com.bumptech.glide.load.data.ParcelFileDescriptorRewinder$InternalRewinder {
  *** rewind();
}


# Extensive dontwarn rules
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task

-dontwarn com.android.org.conscrypt.SSLParametersImpl
-dontwarn javax.naming.Binding
-dontwarn javax.naming.NamingEnumeration
-dontwarn javax.naming.NamingException
-dontwarn javax.naming.directory.Attribute
-dontwarn javax.naming.directory.Attributes
-dontwarn javax.naming.directory.DirContext
-dontwarn javax.naming.directory.InitialDirContext
-dontwarn javax.naming.directory.SearchControls
-dontwarn javax.naming.directory.SearchResult
-dontwarn org.apache.harmony.xnet.provider.jsse.SSLParametersImpl
-dontwarn org.bouncycastle.jsse.BCSSLParameters
-dontwarn org.bouncycastle.jsse.BCSSLSocket
-dontwarn org.bouncycastle.jsse.provider.BouncyCastleJsseProvider
-dontwarn org.openjsse.javax.net.ssl.SSLParameters
-dontwarn org.openjsse.javax.net.ssl.SSLSocket
-dontwarn org.openjsse.net.ssl.OpenJSSE

-dontwarn io.grpc.internal.DnsNameResolverProvider
-dontwarn io.grpc.internal.PickFirstLoadBalancerProvider
-dontwarn org.bouncycastle.jsse.BCSSLParameters
-dontwarn org.bouncycastle.jsse.BCSSLSocket
-dontwarn org.bouncycastle.jsse.provider.BouncyCastleJsseProvider
-dontwarn org.conscrypt.Conscrypt$Version
-dontwarn org.conscrypt.Conscrypt