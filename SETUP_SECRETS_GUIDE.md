# 🔐 Complete GitHub Secrets Setup Guide

Follow this step-by-step guide to set up all required GitHub Actions secrets.

## 🎯 **Step 1: Access GitHub Secrets**

1. Go to your GitHub repository: `https://github.com/YOUR_USERNAME/Samaanai_fitness_tracker`
2. Click the **Settings** tab
3. In the left sidebar, click **Secrets and variables** → **Actions**
4. You'll see a page where you can add repository secrets

## 🔥 **Step 2: Firebase Token**

```bash
# Login to Firebase and get CI token
firebase login:ci
```

Copy the token and add it as:
- **Secret Name**: `FIREBASE_TOKEN`
- **Secret Value**: The token from the command above

## 🌐 **Step 3: Web Client IDs**

These are already known from your Firebase projects:

### Add Staging Web Client ID:
- **Secret Name**: `GOOGLE_CLIENT_ID_STAGING`
- **Secret Value**: `763348902456-l7kcl7qerssghmid1bmc5n53oq2v62ic.apps.googleusercontent.com`

### Add Production Web Client ID:
- **Secret Name**: `GOOGLE_CLIENT_ID_PRODUCTION`  
- **Secret Value**: `934862983900-e42cifg34olqbd4u9cqtkvmcfips46fg.apps.googleusercontent.com`

## 📱 **Step 4: Android Google Services**

### 4A. Staging Google Services

Your current `android/app/google-services.json` is already configured for staging. Encode it:

```bash
base64 -i android/app/google-services.json
```

Add this as:
- **Secret Name**: `GOOGLE_SERVICES_STAGING`
- **Secret Value**: The base64 output from above

### 4B. Production Google Services

You need to create a production `google-services.json` from your Firebase production project. Here's how:

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your **production project**: `fitness-tracker-p2025`
3. Click ⚙️ **Project Settings**
4. Go to **Your apps** section
5. Find your Android app or add one if missing:
   - **Package name**: `com.fitnesstracker.fitness_tracker`
   - **App nickname**: `Fitness Tracker Production`
6. Download the `google-services.json` file
7. **IMPORTANT**: Before using it, you need to add your production keystore SHA-1 to Firebase (see Step 5 first)

## 🔑 **Step 5: Create Production Keystore (Critical Step!)**

Currently, you only have a debug keystore. For production releases, you need a production keystore.

### 5A. Create the Production Keystore

```bash
# Run the helper script
./scripts/create-production-keystore.sh
```

**OR manually create it:**

```bash
keytool -genkey -v \
    -keystore android/app/fitness-tracker-production.jks \
    -alias fitness-tracker-key \
    -keyalg RSA \
    -keysize 2048 \
    -validity 9125 \
    -storetype JKS
```

You'll be prompted to enter:
- **Keystore password** (remember this!)
- **Key password** (remember this!)
- **Your name, organization, city, state, country**

### 5B. Get Production SHA-1 Fingerprint

```bash
keytool -list -v \
    -keystore android/app/fitness-tracker-production.jks \
    -alias fitness-tracker-key
```

Copy the **SHA1 fingerprint** (format: `AA:BB:CC:DD:...`)

### 5C. Add Production SHA-1 to Firebase

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select **production project**: `fitness-tracker-p2025`  
3. Go to **Project Settings** → **Your apps**
4. Find your Android app
5. Click **Add fingerprint**
6. Paste your production SHA-1 fingerprint
7. **Download the updated `google-services.json`**

### 5D. Encode Production Google Services

```bash
# Encode the updated production google-services.json
base64 -i /path/to/production-google-services.json
```

Add this as:
- **Secret Name**: `GOOGLE_SERVICES_PROD`
- **Secret Value**: The base64 output

## 🔐 **Step 6: Production Android Signing Secrets**

### 6A. Encode Production Keystore

```bash
base64 -i android/app/fitness-tracker-production.jks
```

Add this as:
- **Secret Name**: `ANDROID_RELEASE_KEYSTORE`
- **Secret Value**: The base64 output

### 6B. Add Keystore Passwords

Add these secrets with the passwords you entered when creating the keystore:

- **Secret Name**: `ANDROID_RELEASE_KEYSTORE_PASSWORD`
- **Secret Value**: Your keystore password

- **Secret Name**: `ANDROID_RELEASE_KEY_PASSWORD`  
- **Secret Value**: Your key password

- **Secret Name**: `ANDROID_RELEASE_KEY_ALIAS`
- **Secret Value**: `fitness-tracker-key`

## ✅ **Step 7: Verify All Secrets**

Your GitHub secrets should now include:

### 🔥 Firebase & Auth (5 secrets)
- ✅ `FIREBASE_TOKEN`
- ✅ `GOOGLE_SERVICES_STAGING`
- ✅ `GOOGLE_SERVICES_PROD`
- ✅ `GOOGLE_CLIENT_ID_STAGING`
- ✅ `GOOGLE_CLIENT_ID_PRODUCTION`

### 📱 Android Production (4 secrets)
- ✅ `ANDROID_RELEASE_KEYSTORE`
- ✅ `ANDROID_RELEASE_KEYSTORE_PASSWORD`
- ✅ `ANDROID_RELEASE_KEY_PASSWORD`  
- ✅ `ANDROID_RELEASE_KEY_ALIAS`

**Total: 9 secrets**

## 🧪 **Step 8: Test the Setup**

### Run Validation Workflow
```bash
gh workflow run validate-configuration.yml
```

### Test Feature Workflow
1. Create a feature branch: `git checkout -b feature/test-workflows`
2. Make a small change and push
3. Check if the workflow runs successfully

### Test Staging Workflow
1. Merge your feature branch to `main`
2. Check if staging deployment works

### Test Production Workflow
1. Create a version tag: `git tag v1.0.1`
2. Push the tag: `git push origin v1.0.1`
3. Check if production deployment works

## ⚠️ **Important Security Notes**

1. **Never commit keystore files** - they're in `.gitignore`
2. **Back up your production keystore** - if you lose it, you can't update your app
3. **Keep passwords secure** - store them in a password manager
4. **Production keystore is permanent** - you can't change it once you publish to Play Store

## 🔧 **Troubleshooting**

### "ApiException: 10" Error
- Make sure production SHA-1 fingerprint is added to Firebase
- Verify `GOOGLE_SERVICES_PROD` contains the updated JSON with your production SHA-1

### "Keystore not found" Error
- Check that `ANDROID_RELEASE_KEYSTORE` is properly base64 encoded
- Verify the keystore alias matches `ANDROID_RELEASE_KEY_ALIAS`

### "Invalid JSON" Error  
- Validate your google-services.json: `python3 -m json.tool android/app/google-services.json`
- Re-download from Firebase if corrupted