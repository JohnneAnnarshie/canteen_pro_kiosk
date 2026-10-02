package com.persol.canteenpro

import android.annotation.SuppressLint
import android.content.Context
import android.provider.Settings
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "canteen/main_channel"


    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getDeviceSerial" -> {
                    result.success(
                        getDeviceSerialNumber(
                            applicationContext
                        )
                    )
                }
                else -> result.notImplemented()
            }

        }
    }
}

@SuppressLint("HardwareIds")
fun getDeviceSerialNumber(context: Context): String {
    return try {
        // Android 10 and above - restricted
        Log.d("SERIAL NUMBER", "Android 10 and above - restricted")
        Settings.Secure.getString(context.contentResolver, Settings.Secure.ANDROID_ID)

    } catch (e: SecurityException) {
        // No permission for getSerial()
        Log.d("SERIAL NUMBER", "Android 9 and below")
        Settings.Secure.getString(context.contentResolver, Settings.Secure.ANDROID_ID)
    } catch (e: Exception) {
        "unknown"
    }
}
