# ⚡ Quick Start Reference

## 🚀 One-Time Setup

```bash
# 1. Install Flutter (download from flutter.dev)
echo 'export PATH="$PATH:$HOME/development/flutter/bin"' >> ~/.zshrc
source ~/.zshrc

# 2. Verify installation
flutter doctor

# 3. Run setup script
./setup_flutter.sh

# 4. Firebase login
firebase login
firebase use --add

# 5. Deploy backend
firebase deploy --only firestore:rules,firestore:indexes,functions
```

## 📱 Daily Development

```bash
# Start the app
flutter run

# Hot reload (in app)
r

# Hot restart (in app)
R

# Clean build
flutter clean && flutter pub get

# Check dependencies
flutter doctor

# View Firebase logs
firebase functions:log
```

## 🔧 Firebase Commands

```bash
# Check projects
firebase projects:list

# Switch project
firebase use PROJECT_ID

# Deploy functions only
firebase deploy --only functions

# Deploy rules only
firebase deploy --only firestore:rules

# Start emulators
firebase emulators:start
```

## 📊 What You'll Build

- **Authentication**: Email/Google Sign-In
- **Food Logging**: Track daily calories consumed
- **Exercise Logging**: Track calories burned and duration
- **Weight Tracking**: Monitor weight changes
- **BMR Calculation**: Automatic metabolic rate calculation
- **Reports**: Visual charts of calorie deficit trends
- **Real-time Sync**: All data synced across devices

## 🎯 Key Features

- Material 3 design
- Real-time Firebase backend
- Secure user data isolation
- Interactive charts with FL Chart
- BMR calculation using Mifflin-St Jeor equation
- Cloud Functions for complex calculations
- Comprehensive data validation

---

**Need help?** Check `GETTING_STARTED.md` for detailed instructions! 