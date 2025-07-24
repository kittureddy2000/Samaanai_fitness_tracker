# How to Download Android APK from Cloud Build Artifacts

## 📋 Prerequisites
- Latest build must be **SUCCESS** status
- Build must have completed the Android APK generation step

## 🌐 Method 1: Google Cloud Console (Web Interface)

### Step 1: Go to Cloud Build History
1. Open: [Cloud Build Console](https://console.cloud.google.com/cloud-build/builds?project=fitness-tracker-8d0ae)
2. You'll see a list of recent builds

### Step 2: Find Successful Build
1. Look for a build with **green checkmark** and status **"Success"**
2. Click on the build ID (e.g., `8e1596a6-2d25-4d1a-8640-45a437aa8258`)

### Step 3: Navigate to Artifacts
1. In the build details page, look for the **"Artifacts"** section
2. You should see:
   ```
   📁 gs://fitness-tracker-8d0ae_cloudbuild/artifacts/
   └── build/app/outputs/flutter-apk/app-debug.apk
   ```

### Step 4: Download APK
1. Click on `app-debug.apk`
2. Click **"Download"** button
3. Save the file as `fitness-tracker-debug.apk`

## 💻 Method 2: Command Line (gcloud)

### Step 1: Find Latest Successful Build
```bash
gcloud builds list --project=fitness-tracker-8d0ae --limit=5 --filter="status=SUCCESS"
```

### Step 2: Copy Build ID
Copy the ID of the latest successful build (first column)

### Step 3: Download APK
```bash
# Replace BUILD_ID with actual build ID
gsutil cp gs://fitness-tracker-8d0ae_cloudbuild/artifacts/build/app/outputs/flutter-apk/app-debug.apk ./fitness-tracker-debug.apk
```

### Alternative: Direct Download
```bash
# Download from latest successful build artifacts
gsutil ls gs://fitness-tracker-8d0ae_cloudbuild/artifacts/
gsutil cp gs://fitness-tracker-8d0ae_cloudbuild/artifacts/build/app/outputs/flutter-apk/app-debug.apk ./fitness-tracker-debug.apk
```

## 📱 Install APK on Phone

### Method 1: ADB (if phone connected)
```bash
adb install fitness-tracker-debug.apk
```

### Method 2: Manual Transfer
1. Transfer APK to phone (email, USB, cloud drive)
2. Enable **"Install from Unknown Sources"** in phone settings
3. Use file manager to find and tap the APK
4. Follow installation prompts

## 🔍 Troubleshooting

### No Artifacts Section?
- Build may have failed before creating artifacts
- Check build logs for errors
- Ensure build status is **SUCCESS**

### APK Not Found?
- Build may have failed during Android build step
- Check build logs for `flutter build apk --debug` errors
- Try rebuilding by pushing a small change to GitHub

### Download Permission Denied?
```bash
# Authenticate if needed
gcloud auth login
gcloud config set project fitness-tracker-8d0ae
```

## 📊 Current Build Status

Check current builds:
```bash
gcloud builds list --project=fitness-tracker-8d0ae --limit=3
```

**Latest Build ID:** `8e1596a6-2d25-4d1a-8640-45a437aa8258` (currently building)

Once this build shows **SUCCESS**, you can download the APK using either method above!