import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyDNqubyABoT63QD8_av2vGJcvSPXJzaQIs',
    appId: '1:149001870206:web:0bb43fb8fb2395f759712f',
    messagingSenderId: '149001870206',
    projectId: 'sprint-2-e01d3',
    authDomain: 'sprint-2-e01d3.firebaseapp.com',
    storageBucket: 'sprint-2-e01d3.firebasestorage.app',
    measurementId: 'G-X8RY8HRM55',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDNqubyABoT63QD8_av2vGJcvSPXJzaQIs',
    appId: '1:149001870206:android:0bb43fb8fb2395f759712f',
    messagingSenderId: '149001870206',
    projectId: 'sprint-2-e01d3',
    storageBucket: 'sprint-2-e01d3.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDNqubyABoT63QD8_av2vGJcvSPXJzaQIs',
    appId: '1:149001870206:ios:0bb43fb8fb2395f759712f',
    messagingSenderId: '149001870206',
    projectId: 'sprint-2-e01d3',
    storageBucket: 'sprint-2-e01d3.firebasestorage.app',
    iosBundleId: 'com.example.stylehubApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDNqubyABoT63QD8_av2vGJcvSPXJzaQIs',
    appId: '1:149001870206:ios:0bb43fb8fb2395f759712f',
    messagingSenderId: '149001870206',
    projectId: 'sprint-2-e01d3',
    storageBucket: 'sprint-2-e01d3.firebasestorage.app',
    iosBundleId: 'com.example.stylehubApp',
  );
}
