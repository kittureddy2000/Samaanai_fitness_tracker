# 🚀 Getting Started with Fitness Tracker App

## Prerequisites Checklist

Before you begin, make sure you have:
- [ ] macOS system (for iOS development) or any system (for Android only)
- [ ] Internet connection
- [ ] Admin access to install software

## Step 1: Install Flutter SDK

### Download Flutter
1. Visit [Flutter Installation Guide](https://docs.flutter.dev/get-started/install/macos)
2. Download the latest stable Flutter SDK for macOS
3. Extract the zip file to `~/development/flutter`

### Add Flutter to PATH
```bash
# Open terminal and run:
echo 'export PATH="$PATH:$HOME/development/flutter/bin"' >> ~/.zshrc
source ~/.zshrc
```

### Verify Installation
```bash
flutter doctor
```

## Step 2: Install Development Tools

### For iOS Development (Optional)
1. **Install Xcode** from Mac App Store
2. **Install Xcode Command Line Tools:**
   ```bash
   sudo xcode-select --install
   ```
3. **Accept Xcode License:**
   ```bash
   sudo xcodebuild -license
   ```

### For Android Development
1. **Download Android Studio** from https://developer.android.com/studio
2. **Install Android Studio** and follow setup wizard
3. **Install Android SDK** through Android Studio
4. **Accept Android Licenses:**
   ```bash
   flutter doctor --android-licenses
   ```

## Step 3: Run Flutter Setup Script

✅ **Good news!** Firebase CLI is already installed and functions dependencies are ready.

Once Flutter is installed, run our automated setup script:

```bash
./setup_flutter.sh
```

This script will:
- ✅ Verify Flutter installation
- 📱 Create Flutter project structure
- 📦 Install all dependencies
- 🔧 Guide you through Firebase setup

## Step 4: Firebase Project Setup

### Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. Name it "fitness-tracker" (or your preferred name)
4. Enable Google Analytics (optional)

### Enable Services
In your Firebase project:

#### Authentication
1. Go to **Authentication** → **Sign-in method**
2. Enable **Email/Password**
3. Enable **Google** sign-in
4. Add your app's package name

#### Cloud Firestore
1. Go to **Firestore Database**
2. Click **Create database**
3. Start in **test mode** (we'll deploy secure rules later)
4. Choose a location closest to you

#### Cloud Functions
1. Go to **Functions**
2. Click **Get started**
3. Choose your billing plan (Blaze pay-as-you-go for functions)

### Download Configuration Files

#### For Android
1. Go to **Project Settings** → **Your apps**
2. Add Android app with package name: `com.fitnesstracker.fitness_tracker`
3. Download `google-services.json`
4. Place it in `android/app/` directory

#### For iOS
1. Add iOS app with bundle ID: `com.fitnesstracker.fitnessTracker`
2. Download `GoogleService-Info.plist`
3. Place it in `ios/Runner/` directory

## Step 5: Connect to Firebase

### Login to Firebase
```bash
firebase login
```

### Associate Project
```bash
firebase use --add
# Select your Firebase project when prompted
```

## Step 6: Deploy Backend

Deploy your Firebase backend components:

```bash
# Deploy security rules and database indexes
firebase deploy --only firestore:rules,firestore:indexes

# Deploy Cloud Functions
firebase deploy --only functions
```

## Step 7: Run the App

### Start the app
```bash
# For iOS
flutter run -d ios

# For Android
flutter run -d android

# Or let Flutter choose
flutter run
```

## Troubleshooting

### Common Issues

#### Flutter Doctor Issues
```bash
# If you see issues, run:
flutter doctor -v
# Follow the suggestions provided
```

#### Firebase Connection Issues
```bash
# Verify Firebase project
firebase projects:list

# Check current project
firebase use
```

#### Dependencies Issues
```bash
# Clean and reinstall
flutter clean
flutter pub get
```

### Getting Help

1. **Flutter Issues**: Check [Flutter Documentation](https://docs.flutter.dev/)
2. **Firebase Issues**: Check [Firebase Documentation](https://firebase.google.com/docs)
3. **App-specific Issues**: Check the main README.md

## What's Next?

Once the app is running:

1. **Create an account** using email/password or Google Sign-In
2. **Set up your profile** with height, age, and gender for BMR calculation
3. **Start logging** your daily food intake and exercise
4. **View reports** to track your calorie deficit over time

## Project Structure Overview

```
fitness_tracker/
├── lib/                    # Flutter app source code
│   ├── models/            # Data models
│   ├── services/          # Business logic
│   └── screens/           # UI screens
├── functions/             # Firebase Cloud Functions
├── android/               # Android platform files
├── ios/                   # iOS platform files
├── firestore.rules        # Database security rules
├── firestore.indexes.json # Database indexes
└── firebase.json          # Firebase configuration
```

## Success Criteria

✅ Your setup is successful when:
- Flutter doctor shows no critical issues
- Firebase project is connected
- App builds and runs without errors
- You can create an account and log in
- Dashboard loads with today's summary

---

**🎉 Congratulations!** You now have a fully functional fitness tracking app with real-time Firebase backend! 