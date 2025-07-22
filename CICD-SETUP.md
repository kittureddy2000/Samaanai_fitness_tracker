# Google Cloud Build Setup Guide

## 🚀 Complete Setup Steps

### 1. **Enable Required APIs**
```bash
# Enable Cloud Build API
gcloud services enable cloudbuild.googleapis.com

# Enable Cloud Storage (for artifacts)
gcloud services enable storage.googleapis.com

# Connect to your Firebase projects
gcloud services enable firebase.googleapis.com
```

### 2. **Create Storage Buckets for Build Artifacts**
```bash
# Staging artifacts
gsutil mb gs://fitness-tracker-build-artifacts

# Production artifacts  
gsutil mb gs://fitness-tracker-prod-artifacts
```

### 3. **Set up Cloud Build GitHub Connection**
1. Go to [Cloud Build Console](https://console.cloud.google.com/cloud-build/triggers)
2. Click "Connect Repository"
3. Select "GitHub" → "Continue" 
4. Authenticate with GitHub
5. Select your repository: `kittureddy2000/Samaanai_fitness_tracker`

### 4. **Create Build Triggers**

#### Staging Trigger (Automatic):
- **Name**: `deploy-staging`
- **Event**: Push to branch
- **Branch**: `^main$`
- **Configuration**: Cloud Build configuration file
- **Location**: `cloudbuild.yaml`

#### Production Trigger (Manual):
- **Name**: `deploy-production`  
- **Event**: Manual invocation
- **Branch**: `^main$`
- **Configuration**: Cloud Build configuration file
- **Location**: `cloudbuild-production.yaml`

### 5. **Grant Cloud Build Permissions**
```bash
# Get your Cloud Build service account
PROJECT_NUMBER=$(gcloud projects describe fitness-tracker-8d0ae --format="value(projectNumber)")
CLOUD_BUILD_SA="${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com"

# Grant Firebase permissions to both projects
gcloud projects add-iam-policy-binding fitness-tracker-8d0ae \
    --member="serviceAccount:${CLOUD_BUILD_SA}" \
    --role="roles/firebase.admin"

gcloud projects add-iam-policy-binding fitness-tracker-p2025 \
    --member="serviceAccount:${CLOUD_BUILD_SA}" \
    --role="roles/firebase.admin"
```

---

## Option 2: GitHub Actions

### Benefits:
- ✅ Easier setup (code already on GitHub)
- ✅ 2000 minutes/month free
- ✅ Familiar to most developers

### Drawbacks:
- ❌ Need Firebase service account setup
- ❌ Less integrated with Google services

### Cost:
- **Free**: 2000 minutes/month
- **Paid**: $0.008/minute after free tier

---

## Recommendation

**Use Google Cloud Build** because:
1. You're already using Firebase/Google services
2. Better integration and security
3. More free build time (120 min/day vs 2000 min/month)
4. Google optimized for Flutter builds

---

## Manual Deployment (Current)

If you prefer to keep manual control:
```bash
# Development
git push origin main

# Production deployment (manual)
firebase use production
flutter build web --release
firebase deploy
```