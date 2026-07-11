package com.bloot.app

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.google.firebase.appdistribution.FirebaseAppDistribution
import com.google.firebase.appdistribution.InterruptionLevel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.bloot.app/app_distribution"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Attempt to show Firebase App Distribution feedback notification early.
        // This may fail silently if the tester isn't signed in yet; Dart will
        // retry via the method channel after sign-in completes.
        try {
            FirebaseAppDistribution.getInstance().showFeedbackNotification(
                "Tap to send feedback about Bloot",
                InterruptionLevel.HIGH
            )
        } catch (e: Exception) {
            android.util.Log.w(
                "MainActivity",
                "showFeedbackNotification failed in onCreate (expected before sign-in): ${e.message}"
            )
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "showFeedbackNotification" -> {
                    try {
                        FirebaseAppDistribution.getInstance().showFeedbackNotification(
                            "Tap to send feedback about Bloot",
                            InterruptionLevel.HIGH
                        )
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("FEEDBACK_ERROR", e.message, null)
                    }
                }
                "startFeedback" -> {
                    try {
                        val text = call.argument<String>("text") ?: "Please describe your feedback:"
                        FirebaseAppDistribution.getInstance().startFeedback(text)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("FEEDBACK_ERROR", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
