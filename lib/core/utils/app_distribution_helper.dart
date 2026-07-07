import 'dart:developer';

import 'package:flutter/services.dart';

/// Helper to communicate with the native Firebase App Distribution SDK.
class AppDistributionHelper {
  static const MethodChannel _channel = MethodChannel(
    'com.bloot.app/app_distribution',
  );

  /// Show the persistent feedback notification for testers.
  static Future<void> showFeedbackNotification() async {
    try {
      await _channel.invokeMethod('showFeedbackNotification');
      log('Feedback notification shown successfully.');
    } on PlatformException catch (e) {
      log('Failed to show feedback notification: ${e.message}');
    }
  }

  /// Start the feedback flow directly.
  static Future<void> startFeedback({String text = 'Please describe your feedback:'}) async {
    try {
      await _channel.invokeMethod('startFeedback', {'text': text});
      log('Feedback started successfully.');
    } on PlatformException catch (e) {
      log('Failed to start feedback: ${e.message}');
    }
  }
}
