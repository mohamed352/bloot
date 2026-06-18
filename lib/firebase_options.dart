import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for Linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCNTDDoOpYfOkpWlD0yl3kv7IAY4w3J3yc',
    appId: '1:738592764893:web:2480b3f5dbf26d717efc34',
    messagingSenderId: '738592764893',
    projectId: 'bloot-89b2b',
    authDomain: 'bloot-89b2b.firebaseapp.com',
    storageBucket: 'bloot-89b2b.firebasestorage.app',
    measurementId: 'G-JPB9S7HV45',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAhDoPUSiASJOgs8HeI6TVYMHl-FeOTU9g',
    appId: '1:738592764893:android:e9cf7172926e3a227efc34',
    messagingSenderId: '738592764893',
    projectId: 'bloot-89b2b',
    storageBucket: 'bloot-89b2b.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyARtTnF-LWy1cKgzw9_-r2AvOXvloiMU0s',
    appId: '1:738592764893:ios:2e62a181845091967efc34',
    messagingSenderId: '738592764893',
    projectId: 'bloot-89b2b',
    storageBucket: 'bloot-89b2b.firebasestorage.app',
    iosClientId: '738592764893-k0to50pfuimbfnk67g8oe7hvrk9b7m4v.apps.googleusercontent.com',
    iosBundleId: 'com.bloot.app',
  );
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyARtTnF-LWy1cKgzw9_-r2AvOXvloiMU0s',
    appId: '1:738592764893:ios:2e62a181845091967efc34',
    messagingSenderId: '738592764893',
    projectId: 'bloot-89b2b',
    storageBucket: 'bloot-89b2b.firebasestorage.app',
    iosClientId: '738592764893-k0to50pfuimbfnk67g8oe7hvrk9b7m4v.apps.googleusercontent.com',
    iosBundleId: 'com.bloot.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCNTDDoOpYfOkpWlD0yl3kv7IAY4w3J3yc',
    appId: '1:738592764893:web:2480b3f5dbf26d717efc34',
    messagingSenderId: '738592764893',
    projectId: 'bloot-89b2b',
    authDomain: 'bloot-89b2b.firebaseapp.com',
    storageBucket: 'bloot-89b2b.firebasestorage.app',
    measurementId: 'G-JPB9S7HV45',
  );
}
