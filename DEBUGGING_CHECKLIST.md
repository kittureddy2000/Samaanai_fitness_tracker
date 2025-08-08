# 🐛 Google Sign-In ApiException: 10 Debugging Checklist

## 📋 **Critical Questions to Answer**

### **1. Verify the DEBUG_KEYSTORE Secret**
- [ ] **Did you add the `DEBUG_KEYSTORE` secret to GitHub?**
  - Go to: Repository → Settings → Secrets and variables → Actions
  - Confirm `DEBUG_KEYSTORE` exists with the long base64 value

### **2. Verify the Workflow Execution**
- [ ] **Was the staging workflow run AFTER adding DEBUG_KEYSTORE?**
  - Check GitHub Actions tab
  - Look for recent "Pre-Production Deploy" workflow
  - Verify it shows "✅ Using consistent debug keystore (SHA-1 matches Firebase)"

### **3. Analyze the Downloaded APK**

**CRITICAL**: Download the latest APK and run this analysis:

```bash
# Download APK from GitHub Actions artifacts
# Then run our debugging script:
python3 scripts/debug-apk-signing.py ~/Downloads/app-debug.apk
```

**Expected Results:**
- Package: `com.fitnesstracker.fitness_tracker`
- SHA-1: `53:31:54:40:BD:50:06:48:D1:03:4B:DF:6F:A4:62:FC:E0:37:75:FA`
- Project: `fitness-tracker-8d0ae`

### **4. Exact Error Details**

Please provide these details:

#### **When does the error occur?**
- [ ] When opening the app?
- [ ] When tapping Google Sign-In button?
- [ ] When selecting Google account?
- [ ] After selecting Google account?

#### **What is the exact error message?**
```
Exception: Google sign_in failed. Platformexception(Sign_in_failed,com.google.andriod.gms.common.api.apiexception.10,null,null)
```

#### **Device Information**
- [ ] Android version: _____
- [ ] Device model: _____
- [ ] Google Play Services version: _____

### **5. Firebase Console Verification**

**Go to Firebase Console → fitness-tracker-8d0ae → Project Settings → Your apps:**

- [ ] **Android app exists with package**: `com.fitnesstracker.fitness_tracker`
- [ ] **SHA-1 fingerprint registered**: `53:31:54:40:BD:50:06:48:D1:03:4B:DF:6F:A4:62:FC:E0:37:75:FA`
- [ ] **Google Sign-In is enabled** in Authentication → Sign-in method

## 🔍 **Advanced Debugging Steps**

### **Step 1: Check APK Certificate**
```bash
# Install Android build tools if not available
# Then check APK signature:
apksigner verify --print-certs ~/Downloads/app-debug.apk
```

### **Step 2: Compare Keystores**
```bash
# Local debug keystore SHA-1:
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android | grep SHA1

# Compare with APK certificate SHA-1 from Step 1
```

### **Step 3: Check Workflow Logs**
In GitHub Actions, look for these log messages in the staging workflow:
- ✅ `"Using consistent debug keystore (SHA-1 matches Firebase)"`
- ✅ `"google-services.json is valid"`
- ✅ `"Build Debug APK (Staging)"` completed successfully

### **Step 4: Test Local Build**
```bash
# Build locally and compare:
flutter build apk --debug --dart-define=ENVIRONMENT=staging

# Check the locally built APK:
python3 scripts/debug-apk-signing.py build/app/outputs/flutter-apk/app-debug.apk
```

## 🚨 **Common Issues & Solutions**

### **Issue 1: Wrong APK Downloaded**
- **Problem**: Downloaded an old APK built before DEBUG_KEYSTORE fix
- **Solution**: Ensure you download from the LATEST workflow run

### **Issue 2: DEBUG_KEYSTORE Not Applied**
- **Problem**: Workflow didn't use the DEBUG_KEYSTORE secret
- **Solution**: Re-run the workflow, check logs for keystore setup messages

### **Issue 3: SHA-1 Mismatch Still Exists**
- **Problem**: APK still has different SHA-1 than Firebase
- **Solution**: Verify Firebase console has the correct SHA-1 registered

### **Issue 4: Wrong Firebase Project**
- **Problem**: APK configured for wrong Firebase project
- **Solution**: Check GOOGLE_SERVICES_STAGING secret contains staging project config

### **Issue 5: Google Play Services Issue**
- **Problem**: Device Google Play Services outdated/corrupted
- **Solution**: Update Google Play Services on device

## 📱 **Quick Test**

**Try these immediate tests:**

1. **Build and test locally:**
   ```bash
   flutter build apk --debug
   # Install the locally built APK and test Google Sign-In
   ```

2. **Check if web version works:**
   - Test Google Sign-In on web version
   - If web works but mobile doesn't, it's definitely a keystore/SHA-1 issue

3. **Try with different Google account:**
   - Sometimes account-specific issues occur
   - Try signing in with a different Google account

## 📞 **Next Steps Based on Results**

### **If APK SHA-1 is CORRECT but error persists:**
- Issue might be in Firebase console configuration
- Check OAuth client configuration in Google Cloud Console
- Verify Google Sign-In is properly enabled

### **If APK SHA-1 is WRONG:**
- DEBUG_KEYSTORE secret might be corrupted
- Workflow might not be applying it correctly
- Need to regenerate and re-upload DEBUG_KEYSTORE

### **If APK has completely different package/config:**
- GOOGLE_SERVICES_STAGING secret might be wrong
- Workflow might be using wrong environment variables

---

**🎯 PRIORITY: Run the APK analysis script first to get concrete data about what's wrong!**