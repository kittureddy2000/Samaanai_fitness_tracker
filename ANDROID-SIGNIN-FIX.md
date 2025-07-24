# Android Google Sign-In Fix

## 🚨 Error: `sign_in_failed, ApiException: 10`

This error indicates OAuth client configuration issues for Android.

## 🔧 Solution Steps

### 1. **Verify Google Cloud Console OAuth Client**

1. Go to: [Google Cloud Console - Credentials](https://console.cloud.google.com/apis/credentials?project=fitness-tracker-8d0ae)
2. Find your **Android OAuth 2.0 Client ID**
3. Click **Edit** (pencil icon)
4. Verify these settings:

   **Application type:** Android
   
   **Package name:** `com.fitnesstracker.fitness_tracker`
   
   **SHA-1 certificate fingerprint:** 
   ```
   53:31:54:40:BD:50:06:48:D1:03:4B:DF:6F:A4:62:FC:E0:37:75:FA
   ```

### 2. **If OAuth Client Doesn't Exist or is Wrong**

1. **Create New Android OAuth Client:**
   - Click **+ CREATE CREDENTIALS** > **OAuth 2.0 Client ID**
   - Application type: **Android**
   - Name: `Fitness Tracker Android`
   - Package name: `com.fitnesstracker.fitness_tracker`
   - SHA-1 certificate fingerprint: `53:31:54:40:BD:50:06:48:D1:03:4B:DF:6F:A4:62:FC:E0:37:75:FA`
   - Click **CREATE**

2. **Update google-services.json:**
   - Download the new `google-services.json` from Firebase Console
   - Replace the current file in `android/app/google-services.json`
   - Rebuild APK: `flutter build apk --release`

### 3. **Alternative: Add SHA-1 to Existing Client**

If you have an existing Android OAuth client:
1. Edit the existing client
2. Add the SHA-1 fingerprint: `53:31:54:40:BD:50:06:48:D1:03:4B:DF:6F:A4:62:FC:E0:37:75:FA`
3. Save changes

### 4. **Verify Firebase Console**

1. Go to: [Firebase Console - Authentication](https://console.firebase.google.com/project/fitness-tracker-8d0ae/authentication/providers)
2. Ensure **Google** provider is enabled
3. Check that your OAuth client ID is listed

## 🧪 Testing Steps

After making changes:
1. Wait 5-10 minutes for propagation
2. Rebuild APK: `flutter build apk --release`  
3. Reinstall on phone
4. Test Google Sign-In

## 📋 Current Configuration

**Project ID:** `fitness-tracker-8d0ae`
**Package Name:** `com.fitnesstracker.fitness_tracker`
**Debug SHA-1:** `53:31:54:40:BD:50:06:48:D1:03:4B:DF:6F:A4:62:FC:E0:37:75:FA`
**Current OAuth Client:** `763348902456-b2ga4vrkv25ecap115hmr8qdh3jk1q73.apps.googleusercontent.com`

## 🚨 Common Issues

- **Wrong SHA-1:** Most common cause
- **Package name mismatch:** Ensure exact match
- **OAuth client not enabled:** Check Google Cloud Console
- **Propagation delay:** Wait 5-10 minutes after changes