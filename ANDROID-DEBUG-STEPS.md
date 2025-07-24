# Android Google Sign-In Debug Steps

Since Google Cloud Console is configured correctly, let's try these debugging steps:

## 🔍 Step 1: Try Debug APK First
The release APK might have signing issues. Try the debug APK:

**Location:** `build/app/outputs/flutter-apk/app-debug.apk`

1. Install the debug APK instead
2. Test Google Sign-In
3. If it works, we know it's a release signing issue

## 🔍 Step 2: Check Device Settings

1. **Clear Google Play Services data:**
   - Settings > Apps > Google Play Services > Storage
   - Clear Cache and Clear Data

2. **Clear Google Services Framework:**
   - Settings > Apps > Google Services Framework > Storage  
   - Clear Cache and Clear Data

3. **Restart your phone**

## 🔍 Step 3: Verify Package Name
Check that the installed app has the correct package name:

```bash
# If you have ADB connected
adb shell pm list packages | grep fitness
```

Should show: `package:com.fitnesstracker.fitness_tracker`

## 🔍 Step 4: Enable Google Sign-In API
Ensure the Google Sign-In API is enabled:

1. Go to: [Google Cloud Console - APIs](https://console.cloud.google.com/apis/library?project=fitness-tracker-8d0ae)
2. Search for "Google Sign-In API" 
3. Click and ensure it's **ENABLED**

## 🔍 Step 5: Check Firebase Auth Configuration

1. Go to: [Firebase Console - Authentication](https://console.firebase.google.com/project/fitness-tracker-8d0ae/authentication/providers)
2. Ensure Google provider is **enabled**
3. Check that your OAuth client ID is listed under "Web SDK configuration"

## 🔍 Step 6: Alternative Debugging

If none of the above work, the issue might be:

1. **Google Play Services version** on your phone is outdated
2. **Time/date** on your phone is incorrect
3. **Network connectivity** issues
4. **Firebase project** connection issues

## 🚨 Quick Test Commands

```bash
# Rebuild and reinstall debug APK
flutter build apk --debug
adb install -r build/app/outputs/flutter-apk/app-debug.apk

# Check app logs
adb logcat | grep -i "google\|auth\|sign"
```

Try the debug APK first - if that works, we'll know it's a release signing configuration issue!