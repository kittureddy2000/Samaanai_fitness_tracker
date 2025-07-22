import 'package:firebase_core/firebase_core.dart';

class FirebaseConfig {
  static FirebaseOptions get currentPlatform {
    // In production, these should come from environment variables
    // For now, using the existing configuration
    // TODO: Move to environment variables before production deployment
    return const FirebaseOptions(
      apiKey: "AIzaSyDyMm6tWemrbUeqRMFNQAjZZuDAPH5GrTU",
      authDomain: "fitness-tracker-8d0ae.firebaseapp.com",
      projectId: "fitness-tracker-8d0ae",
      storageBucket: "fitness-tracker-8d0ae.firebasestorage.app",
      messagingSenderId: "763348902456",
      appId: "1:763348902456:web:a000eed0ea1e4ccc1ebccd",
      measurementId: "G-Q8J9DC0FNY",
    );
  }
  
  // Environment-based configuration (recommended for production)
  static FirebaseOptions get environmentConfig {
    // These values should be set as environment variables
    const String? apiKey = String.fromEnvironment('FIREBASE_API_KEY');
    const String? authDomain = String.fromEnvironment('FIREBASE_AUTH_DOMAIN');
    const String? projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
    const String? storageBucket = String.fromEnvironment('FIREBASE_STORAGE_BUCKET');
    const String? messagingSenderId = String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
    const String? appId = String.fromEnvironment('FIREBASE_APP_ID');
    const String? measurementId = String.fromEnvironment('FIREBASE_MEASUREMENT_ID');
    
    if (apiKey == null || projectId == null) {
      throw Exception('Firebase configuration missing. Please set environment variables.');
    }
    
    return FirebaseOptions(
      apiKey: apiKey,
      authDomain: authDomain ?? '$projectId.firebaseapp.com',
      projectId: projectId,
      storageBucket: storageBucket ?? '$projectId.firebasestorage.app',
      messagingSenderId: messagingSenderId ?? '',
      appId: appId ?? '',
      measurementId: measurementId,
    );
  }
}