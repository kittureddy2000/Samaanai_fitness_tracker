# GitHub Secrets Configuration

This document outlines all the required GitHub secrets for proper CI/CD deployment across development and production environments.

## 🔑 Firebase Configuration Secrets

### Development Environment
- **`GOOGLE_SERVICES_DEV`**: Base64 encoded content of `google-services.json` from your development Firebase project (`fitness-tracker-8d0ae`)
  ```bash
  # To generate:
  base64 -i android/app/google-services.json
  ```

- **`GOOGLE_CLIENT_ID_DEV`**: Web OAuth client ID for development environment
  ```
  Value: 763348902456-l7kcl7qerssghmid1bmc5n53oq2v62ic.apps.googleusercontent.com
  ```

### Production Environment  
- **`GOOGLE_SERVICES_PROD`**: Base64 encoded content of `google-services.json` from your production Firebase project (`fitness-tracker-p2025`)
  ```bash
  # To generate:
  base64 -i production-google-services.json
  ```

- **`GOOGLE_CLIENT_ID_PRODUCTION`**: Web OAuth client ID for production environment
  ```
  Value: 934862983900-e42cifg34olqbd4u9cqtkvmcfips46fg.apps.googleusercontent.com
  ```

### Staging Environment
- **`GOOGLE_CLIENT_ID_STAGING`**: Web OAuth client ID for staging environment (uses dev project)
  ```
  Value: 763348902456-l7kcl7qerssghmid1bmc5n53oq2v62ic.apps.googleusercontent.com
  ```

## 🤖 Android Release Signing Secrets

- **`ANDROID_RELEASE_KEYSTORE`**: Your release keystore file (.jks) encoded in Base64
  ```bash
  # To generate:
  base64 -i your-release-keystore.jks
  ```

- **`ANDROID_RELEASE_KEYSTORE_PASSWORD`**: Password for the keystore file

- **`ANDROID_RELEASE_KEY_ALIAS`**: The alias name for your key within the keystore

- **`ANDROID_RELEASE_KEY_PASSWORD`**: Password for the specific key alias

## 🚀 Deployment Secrets

- **`FIREBASE_TOKEN`**: Firebase CLI token for automated deployments
  ```bash
  # To generate:
  firebase login:ci
  ```

- **`GITHUB_TOKEN`**: Automatically provided by GitHub Actions (no need to add manually)

## 📝 Optional Web Configuration Secrets (Future Enhancement)

- **`FIREBASE_WEB_CONFIG_DEV`**: JSON object with web app configuration for development
  ```json
  {
    "apiKey": "AIzaSyAhBC9FUOX02Kj3HBIAmwFOmi9cNFqRR5A",
    "authDomain": "fitness-tracker-8d0ae.firebaseapp.com",
    "projectId": "fitness-tracker-8d0ae",
    "storageBucket": "fitness-tracker-8d0ae.firebasestorage.app",
    "messagingSenderId": "763348902456",
    "appId": "1:763348902456:android:536b977f3ec075131ebccd"
  }
  ```

- **`FIREBASE_WEB_CONFIG_PROD`**: JSON object with web app configuration for production
  ```json
  {
    "apiKey": "AIzaSyAhKu4npHEKmTM5FZTy-jNdcY0kH3W2z6s",
    "authDomain": "fitness-tracker-p2025.firebaseapp.com",
    "projectId": "fitness-tracker-p2025",
    "storageBucket": "fitness-tracker-p2025.firebasestorage.app",
    "messagingSenderId": "934862983900",
    "appId": "1:934862983900:android:9eb21955cbc6a477c1da19"
  }
  ```

## 🔄 Migration from Old Secrets

If you have existing secrets with old names, they need to be renamed:

| Old Secret Name | New Secret Name |
|----------------|-----------------|
| `GOOGLE_SERVICES_JSON_PROD` | `GOOGLE_SERVICES_PROD` |
| `KEYSTORE_FILE_PROD` | `ANDROID_RELEASE_KEYSTORE` |
| `KEYSTORE_PASSWORD` | `ANDROID_RELEASE_KEYSTORE_PASSWORD` |
| `KEY_PASSWORD` | `ANDROID_RELEASE_KEY_PASSWORD` |
| `KEY_ALIAS` | `ANDROID_RELEASE_KEY_ALIAS` |

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