# GitHub Secrets Configuration

This document outlines all the required GitHub secrets for proper CI/CD deployment across staging and production environments.

## 🔑 Firebase Configuration Secrets

### Staging Environment
- **`GOOGLE_SERVICES_STAGING`**: ✅ ADDED - Base64 encoded content of `google-services.json` from your staging Firebase project (`fitness-tracker-8d0ae`)
  ```bash
  # To generate:
  base64 -i android/app/google-services.json
  ```

- **`GOOGLE_CLIENT_ID_STAGING`**: ✅ ADDED - Web OAuth client ID for staging environment
  ```
  Value: 763348902456-l7kcl7qerssghmid1bmc5n53oq2v62ic.apps.googleusercontent.com
  ```

### Production Environment  
- **`GOOGLE_SERVICES_PROD`**: ✅ ADDED - Base64 encoded content of `google-services.json` from your production Firebase project (`fitness-tracker-p2025`)
  ```bash
  # To generate:
  base64 -i production-google-services.json
  ```

- **`GOOGLE_CLIENT_ID_PRODUCTION`**: ✅ ADDED - Web OAuth client ID for production environment
  ```
  Value: 934862983900-e42cifg34olqbd4u9cqtkvmcfips46fg.apps.googleusercontent.com
  ```

## 🤖 Android Release Signing Secrets

- **`ANDROID_RELEASE_KEYSTORE`**: ❌ MISSING - Your release keystore file (.jks) encoded in Base64
  ```bash
  # To generate:
  base64 -i your-release-keystore.jks
  ```

- **`ANDROID_RELEASE_KEYSTORE_PASSWORD`**: ❌ MISSING - Password for the keystore file

- **`ANDROID_RELEASE_KEY_ALIAS`**: ❌ MISSING - The alias name for your key within the keystore

- **`ANDROID_RELEASE_KEY_PASSWORD`**: ❌ MISSING - Password for the specific key alias

## 🚀 Deployment Secrets

- **`FIREBASE_TOKEN`**: ❓ STATUS UNKNOWN - Firebase CLI token for automated deployments
  ```bash
  # To generate:
  firebase login:ci
  ```

- **`GITHUB_TOKEN`**: ✅ AUTO-PROVIDED - Automatically provided by GitHub Actions (no need to add manually)

## ⚠️ OUTSTANDING ACTIONS REQUIRED

### 🔥 Critical Missing Secrets (Required for Android builds):
```
ANDROID_RELEASE_KEYSTORE
ANDROID_RELEASE_KEYSTORE_PASSWORD  
ANDROID_RELEASE_KEY_ALIAS
ANDROID_RELEASE_KEY_PASSWORD
```

### 🔍 To Check Status:
```
FIREBASE_TOKEN - Check if this exists in your GitHub secrets
```

## 📝 Optional Web Configuration Secrets (Future Enhancement)

- **`FIREBASE_WEB_CONFIG_STAGING`**: JSON object with web app configuration for staging
- **`FIREBASE_WEB_CONFIG_PROD`**: JSON object with web app configuration for production

## ✅ CURRENT STATUS SUMMARY

### ✅ COMPLETED (OAuth should now work):
- **Firebase Configuration**: All staging and production secrets added
- **Web OAuth Client IDs**: Both environments configured
- **Workflows**: Updated to use STAGING notation consistently

### ❌ STILL NEEDED (For Android app releases):
- **Android Signing Secrets**: All four keystore-related secrets
- **Firebase Token**: Verify deployment token exists

### 🎯 NEXT STEPS:
1. Test OAuth login on both staging and production deployments
2. Add missing Android secrets if you plan to build/release Android apps
3. Verify FIREBASE_TOKEN exists for deployment automation

## 🛠 How to Add Secrets

1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add the secret name and value
5. Click **Add secret**

## ✅ Verification

After adding all secrets, your workflows should:
- ✅ Development: Deploy to `fitness-tracker-8d0ae.web.app`
- ✅ Production: Deploy to `fitness-tracker-p2025.web.app`  
- ✅ Both environments have proper OAuth configuration
- ✅ Android builds work with proper signing