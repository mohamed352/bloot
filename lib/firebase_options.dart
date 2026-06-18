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
    apiKey: 'AIzaSyDZFEC6lNOF_rfkIn1r2I-HsSQzdhCOeMU',
    appId: '1:847357865468:web:e87c768aa91b4429fdd679',
    messagingSenderId: '847357865468',
    projectId: 'bloot-d9442',
    authDomain: 'bloot-d9442.firebaseapp.com',
    storageBucket: 'bloot-d9442.firebasestorage.app',
    measurementId: 'G-0G330W28NN',
  );



  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBxrytREMHR-8tYxyISDjkybb__e5O48xU',
    appId: '1:847357865468:android:875d4f7c0af0aaeafdd679',
    messagingSenderId: '847357865468',
    projectId: 'bloot-d9442',
    storageBucket: 'bloot-d9442.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCDz4eW2na-uoggpWwg1LfdlVW8AJOFRTI',
    appId: '1:847357865468:ios:f5f50e5766c8df3efdd679',
    messagingSenderId: '847357865468',
    projectId: 'bloot-d9442',
    storageBucket: 'bloot-d9442.firebasestorage.app',
    iosBundleId: 'com.bloot.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCDz4eW2na-uoggpWwg1LfdlVW8AJOFRTI',
    appId: '1:847357865468:ios:f5f50e5766c8df3efdd679',
    messagingSenderId: '847357865468',
    projectId: 'bloot-d9442',
    storageBucket: 'bloot-d9442.firebasestorage.app',
    iosBundleId: 'com.bloot.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDZFEC6lNOF_rfkIn1r2I-HsSQzdhCOeMU',
    appId: '1:847357865468:web:e87c768aa91b4429fdd679',
    messagingSenderId: '847357865468',
    projectId: 'bloot-d9442',
    authDomain: 'bloot-d9442.firebaseapp.com',
    storageBucket: 'bloot-d9442.firebasestorage.app',
    measurementId: 'G-0G330W28NN',
  );
}
