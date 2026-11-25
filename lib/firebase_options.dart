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
    apiKey: 'AIzaSyCQWMmfy09xhFJg9Ph_lvcOvQGU-_b-FP8',
    appId: '1:920540020001:web:852034cbecff2ea3119260',
    messagingSenderId: '920540020001',
    projectId: 'bloot-42242',
    authDomain: 'bloot-42242.firebaseapp.com',
    storageBucket: 'bloot-42242.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAeRmRMSAQ_XkwduOh7Ym4mwba3K1B7__M',
    appId: '1:920540020001:android:ae6207b2cf12c108119260',
    messagingSenderId: '920540020001',
    projectId: 'bloot-42242',
    storageBucket: 'bloot-42242.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDe8_EY6qpbaLOIc_7inOiE7BrJ4kzcGqc',
    appId: '1:920540020001:ios:73fc10afa80e1de9119260',
    messagingSenderId: '920540020001',
    projectId: 'bloot-42242',
    storageBucket: 'bloot-42242.firebasestorage.app',
    iosClientId: '920540020001-3ql2mjtbech97p52b1ood69s6pint1at.apps.googleusercontent.com',
    iosBundleId: 'com.bloot.app',
  );
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDe8_EY6qpbaLOIc_7inOiE7BrJ4kzcGqc',
    appId: '1:920540020001:ios:73fc10afa80e1de9119260',
    messagingSenderId: '920540020001',
    projectId: 'bloot-42242',
    storageBucket: 'bloot-42242.firebasestorage.app',
    iosClientId: '920540020001-3ql2mjtbech97p52b1ood69s6pint1at.apps.googleusercontent.com',
    iosBundleId: 'com.bloot.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCQWMmfy09xhFJg9Ph_lvcOvQGU-_b-FP8',
    appId: '1:920540020001:web:852034cbecff2ea3119260',
    messagingSenderId: '920540020001',
    projectId: 'bloot-42242',
    authDomain: 'bloot-42242.firebaseapp.com',
    storageBucket: 'bloot-42242.firebasestorage.app',
  );
}
