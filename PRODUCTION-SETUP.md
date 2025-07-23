# Production OAuth Setup Guide

## 🚨 Current Issue: OAuth Configuration

Your app is successfully deployed to: **https://fitness-tracker-8d0ae.web.app**

However, Google Sign-In is failing because the OAuth client is only configured for localhost.

## 🔧 Required Fixes

### 1. **Firebase Authentication - Authorized Domains**

1. Go to: [Firebase Console - Authentication Settings](https://console.firebase.google.com/project/fitness-tracker-8d0ae/authentication/settings)
2. Click **Authorized domains** tab
3. Click **Add domain**
4. Add: `fitness-tracker-8d0ae.web.app`
5. Click **Done**

### 2. **Google Cloud Console - OAuth Client**

1. Go to: [Google Cloud Console - Credentials](https://console.cloud.google.com/apis/credentials?project=fitness-tracker-8d0ae)
2. Find your **OAuth 2.0 Client ID** (should exist from initial setup)
3. Click **Edit** (pencil icon)
4. **Add Authorized JavaScript origins:**
   - `https://fitness-tracker-8d0ae.web.app`
5. **Add Authorized redirect URIs:**
   - `https://fitness-tracker-8d0ae.web.app/__/auth/handler`
6. Click **Save**

### 3. **Verify Configuration**

After making these changes:
1. Wait 5-10 minutes for propagation
2. Visit: https://fitness-tracker-8d0ae.web.app
3. Try Google Sign-In again

## 🎯 Production URLs

| Environment | Web App URL | Firebase Console |
|-------------|-------------|------------------|
| **Staging** | [fitness-tracker-8d0ae.web.app](https://fitness-tracker-8d0ae.web.app) | [Console](https://console.firebase.google.com/project/fitness-tracker-8d0ae) |
| **Production** | [fitness-tracker-p2025.web.app](https://fitness-tracker-p2025.web.app) | [Console](https://console.firebase.google.com/project/fitness-tracker-p2025) |

## 🔄 For Production Deployment

When you're ready to deploy to production (`fitness-tracker-p2025`), repeat the same steps for that domain as well.

## ✅ Success Indicators

- ✅ Build succeeded in Cloud Build
- ✅ App deployed to Firebase Hosting  
- ❌ OAuth configuration (fix required)
- ⏳ Google Sign-In working (after OAuth fix)

## 📱 Testing Checklist

After OAuth fix:
- [ ] Google Sign-In works
- [ ] User can register/login
- [ ] Dashboard loads with user data
- [ ] Workout tracking functions
- [ ] Reports generation works
- [ ] Data persists across sessions