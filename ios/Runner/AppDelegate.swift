import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // NOTE: We intentionally do NOT configure/activate AVAudioSession at
    // launch. Activating .playAndRecord here shows the mic indicator
    // immediately and makes the "audio" UIBackgroundMode look speculative to
    // App Review (guideline 2.5.4). The Agora SDK configures and activates
    // the audio session itself when the user actually joins a voice channel
    // (game room / live stream), which is the only time audio is used.
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
