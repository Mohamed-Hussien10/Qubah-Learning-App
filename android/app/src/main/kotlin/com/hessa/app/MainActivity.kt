package com.hessa.app

import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val securityChannelName = "com.qubah.learning/security"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, securityChannelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "enableProtection" -> {
                        activity?.window?.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        result.success(true)
                    }
                    "disableProtection" -> {
                        activity?.window?.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        result.success(true)
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
            }
    }
}
