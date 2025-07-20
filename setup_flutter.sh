#!/bin/bash

echo "🚀 Setting up Fitness Tracker Flutter App..."

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first:"
    echo "   https://docs.flutter.dev/get-started/install/macos"
    exit 1
fi

echo "✅ Flutter found. Checking Flutter installation..."
flutter doctor

echo "📱 Creating Flutter project structure..."
# Initialize Flutter project (this will create android and ios directories)
flutter create --org com.fitnesstracker --project-name fitness_tracker . --overwrite

echo "📦 Installing Flutter dependencies..."
flutter pub get

echo "🔧 Setting up Firebase configuration..."
echo "Please complete these manual steps:"
echo ""
echo "1. Create a Firebase project at https://console.firebase.google.com/"
echo "2. Enable Authentication (Email/Password and Google Sign-In)"
echo "3. Enable Cloud Firestore"
echo "4. Enable Cloud Functions"
echo "5. Download configuration files:"
echo "   - google-services.json → android/app/"
echo "   - GoogleService-Info.plist → ios/Runner/"
echo ""
echo "6. Then run: firebase login"
echo "7. Then run: firebase use --add (select your project)"
echo ""

echo "🚀 Deploy Firebase backend:"
echo "firebase deploy --only firestore:rules,firestore:indexes,functions"

echo ""
echo "✅ Setup script completed!"
echo "📱 Run the app: flutter run" 