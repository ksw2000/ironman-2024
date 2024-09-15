package com.example.shared_preferences_practice

import android.content.SharedPreferences
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity(){
    private val Channel = "com.github.ksw2000.my_shared_preferences_channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val sharedPreferences: SharedPreferences = getSharedPreferences("FlutterSharedPrefs", MODE_PRIVATE);
        val editor = sharedPreferences.edit();

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, Channel).setMethodCallHandler {call, result ->
            if (call.method == "shared_preferences_set") {
                val key = call.argument<String>("key")
                val value = call.argument<String>("value")
                if (key != null && value != null) {
                    editor.putString(key, value)
                    editor.apply()
                    result.success("Data saved successfully")
                } else {
                    result.error("INVALID_ARGUMENTS", "Key or Value missing", null)
                }
            }else if (call.method == "shared_preferences_get"){
                val key = call.argument<String>("key")
                if (key != null) {
                    // 第一個參數是 key 值，第二個參數是預設值
                    val value = sharedPreferences.getString(key, "")
                    result.success(value)
                } else {
                    result.error("INVALID_ARGUMENTS", "Key missing", null)
                }
            }
        }
    }
}
