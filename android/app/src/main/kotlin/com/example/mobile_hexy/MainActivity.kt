package com.example.mobile_hexy

import android.content.Intent
import android.net.Uri
import android.telecom.TelecomManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "mobile_hexy/phone",
        ).setMethodCallHandler { call, result ->
            if (call.method != "openDialer") {
                result.notImplemented()
                return@setMethodCallHandler
            }

            val number = call.argument<String>("number").orEmpty()
            if (number.isBlank()) {
                result.error("INVALID_NUMBER", "A phone number is required.", null)
                return@setMethodCallHandler
            }

            try {
                val intent = Intent(Intent.ACTION_DIAL, Uri.parse("tel:$number"))
                val telecomManager = getSystemService(TELECOM_SERVICE) as TelecomManager
                telecomManager.defaultDialerPackage
                    ?.takeIf { it.isNotBlank() }
                    ?.let(intent::setPackage)
                startActivity(intent)
                result.success(true)
            } catch (error: Exception) {
                result.error("DIALER_UNAVAILABLE", error.message, null)
            }
        }
    }
}
