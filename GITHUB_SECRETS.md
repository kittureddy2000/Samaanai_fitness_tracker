# GitHub Secrets Configuration

This document lists all required GitHub Actions secrets for the three-workflow pipeline.

## Workflow Structure

1. **`preview.yml`** - Feature Testing (feature branches, PRs)
2. **`preproduction.yml`** - Staging (main branch)
3. **`release.yml`** - Production (version tags)

## Required Secrets

### 🔥 Firebase & Authentication
| Secret Name | Used In | Description |
|-------------|---------|-------------|
| `FIREBASE_TOKEN` | All workflows | Firebase CI token for deployment |
| `GOOGLE_SERVICES_STAGING` | preview.yml, preproduction.yml | Base64-encoded staging google-services.json with debug SHA-1 |
| `GOOGLE_SERVICES_PROD` | release.yml | Base64-encoded production google-services.json with release SHA-1 |
| `GOOGLE_CLIENT_ID_STAGING` | preview.yml, preproduction.yml | Web OAuth client ID for staging project |
| `GOOGLE_CLIENT_ID_PRODUCTION` | release.yml | Web OAuth client ID for production project |
| `DEBUG_KEYSTORE` | preview.yml, preproduction.yml | Base64-encoded debug keystore for consistent SHA-1 across CI builds |

### 📱 Android Release Signing (Production Only)
| Secret Name | Used In | Description |
|-------------|---------|-------------|
| `ANDROID_RELEASE_KEYSTORE` | release.yml | Base64-encoded production keystore (.jks file) |
| `ANDROID_RELEASE_KEYSTORE_PASSWORD` | release.yml | Password for the keystore |
| `ANDROID_RELEASE_KEY_PASSWORD` | release.yml | Password for the signing key |
| `ANDROID_RELEASE_KEY_ALIAS` | release.yml | Alias name for the signing key |

## Project Configurations

### Staging Environment (fitness-tracker-8d0ae)
- **Firebase Project**: `fitness-tracker-8d0ae`
- **Web URL**: `https://fitness-tracker-8d0ae.web.app`
- **Android Signing**: Debug keystore (automatic)
- **Environment Variable**: `ENVIRONMENT=staging`

### Production Environment (fitness-tracker-p2025)
- **Firebase Project**: `fitness-tracker-p2025`
- **Web URL**: `https://fitness-tracker-p2025.web.app`
- **Android Signing**: Release keystore (from secrets)
- **Environment Variable**: `ENVIRONMENT=production`

## Workflow Triggers

| Workflow | Trigger | Builds | Deploys To |
|----------|---------|--------|------------|
| **preview.yml** | Feature branches, PRs | Web + Android (debug) | Firebase Preview Channels |
| **preproduction.yml** | Push to `main` branch | Web + Android (debug) | Staging environment |
| **release.yml** | Version tags (v*) | Web + Android (release) | Production environment + GitHub Release |

## Setting Up Secrets

### 1. Generate GOOGLE_SERVICES_STAGING
Run the validation script to generate the correct staging configuration:
```bash
python3 scripts/validate_google_services.py
```

### 2. Firebase Token
```bash
firebase login:ci
```

### 3. Web Client IDs
- **Staging**: `763348902456-l7kcl7qerssghmid1bmc5n53oq2v62ic.apps.googleusercontent.com`
- **Production**: `934862983900-e42cifg34olqbd4u9cqtkvmcfips46fg.apps.googleusercontent.com`

### 4. Android Keystore (Production)
```bash
# Encode your production keystore
base64 -i your-production-keystore.jks
```

## Validation

Run the validation workflow to check all secrets:
```bash
gh workflow run validate-configuration.yml
```

## Troubleshooting

### ApiException: 10 (Google Sign-In)
- Verify SHA-1 fingerprint in `GOOGLE_SERVICES_STAGING` matches debug keystore
- For production, verify SHA-1 matches your production keystore
- Run validation script: `python3 scripts/validate_google_services.py`

### Missing Secrets
- All workflows will fail with clear error messages if secrets are missing
- Check the validation workflow output for specific missing secrets

### Web Client ID Issues  
- Ensure `{{GOOGLE_CLIENT_ID}}` placeholder is replaced in web/index.html
- Verify client IDs match your Firebase project configuration

## Platform Support

All three workflows now support:
- ✅ **Web**: Built and deployed to Firebase Hosting
- ✅ **Android**: APK artifacts available for download
- ✅ **Tests**: Run automatically before builds
- ✅ **Environment-specific configuration**: Proper project targeting