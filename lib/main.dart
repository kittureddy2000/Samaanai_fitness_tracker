import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'screens/auth_gate.dart';
import 'services/auth_service.dart';
import 'services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Disable Provider debug check for production
  Provider.debugCheckInvalidValueType = null;
  
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDyMm6tWemrbUeqRMFNQAjZZuDAPH5GrTU",
      authDomain: "fitness-tracker-8d0ae.firebaseapp.com",
      projectId: "fitness-tracker-8d0ae",
      storageBucket: "fitness-tracker-8d0ae.firebasestorage.app",
      messagingSenderId: "763348902456",
      appId: "1:763348902456:web:a000eed0ea1e4ccc1ebccd",
      measurementId: "G-Q8J9DC0FNY",
    ),
  );
  runApp(const FitnessTrackerApp());
}

class FitnessTrackerApp extends StatelessWidget {
  const FitnessTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => FirebaseService()),
      ],
      child: MaterialApp(
        title: 'Fitness Tracker',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const AuthGate(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
