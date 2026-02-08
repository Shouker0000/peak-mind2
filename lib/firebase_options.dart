import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static const FirebaseOptions currentPlatform = android;

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCiGTULYjyiFzYUrTtcSVppudgrnvsB2so',
    appId: '1:426260816671:android:32f6abd3204563fe4d862a',
    messagingSenderId: '426260816671',
    projectId: 'peak-mind-e6c19',
    storageBucket: 'peak-mind-e6c19.firebasestorage.app',
  );
}
