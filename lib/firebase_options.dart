// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAort8lo37UW6hyPOr2pLsGYt7OEQXv-_I',
    appId: '1:1089824253950:web:60616c90f0f69bc31f02af',
    messagingSenderId: '1089824253950',
    projectId: 'take-note-45a4e',
    authDomain: 'take-note-45a4e.firebaseapp.com',
    storageBucket: 'take-note-45a4e.appspot.com',
    measurementId: 'G-R9DCKPM13M',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB2bWxBdiuYLB8KlJ8TnGpPS-PpWCRuXJM',
    appId: '1:1089824253950:android:abc350e9230a1f051f02af',
    messagingSenderId: '1089824253950',
    projectId: 'take-note-45a4e',
    storageBucket: 'take-note-45a4e.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyADx93hs4diwcQaKFCmJCyDlixcEBL2cZc',
    appId: '1:1089824253950:ios:361e9ce1834142401f02af',
    messagingSenderId: '1089824253950',
    projectId: 'take-note-45a4e',
    storageBucket: 'take-note-45a4e.appspot.com',
    iosClientId: '1089824253950-em84a4tcfqp7ba9ir3en2etauk08lt9q.apps.googleusercontent.com',
    iosBundleId: 'dev.taurs.takeNotes',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyADx93hs4diwcQaKFCmJCyDlixcEBL2cZc',
    appId: '1:1089824253950:ios:361e9ce1834142401f02af',
    messagingSenderId: '1089824253950',
    projectId: 'take-note-45a4e',
    storageBucket: 'take-note-45a4e.appspot.com',
    iosClientId: '1089824253950-em84a4tcfqp7ba9ir3en2etauk08lt9q.apps.googleusercontent.com',
    iosBundleId: 'dev.taurs.takeNotes',
  );
}
