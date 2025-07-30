# 🚀 Development Workflow & Deployment Guide

## 📋 Table of Contents
- [Branch Strategy](#branch-strategy)
- [Development Workflow](#development-workflow)
- [Deployment Environments](#deployment-environments)
- [GitHub Actions Workflows](#github-actions-workflows)
- [Firebase Projects](#firebase-projects)
- [Quick Start Guide](#quick-start-guide)
- [Troubleshooting](#troubleshooting)

---

## 🌳 Branch Strategy

We use **GitHub Flow** with multiple environments for safe, reliable deployments.

### Branch Structure
```
feature/new-exercise-tracker  →  Preview Environment
    ↓ (Pull Request)
develop  →  Staging Environment  
    ↓ (Pull Request)
main  →  Pre-Production Environment
    ↓ (Git Tag v1.0.0)
production  →  Live Production Environment
```

### Branch Purposes

| **Branch** | **Purpose** | **Deployment** | **Access** |
|------------|-------------|----------------|------------|
| `feature/*` | New features, bug fixes | Preview URLs | Developers |
| `develop` | Integration testing | Staging | Dev team |
| `main` | Production-ready code | Pre-production | QA team |
| `v*` tags | Production releases | Live production | End users |

---

## 🔄 Development Workflow

### 1. **Start New Feature**
```bash
# Create and switch to feature branch
git checkout develop
git pull origin develop
git checkout -b feature/add-exercise-tracker

# Make your changes
# ... code, test, commit ...

# Push feature branch
git push -u origin feature/add-exercise-tracker
```

### 2. **Preview & Test**
- **Automatic**: Push to feature branch triggers preview deployment
- **Preview URL**: `https://fitness-tracker-8d0ae--preview-BRANCH-NAME.web.app`
- **Duration**: Preview available for 7 days
- **Mobile**: Test locally with `flutter run`

### 3. **Create Pull Request to Develop**
```bash
# Create PR from feature branch to develop
# GitHub will automatically:
# - Run tests
# - Deploy preview
# - Add preview URL comment to PR
```

### 4. **Code Review & Merge to Develop**
- **Review**: Team reviews code and tests preview
- **Merge**: Approved PR gets merged to `develop`
- **Deploy**: Automatic deployment to staging environment

### 5. **Integration Testing**
- **Staging URL**: `https://fitness-tracker-8d0ae.web.app`
- **Testing**: Full integration testing on staging
- **Mobile**: Debug APK testing

### 6. **Promote to Main (Pre-Production)**
```bash
# Create PR from develop to main
git checkout main
git pull origin main
git checkout -b release/v1.0.1
git merge develop
git push -u origin release/v1.0.1

# Create PR: release/v1.0.1 → main
```

### 7. **Final Testing & Production Release**
```bash
# After merging to main, create production release
git checkout main
git pull origin main
git tag v1.0.1
git push origin v1.0.1
```

---

## 🌍 Deployment Environments

### Environment Overview

| **Environment** | **Branch/Tag** | **Firebase Project** | **Web URL** | **Purpose** |
|-----------------|----------------|---------------------|-------------|-------------|
| **Preview** | `feature/*` | `fitness-tracker-8d0ae` | `*.--preview-*.web.app` | Feature testing |
| **Staging** | `develop` | `fitness-tracker-8d0ae` | `fitness-tracker-8d0ae.web.app` | Integration testing |
| **Pre-Production** | `main` | `fitness-tracker-8d0ae` | `fitness-tracker-8d0ae.web.app` | Final validation |
| **Production** | `v*` tags | `fitness-tracker-p2025` | `fitness-tracker-p2025.web.app` | Live users |

### Environment Details

#### 🔍 **Preview Environment**
- **Trigger**: Push to `feature/*`, `bugfix/*`, `hotfix/*` branches
- **Firebase**: Development project (`fitness-tracker-8d0ae`)
- **URL**: Dynamic preview channels
- **Mobile**: Local testing only
- **Data**: Development database
- **Duration**: 7 days auto-cleanup

#### 🧪 **Staging Environment**
- **Trigger**: Push to `develop` branch
- **Firebase**: Development project (`fitness-tracker-8d0ae`)
- **URL**: `https://fitness-tracker-8d0ae.web.app`
- **Mobile**: Debug APK (local builds)
- **Data**: Development database
- **Purpose**: Integration testing, team demos

#### 🎯 **Pre-Production Environment**
- **Trigger**: Push to `main` branch
- **Firebase**: Development project (`fitness-tracker-8d0ae`)
- **URL**: `https://fitness-tracker-8d0ae.web.app` (overwrites staging)
- **Mobile**: Debug APK (local builds)
- **Data**: Development database
- **Purpose**: Final validation before production

#### 🚀 **Production Environment**
- **Trigger**: Git tags (`v1.0.0`, `v1.1.0`, etc.)
- **Firebase**: Production project (`fitness-tracker-p2025`)
- **URL**: `https://fitness-tracker-p2025.web.app`
- **Mobile**: Signed APK/AAB with production keystore
- **Data**: Production database
- **Purpose**: Live users, app store distribution

---

## ⚙️ GitHub Actions Workflows

### Workflow Files

| **File** | **Trigger** | **Environment** | **Actions** |
|----------|-------------|----------------|-------------|
| `.github/workflows/preview.yml` | Feature branches, PRs | Preview | Web build, preview deploy, PR comment |
| `.github/workflows/development.yml` | `develop` branch | Staging | Web build, staging deploy, tests |
| `.github/workflows/preproduction.yml` | `main` branch | Pre-Production | Web build, pre-prod deploy, tests |
| `.github/workflows/release.yml` | Git tags `v*` | Production | Web + mobile build, prod deploy, GitHub release |

### Workflow Details

#### 🔍 **Preview Workflow** (`preview.yml`)
```yaml
Triggers: feature/*, bugfix/*, hotfix/*, PRs
Actions:
  ✅ Install Flutter & Firebase CLI
  ✅ Run tests (flutter test)
  ✅ Build web (--dart-define=ENVIRONMENT=development)
  ✅ Deploy to Firebase preview channel
  ✅ Comment preview URL on PR
```

#### 🧪 **Staging Workflow** (`development.yml`)
```yaml
Triggers: push to develop
Actions:
  ✅ Install Flutter & Firebase CLI
  ✅ Run tests (flutter test)
  ✅ Build web (--dart-define=ENVIRONMENT=development)
  ✅ Deploy to fitness-tracker-8d0ae
  ✅ Upload web artifacts
```

#### 🎯 **Pre-Production Workflow** (`preproduction.yml`)
```yaml
Triggers: push to main
Actions:
  ✅ Install Flutter & Firebase CLI
  ✅ Run tests (flutter test)
  ✅ Build web (--dart-define=ENVIRONMENT=development)
  ✅ Deploy to fitness-tracker-8d0ae (overwrites staging)
  ✅ Upload web artifacts
```

#### 🚀 **Production Workflow** (`release.yml`)
```yaml
Triggers: git tags (v*)
Actions:
  ✅ Install Flutter, Java, Firebase CLI
  ✅ Inject production secrets (keystore, google-services.json)
  ✅ Build web (--dart-define=ENVIRONMENT=production)
  ✅ Deploy to fitness-tracker-p2025
  ✅ Build mobile APK/AAB with production keystore
  ✅ Create GitHub release with downloadable files
```

---

## 🔥 Firebase Projects

### Project Configuration

#### **Development Project** (`fitness-tracker-8d0ae`)
- **Purpose**: Development, staging, pre-production
- **Web Hosting**: `fitness-tracker-8d0ae.web.app`
- **Authentication**: Development users
- **Firestore**: Development data
- **OAuth Client**: Development SHA-1 fingerprint
- **Usage**: Free tier, development testing

#### **Production Project** (`fitness-tracker-p2025`)
- **Purpose**: Live production environment
- **Web Hosting**: `fitness-tracker-p2025.web.app`
- **Authentication**: Real users
- **Firestore**: Production data
- **OAuth Client**: Production SHA-1 fingerprint
- **Usage**: Production tier, real user data

### Firebase Configuration Code

#### **Environment Detection** (`lib/config/firebase_config.dart`)
```dart
static FirebaseOptions get currentPlatform {
  const String environment = String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');
  
  switch (environment) {
    case 'production':
      return _productionConfig;  // fitness-tracker-p2025
    case 'development':
    default:
      return _developmentConfig; // fitness-tracker-8d0ae
  }
}
```

---

## 🚀 Quick Start Guide

### For New Features

```bash
# 1. Start new feature
git checkout develop
git pull origin develop
git checkout -b feature/your-feature-name

# 2. Develop and test locally
flutter run
# ... make changes ...
git add .
git commit -m "Add new feature"
git push -u origin feature/your-feature-name

# 3. Check preview deployment
# Visit the preview URL from GitHub Actions

# 4. Create PR to develop
# Go to GitHub and create Pull Request

# 5. After approval and merge, test on staging
# Visit: https://fitness-tracker-8d0ae.web.app
```

### For Production Release

```bash
# 1. Create release PR (develop → main)
git checkout main
git pull origin main
git merge develop
git push origin main

# 2. Test on pre-production
# Visit: https://fitness-tracker-8d0ae.web.app

# 3. Create production release
git tag v1.0.1
git push origin v1.0.1

# 4. Monitor deployment
# Check GitHub Actions for deployment status
# Visit: https://fitness-tracker-p2025.web.app
# Download APK/AAB from GitHub Releases
```

### Branch Management Commands

```bash
# Switch between branches
git checkout develop        # Staging environment
git checkout main          # Pre-production environment
git checkout feature/xyz   # Your feature branch

# Keep branches updated
git checkout develop
git pull origin develop
git checkout main
git pull origin main

# Clean up old feature branches
git branch -d feature/old-feature
git push origin --delete feature/old-feature
```

---

## 🛠️ GitHub Secrets Configuration

### Required Secrets

| **Secret Name** | **Purpose** | **Value Source** |
|-----------------|-------------|------------------|
| `FIREBASE_TOKEN` | Firebase deployments | `firebase login:ci` |
| `GOOGLE_SERVICES_JSON_PROD` | Production Firebase config | Base64 encoded production google-services.json |
| `KEYSTORE_FILE_PROD` | Production app signing | Base64 encoded production-keystore.jks |
| `KEY_PROPERTIES_PROD` | Keystore configuration | Base64 encoded key-production.properties |
| `KEYSTORE_PASSWORD` | Keystore password | Your production keystore password |
| `KEY_PASSWORD` | Key password | Your production key password |
| `KEY_ALIAS` | Key alias | `production` |

### Secret Setup Commands

```bash
# Encode files for GitHub Secrets
base64 -i ~/Downloads/google-services-production.json
base64 -i android/app/production-keystore.jks  
base64 -i android/key-production.properties

# Get Firebase CI token
firebase login:ci
```

---

## 🔧 Local Development

### Environment Setup

```bash
# Install dependencies
flutter pub get

# Run locally (development environment)
flutter run

# Run web locally
flutter run -d chrome

# Run tests
flutter test

# Build for testing
flutter build apk --debug    # Debug APK
flutter build web --release  # Production web build
```

### Testing Different Environments Locally

```bash
# Test with development environment (default)
flutter run

# Test with production environment
flutter run --dart-define=ENVIRONMENT=production
```

---

## 🎯 Testing Strategy

### Test Types by Environment

| **Environment** | **Testing Focus** | **Who Tests** |
|-----------------|-------------------|---------------|
| **Local** | Unit tests, widget tests | Developers |
| **Preview** | Feature functionality | Developers, reviewers |
| **Staging** | Integration testing | Dev team |
| **Pre-Production** | End-to-end testing | QA team |
| **Production** | Smoke testing | DevOps, QA |

### Test Commands

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run tests with coverage
flutter test --coverage

# Integration testing
flutter drive --target=test_driver/app.dart
```

---

## 🐛 Troubleshooting

### Common Issues

#### **1. Preview Deployment Fails**
```bash
# Check GitHub Actions logs
# Common fixes:
flutter clean
flutter pub get
flutter test  # Fix failing tests
```

#### **2. Firebase Deploy Fails**
```bash
# Check Firebase token
firebase login:ci

# Verify project access
firebase projects:list
firebase use fitness-tracker-8d0ae
```

#### **3. Production Build Fails**
```bash
# Check GitHub Secrets are set correctly
# Verify keystore file is accessible
# Check google-services.json is valid
```

#### **4. Branch Out of Sync**
```bash
# Update your branch
git checkout develop
git pull origin develop
git checkout your-feature-branch
git merge develop
```

### Debug Commands

```bash
# Check current branch and status
git status
git branch -v

# Check remote branches
git branch -r

# Check GitHub Actions status
# Visit: https://github.com/YOUR_USERNAME/REPO_NAME/actions

# Check Firebase hosting
firebase hosting:sites:list
```

---

## 📚 Additional Resources

### Documentation Links
- [Flutter Deployment](https://flutter.dev/docs/deployment)
- [Firebase Hosting](https://firebase.google.com/docs/hosting)
- [GitHub Actions](https://docs.github.com/en/actions)
- [Firebase CLI](https://firebase.google.com/docs/cli)

### Workflow Files Location
- `.github/workflows/preview.yml` - Preview deployments
- `.github/workflows/development.yml` - Staging deployments  
- `.github/workflows/preproduction.yml` - Pre-production deployments
- `.github/workflows/release.yml` - Production deployments

### Configuration Files
- `firebase.json` - Firebase project configuration
- `lib/config/firebase_config.dart` - Environment-based Firebase config
- `android/key-production.properties` - Production keystore config (not in repo)

---

## 🎉 Success Metrics

### Deployment Health Check

After each deployment, verify:

✅ **Web Application**
- [ ] App loads without errors
- [ ] Authentication works (Google + Email)
- [ ] Core features functional
- [ ] No console errors

✅ **Mobile Application** (Production only)
- [ ] APK installs successfully
- [ ] Google Sign-In works
- [ ] Data syncs with Firebase
- [ ] Performance acceptable

✅ **Firebase Integration**
- [ ] Firestore data reads/writes
- [ ] Authentication flow works
- [ ] Hosting serves correctly
- [ ] Analytics tracking

---

**🎯 Happy Coding!** This workflow ensures safe, reliable deployments from development to production.