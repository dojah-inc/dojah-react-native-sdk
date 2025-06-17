package com.dojahkyc.rn

import android.app.Activity
import android.content.Intent
import com.dojah.kyc_sdk_kotlin.DojahSdk
import com.dojah.kyc_sdk_kotlin.DOJAH_RESULT_KEY
// import com.dojah.kyc_sdk_kotlin.BACKWARD_CALL_REQUEST_CODE
import com.dojah.kyc_sdk_kotlin.domain.ExtraUserData
import com.facebook.react.bridge.ActivityEventListener
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.WritableMap
import com.facebook.react.bridge.WritableNativeMap
import com.facebook.react.bridge.ReadableMap
import com.dojah.kyc_sdk_kotlin.domain.UserData
import com.dojah.kyc_sdk_kotlin.domain.GovData
import com.dojah.kyc_sdk_kotlin.domain.GovId
import com.dojah.kyc_sdk_kotlin.domain.Location
import com.dojah.kyc_sdk_kotlin.domain.BusinessData

const val BACKWARD_CALL_REQUEST_CODE = 1001

class DojahKycModule(private val reactContext: ReactApplicationContext) :
  ReactContextBaseJavaModule(reactContext), ActivityEventListener{

  var promise: Promise? = null

  init {
        reactContext.addActivityEventListener(this)
    }
  override fun getName(): String {
    return NAME
  }

  // Example method
  // See https://reactnative.dev/docs/native-modules-android
  @ReactMethod()
  fun launch(
    widgetId: String,
    referenceId: String? = null,
    email: String? = null,
    userData: ReadableMap? = null,
    govData: ReadableMap? = null,
    govId: ReadableMap? = null,
    location: ReadableMap? = null,
    businessData: ReadableMap? = null,
    address: String? = null,
    metadata: ReadableMap? = null,
    promise: Promise
  ) {
    val activity = currentActivity

    if (activity == null) {
      promise.reject("D_ACTIVITY_DOES_NOT_EXIST", "Activity doesn't exist")
      return
    }
    this.promise = promise
    try {
      DojahSdk.with(reactContext)
        .launchWithBackwardCompatibility(activity, widgetId, referenceId, email, extraData = ExtraUserData(
          userData = UserData(
            firstName = userData?.getString("firstName"),
            lastName = userData?.getString("lastName"),
            dob = userData?.getString("dob"),
            email = userData?.getString("email")
          ),
          govData = GovData(
            bvn = govData?.getString("bvn"),
            dl = govData?.getString("dl"),
            nin = govData?.getString("nin"),
            vnin = govData?.getString("vnin")
          ),
          govId = GovId(
            national = govId?.getString("national"),
            passport = govId?.getString("passport"),
            dl = govId?.getString("dl"),
            voter = govId?.getString("voter"),
            nin = govId?.getString("nin"),
            others = govId?.getString("others")
          ),
          location = Location(
            latitude = location?.getString("latitude"),
            longitude = location?.getString("longitude")
          ),
          businessData = BusinessData(
            cac = businessData?.getString("cac")
          ),
          address = address,
          metadata = metadata?.toHashMap() as? Map<String, Any>
        ))
    } catch (e: Exception) {
        // this.promise.reject("LAUNCH_ERROR", e.message, e)
        // this.promise = null
    }

  }



  @ReactMethod
  fun getIdHistory(promise: Promise) {
    val writeMap: WritableMap = WritableNativeMap()
    DojahSdk.with(reactContext).getIdHistory().forEach {
      writeMap.putString(it.first, it.second)
    }
    promise.resolve(writeMap)
  }


  override fun onActivityResult(activity:Activity?,requestCode: Int, resultCode: Int, data: Intent?) {
    if (requestCode == BACKWARD_CALL_REQUEST_CODE) {
        if (resultCode == Activity.RESULT_OK) {
            val result = data?.getStringExtra(DOJAH_RESULT_KEY)
            promise?.resolve(result)
        } else {
            promise?.reject("RESULT_FAILED", "Activity did not return OK")
        }
        promise = null
    }
  }

  override fun onNewIntent(intent: Intent?) {
  }

  companion object {
    const val NAME = "DojahKyc"
  }
}
