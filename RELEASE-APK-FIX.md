# Release APK Google Sign-In Fix

## 🎯 Problem Identified
Your release APK uses a different signing certificate than debug APK:

- **Debug SHA-1:** `53:31:54:40:BD:50:06:48:D1:03:4B:DF:6F:A4:62:FC:E0:37:75:FA` ✅ (configured)
- **Release SHA-1:** `C1:FB:C8:A8:57:D8:71:94:6D:46:A1:F4:4C:B5:44:51:E5:F6:5A:32` ❌ (missing)

## 🚀 Solution: Add Release Certificate

### Option 1: Add to Existing OAuth Client (Recommended)
1. Go to: [Google Cloud Console - Credentials](https://console.cloud.google.com/apis/credentials?project=fitness-tracker-8d0ae)
2. Find your Android OAuth client: `763348902456-b2ga4vrkv25ecap115hmr8qdh3jk1q73.apps.googleusercontent.com`
3. Click **Edit** (pencil icon)
4. **Add this SHA-1 certificate fingerprint:**
   ```
   C1:FB:C8:A8:57:D8:71:94:6D:46:A1:F4:4C:B5:44:51:E5:F6:5A:32
   ```
5. Now you'll have **both** certificates:
   - Debug: `53:31:54:40:BD:50:06:48:D1:03:4B:DF:6F:A4:62:FC:E0:37:75:FA`
   - Release: `C1:FB:C8:A8:57:D8:71:94:6D:46:A1:F4:4C:B5:44:51:E5:F6:5A:32`
6. Click **Save**

### Option 2: Create New OAuth Client (Alternative)
1. **+ CREATE CREDENTIALS** > **OAuth 2.0 Client ID**
2. Application type: **Android**
3. Name: `Fitness Tracker Android Release`
4. Package name: `com.fitnesstracker.fitness_tracker`
5. SHA-1: `C1:FB:C8:A8:57:D8:71:94:6D:46:A1:F4:4C:B5:44:51:E5:F6:5A:32`

### After Adding Certificate:
1. **Wait 5-10 minutes** for propagation
2. **Test the release APK** - should now work!
3. **No need to rebuild** - the APK is already correctly signed

## 📋 Certificate Details
**Release Certificate Owner:** krishna.yadamakanti, Samaanai
**Valid Until:** Dec 05, 2052
**Algorithm:** SHA384withRSA

This is a custom keystore that was created for your project, which is why it's different from the debug certificate.

## ✅ Expected Result
After adding the release SHA-1, both APKs should work:
- **Debug APK:** Works with debug certificate
- **Release APK:** Works with release certificate