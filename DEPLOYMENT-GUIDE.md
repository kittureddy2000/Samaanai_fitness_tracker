# Deployment Guide - Testing & Production URLs

## 🎯 Understanding Your Deployment Setup

You have **two separate environments** with **two Cloud Build triggers** that deploy to different locations:

### **Trigger 1: `deploy-staging` (Automatic)**
- **When it triggers:** Every time you `git push origin main`
- **Configuration file:** `cloudbuild.yaml`
- **Deploys to:** Staging environment (`fitness-tracker-8d0ae`)
- **Control:** Automatic - no approval needed

### **Trigger 2: `deploy-production` (Manual)**
- **When it triggers:** Only when you manually click "Run trigger" in Cloud Build Console
- **Configuration file:** `cloudbuild-production.yaml`
- **Deploys to:** Production environment (`fitness-tracker-p2025`)
- **Control:** Manual approval - you decide when to deploy

---

## 🌐 Deployment Destinations

### **Staging Environment** (Auto-deploys on git push)
- **Web App URL:** https://fitness-tracker-8d0ae.web.app
- **Firebase Project ID:** `fitness-tracker-8d0ae`
- **Firebase Console:** https://console.firebase.google.com/project/fitness-tracker-8d0ae
- **Android APK Storage:** `gs://fitness-tracker-build-artifacts`
- **Purpose:** Testing and development

### **Production Environment** (Manual deployment only)
- **Web App URL:** https://fitness-tracker-p2025.web.app
- **Firebase Project ID:** `fitness-tracker-p2025`
- **Firebase Console:** https://console.firebase.google.com/project/fitness-tracker-p2025
- **Android APK Storage:** `gs://fitness-tracker-prod-artifacts`
- **Purpose:** Live users

---

## 🔄 Complete Development & Testing Workflow

### **1. Daily Development Workflow**
```bash
# Make your changes locally
git add .
git commit -m "Add new feature"
git push origin main

# 🤖 AUTOMATIC: deploy-staging trigger runs
# ✅ Staging web app updates: https://fitness-tracker-8d0ae.web.app
# ❌ Production remains unchanged
```

### **2. Monitor Build Progress**
- **Cloud Build Console:** https://console.cloud.google.com/cloud-build
- **Build takes:** 5-10 minutes typically
- **Build includes:** Web deployment + Android APK/AAB generation

### **3. Testing Your Changes**

#### **Web App Testing:**
1. Wait for build to complete (check Cloud Build console)
2. Visit: **https://fitness-tracker-8d0ae.web.app**
3. Test all your new features
4. Check Firebase Console for any errors

#### **Android App Testing:**
1. Go to **Cloud Build Console** → Build History
2. Click your latest successful build
3. Go to **Artifacts** tab
4. Download files:
   - `app-release.apk` (for direct installation)
   - `app-release.aab` (for Google Play Store)
5. Install APK on Android device:
   ```bash
   # Enable "Unknown Sources" in Android settings first
   adb install app-release.apk
   ```

### **4. Production Deployment (When Ready)**
```bash
# Only deploy to production when staging tests pass!

# 1. Go to Cloud Build Console
# 2. Find "deploy-production" trigger
# 3. Click "Run Trigger"
# 4. Wait for build to complete
# 5. Test production: https://fitness-tracker-p2025.web.app
```

---

## 📊 Quick Reference URLs

| Environment | Web URL | Firebase Console | Purpose |
|-------------|---------|------------------|---------|
| **Staging** | [fitness-tracker-8d0ae.web.app](https://fitness-tracker-8d0ae.web.app) | [Console](https://console.firebase.google.com/project/fitness-tracker-8d0ae) | Testing/Development |
| **Production** | [fitness-tracker-p2025.web.app](https://fitness-tracker-p2025.web.app) | [Console](https://console.firebase.google.com/project/fitness-tracker-p2025) | Live Users |

---

## 🛠 Build Monitoring & Troubleshooting

### **Cloud Build Console**
- **URL:** https://console.cloud.google.com/cloud-build
- **Check build status:** See if builds pass/fail
- **View build logs:** Debug any issues
- **Download artifacts:** Get Android APK/AAB files

### **Build Artifacts Locations**
- **Staging builds:** `gs://fitness-tracker-build-artifacts`
- **Production builds:** `gs://fitness-tracker-prod-artifacts`

### **Common Build Times**
- **Web build + deploy:** 3-5 minutes
- **Android APK build:** 2-3 minutes  
- **Android AAB build:** 2-3 minutes
- **Total pipeline:** 5-10 minutes

---

## 🎭 Example Scenarios

### **Scenario 1: Daily Feature Development**
```bash
# You fix a bug
git commit -m "Fix login validation bug"
git push origin main

# ✅ Automatic staging deployment
# 🧪 Test at: https://fitness-tracker-8d0ae.web.app
# ❌ Production unchanged (safe!)
```

### **Scenario 2: Ready for Production Release**
```bash
# After thorough testing on staging
# 1. Go to Cloud Build Console
# 2. Manually trigger "deploy-production"  
# 3. ✅ Production updated: https://fitness-tracker-p2025.web.app
```

### **Scenario 3: Need Android APK for Testing**
```bash
# After any successful build
# 1. Go to Cloud Build Console → Build History
# 2. Click latest build → Artifacts tab
# 3. Download app-release.apk
# 4. Install on Android device for testing
```

---

## 🚨 Important Safety Notes

1. **Never manually deploy to production Firebase** using `firebase deploy` - always use the Cloud Build production trigger
2. **Always test on staging first** before production deployment  
3. **Production deployments are manual only** - no accidents possible
4. **Each environment has separate data** - staging won't affect production users
5. **Build artifacts are stored safely** in Cloud Storage for later download

---

## 🎯 Your Main Testing URL

**Primary staging URL for all testing:** 
# 🔗 https://fitness-tracker-8d0ae.web.app

*Last updated: Testing Cloud Build trigger*

Bookmark this URL - it's where you'll test every change before production!