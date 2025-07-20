# 🔥 Firebase Setup Guide

## Create Firebase Project

### Step 1: Create New Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Create a project"**
3. **Project name**: `fitness-tracker` (or your choice)
4. **Google Analytics**: Enable (recommended)
5. **Analytics account**: Use default or create new
6. Click **"Create project"**

## Authentication Setup

### Step 1: Enable Authentication
1. In Firebase Console → **Authentication**
2. Click **"Get started"**
3. Go to **"Sign-in method"** tab

### Step 2: Configure Sign-in Methods
1. **Email/Password**:
   - Click on "Email/Password"
   - Enable the first option (Email/Password)
   - Click "Save"

2. **Google Sign-In**:
   - Click on "Google"
   - Enable Google sign-in
   - **Project support email**: Your email
   - Click "Save"

### Step 3: Authorized Domains
- Default domains are fine for development
- For production, add your custom domain

## Cloud Firestore Setup

### Step 1: Create Database
1. Go to **Firestore Database**
2. Click **"Create database"**
3. **Security rules**: Start in **test mode** (temporary)
4. **Location**: Choose closest to your users
5. Click **"Create"**

### Step 2: Note Your Settings
- **Project ID**: (displayed in project settings)
- **Database location**: (e.g., us-central1)

## Cloud Functions Setup

### Step 1: Enable Functions
1. Go to **Functions**
2. Click **"Get started"**
3. **Billing**: Upgrade to **Blaze plan** (pay-as-you-go)
   - Functions require billing enabled
   - Free tier is generous for development

### Step 2: Function Configuration
- **Location**: Use same as Firestore
- **Node.js version**: 18 (default)

## App Configuration

### Step 1: Add Android App
1. **Project Settings** → **Your apps**
2. Click **Android icon** to add Android app
3. **Package name**: `com.fitnesstracker.fitness_tracker`
4. **App nickname**: "Fitness Tracker Android"
5. **Debug signing certificate**: Leave empty for now
6. Click **"Register app"**
7. **Download** `google-services.json`
8. **Save location**: `android/app/google-services.json`

### Step 2: Add iOS App
1. Click **iOS icon** to add iOS app
2. **Bundle ID**: `com.fitnesstracker.fitnessTracker`
3. **App nickname**: "Fitness Tracker iOS"
4. **App Store ID**: Leave empty
5. Click **"Register app"**
6. **Download** `GoogleService-Info.plist`
7. **Save location**: `ios/Runner/GoogleService-Info.plist`

## Security Configuration

### Firestore Security Rules
Our app includes comprehensive security rules that:
- Users can only access their own data
- Validate all data types and ranges
- Prevent unauthorized access
- Include rate limiting

### Security Best Practices
1. **API Keys**: Keep your API keys secure
2. **Rules**: Deploy security rules before production
3. **Indexes**: Use proper database indexes
4. **Functions**: Authenticate all function calls

## Environment Variables

### Required Configuration
```bash
# Project ID (from Firebase Console)
FIREBASE_PROJECT_ID=your-project-id

# Function Region (same as database)
FIREBASE_REGION=us-central1

# App Package Names
ANDROID_PACKAGE=com.fitnesstracker.fitness_tracker
IOS_BUNDLE_ID=com.fitnesstracker.fitnessTracker
```

## Billing Information

### Free Tier Limits (Generous for Development)
- **Firestore**: 50,000 reads, 20,000 writes per day
- **Authentication**: Unlimited
- **Functions**: 125,000 invocations, 40,000 GB-seconds per month
- **Storage**: 1GB

### Cost Optimization
- Use Firestore efficiently (batch operations)
- Optimize function execution time
- Use proper indexing
- Monitor usage in Firebase Console

## Testing Configuration

### Firebase Emulators
```bash
# Start emulators for local testing
firebase emulators:start
```

**Emulator Ports**:
- **Auth**: http://localhost:9099
- **Firestore**: http://localhost:8080
- **Functions**: http://localhost:5001
- **UI**: http://localhost:4000

## Verification Checklist

✅ **Project Setup**:
- [ ] Firebase project created
- [ ] Billing enabled (for functions)

✅ **Authentication**:
- [ ] Email/Password enabled
- [ ] Google Sign-In enabled
- [ ] Test user can be created

✅ **Database**:
- [ ] Firestore database created
- [ ] Location selected
- [ ] Test mode enabled initially

✅ **Functions**:
- [ ] Functions enabled
- [ ] Same region as database

✅ **App Configuration**:
- [ ] Android app added with correct package name
- [ ] iOS app added with correct bundle ID
- [ ] Configuration files downloaded

✅ **Security**:
- [ ] Ready to deploy security rules
- [ ] API keys secured

## Next Steps

After Firebase setup:
1. Place configuration files in correct directories
2. Run `firebase login` in terminal
3. Run `firebase use --add` and select your project
4. Deploy backend: `firebase deploy --only firestore:rules,firestore:indexes,functions`
5. Test the app connection

---

**🔥 Firebase is now ready for your Fitness Tracker app!** 