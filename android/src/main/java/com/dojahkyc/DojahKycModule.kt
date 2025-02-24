package com.dojahkyc

import com.dojah.kyc_sdk_kotlin.DojahSdk
import com.facebook.react.bridge.LifecycleEventListener
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.WritableMap
import com.facebook.react.bridge.WritableNativeMap


class DojahKycModule(private val reactContext: ReactApplicationContext) :
  ReactContextBaseJavaModule(reactContext) {

  override fun getName(): String {
    return NAME
  }

  // Example method
  // See https://reactnative.dev/docs/native-modules-android
  @ReactMethod
  fun launch(
    widgetId: String,
    referenceId: String? = null,
    email: String? = null,
    promise: Promise
  ) {
    DojahSdk.with(reactContext).launch(widgetId, referenceId, email)
    promise.resolve("Launched Dojah SDK")
  }

  @ReactMethod
  fun getIdHistory(promise: Promise) {
    val writeMap: WritableMap = WritableNativeMap()
    DojahSdk.with(reactContext).getIdHistory().forEach {
      writeMap.putString(it.first, it.second)
    }

    promise.resolve(writeMap)
  }


  companion object {
    const val NAME = "DojahKyc"
  }
}
