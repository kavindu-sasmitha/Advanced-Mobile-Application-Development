// ⚠️ THIS IS A PLACEHOLDER FILE.
//
// Do NOT edit this by hand. Instead, run this in your project root:
//
//   dart pub global activate flutterfire_cli
//   flutterfire configure
//
// This will auto-generate the real firebase_options.dart with your
// actual Firebase project's keys (Android/iOS/Web) and overwrite this file.
// Full steps are in README.md.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'run `flutterfire configure` to generate this file.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform - '
          'run `flutterfire configure` to generate this file.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAXs-7OwMSR8Tliy0_gVOUpKJbiqriCEAk',
    appId: '1:932910203193:android:6559ad34fc8be28083a8e8',
    messagingSenderId: '932910203193',
    projectId: 'vibecast-99a96',
    storageBucket: 'vibecast-99a96.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'REPLACE_ME',
    storageBucket: 'REPLACE_ME.appspot.com',
    iosBundleId: 'REPLACE_ME',
  );
}
