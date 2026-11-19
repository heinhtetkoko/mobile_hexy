# PGInAppSDK ships no consumer rules; its Retrofit/Gson models and activities
# must keep their names and members or JSON parsing breaks in release builds.
-keep class com.pg.sdk.** { *; }
-keep class com.kbzbank.payment.** { *; }
-dontwarn com.pg.sdk.**
-dontwarn com.kbzbank.payment.**

# Retrofit / Gson (reflection on generic signatures and annotations)
-keepattributes Signature, InnerClasses, EnclosingMethod, *Annotation*
-keepattributes RuntimeVisibleAnnotations, RuntimeVisibleParameterAnnotations
-keep,allowobfuscation,allowshrinking interface retrofit2.Call
-keep,allowobfuscation,allowshrinking class retrofit2.Response
-keep,allowobfuscation,allowshrinking class kotlin.coroutines.Continuation
-keepclassmembers,allowshrinking,allowobfuscation interface * {
    @retrofit2.http.* <methods>;
}
-dontwarn retrofit2.**
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken
