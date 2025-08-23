// generated file
// ignore_for_file: public_member_api_docs

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      // generated file
      // ignore: no_default_cases
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA15ZXE0D8krzRBweaeqYfyZpnU7z2EbCs',
    appId: '1:168730393077:web:4001d41d73f9ef725a08bc',
    messagingSenderId: '168730393077',
    projectId: 'aegis-docs',
    authDomain: 'aegis-docs.firebaseapp.com',
    storageBucket: 'aegis-docs.firebasestorage.app',
    measurementId: 'G-2M89HDBYB8',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBjeCnCQdG73642hCCjnzasQAwcpBZLX8k',
    appId: '1:168730393077:android:68666ef30191f9c15a08bc',
    messagingSenderId: '168730393077',
    projectId: 'aegis-docs',
    storageBucket: 'aegis-docs.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA15ZXE0D8krzRBweaeqYfyZpnU7z2EbCs',
    appId: '1:168730393077:web:7db4a58eaccb446f5a08bc',
    messagingSenderId: '168730393077',
    projectId: 'aegis-docs',
    authDomain: 'aegis-docs.firebaseapp.com',
    storageBucket: 'aegis-docs.firebasestorage.app',
    measurementId: 'G-SNP0EDRMJW',
  );
}
