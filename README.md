# Fitness Tracker

A comprehensive Flutter-based fitness tracking application with Firebase backend, designed for tracking daily nutrition, exercise, and weight management.

## Features

- **Daily Logging**: Track food intake, exercise, weight, and water consumption
- **Dashboard**: Interactive tiles showing BMR, Net Deficit, Consumed, and Burned calories with date navigation
- **Reports**: Visualize data with charts for calories, weight, and water intake across weekly, monthly, and yearly periods
- **Goal Management**: Set and track weight loss goals with progress monitoring
- **Cross-Platform**: Available as web app and Android APK

## Tech Stack

- **Frontend**: Flutter (Web & Android)
- **Backend**: Firebase (Firestore, Authentication, Cloud Functions)
- **CI/CD**: Google Cloud Build with automated deployment
- **Charts**: FL Chart for data visualization

## Live Application

- **Web App**: https://fitness-tracker-8d0ae.web.app/
- **Android APK**: Available via GitHub releases

## Project Structure

```
lib/
├── config/          # Firebase configuration
├── models/          # Data models (DailyEntry, CalorieReport, etc.)
├── screens/         # UI screens (Dashboard, Reports, Daily Log)
├── services/        # Firebase and authentication services
└── widgets/         # Reusable UI components

functions/           # Firebase Cloud Functions
android/            # Android-specific configuration
web/                # Web-specific assets
```

## Key Features Detail

### Dashboard
- Date navigation with previous/next day buttons
- Real-time BMR, calorie deficit, consumption, and burn metrics
- Quick actions for daily logging and reports

### Reports
- Calorie tracking with weekly navigation
- Weight progress visualization (yearly view)
- Water intake monitoring with goal tracking
- Export and analysis capabilities

### Daily Logging
- Comprehensive food and exercise entry
- Weight and water intake tracking
- Date selection with validation

## Deployment

See [DEPLOYMENT.md](./DEPLOYMENT.md) for complete deployment instructions including Play Store readiness.

## Privacy

See [privacy_policy.md](./privacy_policy.md) for the application privacy policy.

## Development Status

✅ **Production Ready**
- All core features implemented and tested
- CI/CD pipeline configured and working
- Play Store deployment ready
- Timezone issues resolved
- Performance optimized