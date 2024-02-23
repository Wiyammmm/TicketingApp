package com.example.dltb

import android.os.Build
import android.os.Bundle
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import java.lang.reflect.Method
class MainActivity: FlutterActivity() {
    // private val CHANNEL = "com.flutter.epic/epic"

    // override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    //     GeneratedPluginRegistrant.registerWith(flutterEngine)
    //     MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { methodCall, result->
    //         if(methodCall.method == "Printy") {
    //             result.success("Hello From The Kotlin")
    //         }
    //     }
    // }
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val systemPropertiesClass = Class.forName("android.os.SystemProperties")
        val getMethod: Method = systemPropertiesClass.getDeclaredMethod("get", String::class.java)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.flutter.epic/epic").setMethodCallHandler {
          call, result ->
            if(call.method == "Printy") {
            //   result.success("Hello From The Kotlin")
            val serial: String? = getSerialNumber(getMethod)
            result.success(serial)
            }
            else {
              result.notImplemented()
            }
        }
      }
      private fun getSerialNumber(getMethod: Method): String? {
        val apiLevel = Build.VERSION.SDK_INT

        return when {
            apiLevel >= Build.VERSION_CODES.R -> {
                try {
                    getMethod.invoke(null, "ro.sunmi.serial") as String
                } catch (e: Exception) {
                    e.printStackTrace()
                    null
                }
            }
            apiLevel >= Build.VERSION_CODES.O -> Build.getSerial()
            else -> {
                try {
                    getMethod.invoke(null, "ro.serialno") as String
                } catch (e: Exception) {
                    e.printStackTrace()
                    null
                }
            }
        }
    }
}