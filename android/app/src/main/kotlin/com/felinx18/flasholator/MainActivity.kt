package com.felinx18.flasholator

import android.content.Intent
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.felinx18.flasholator.translate_and_add_card"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "getText") {
                val intent = intent
                if (Intent.ACTION_PROCESS_TEXT == intent.action) {
                    val text = intent.getCharSequenceExtra(Intent.EXTRA_PROCESS_TEXT).toString()
                    result.success(text)
                } else {
                    result.success(null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

}
