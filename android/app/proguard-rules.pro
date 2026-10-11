# Keep rules for release builds (R8 code shrinking).
#
# flutter_local_notifications (v17) saves scheduled reminders with Gson.
# Without these rules R8 strips the generic type info Gson needs, and the
# release app hangs on the start screen once reminders are saved.
# Rules copied from the plugin's example app:
# https://github.com/MaikuB/flutter_local_notifications/blob/master/flutter_local_notifications/example/android/app/proguard-rules.pro
# Not needed once the plugin is upgraded to v19 or higher.

## Gson rules
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class * extends com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer
-keepclassmembers,allowobfuscation class * {
  @com.google.gson.annotations.SerializedName <fields>;
}
-keep,allowobfuscation,allowshrinking class com.google.gson.reflect.TypeToken
-keep,allowobfuscation,allowshrinking class * extends com.google.gson.reflect.TypeToken
