# Production Firebase Setup Fix

## Problem
Google Sign-In error: `Authorization Error - The OAuth client was deleted. Error 401: deleted_client`

## Root Cause
The production Firebase project (`fitness-tracker-p2025`) is not properly configured with:
1. Android app with correct package name and SHA-1 certificate
2. Google Sign-in authentication provider enabled
3. Correct OAuth client IDs

## Current Status
- ✅ Staging project (`fitness-tracker-8d0ae`) is perfectly configured
- ❌ Production project (`fitness-tracker-p2025`) needs setup
- ✅ Web template fixed to use dynamic client ID
- ✅ Release workflow correctly configured

## Required Actions

### 1. Add Android App to Production Firebase Project

**Step-by-step process:**

1. **Open Firebase Console**
   - Go to https://console.firebase.google.com/project/fitness-tracker-p2025
   - Make sure you're logged in with `kittureddy2000@gmail.com`

2. **Add Android App**
   - On the project overview page, look for the "Get started by adding Firebase to your app" section
   - Click the **Android icon** (robot icon) 
   - If you don't see this, click the **"⚙️ Project settings"** gear icon → **"Your apps"** section → **"Add app"** → **Android**

3. **Register Android App Form**
   - **Android package name**: `com.fitnesstracker.fitness_tracker`
   - **App nickname (optional)**: `Fitness Tracker Production Android`
   - **Debug signing certificate SHA-1**: `f5:99:a8:35:df:89:c5:02:48:b4:d7:bf:60:7d:d9:62:12:f1:58:3d`
   - Click **"Register app"**

4. **Download Configuration File**
   - Click **"Download google-services.json"**
   - Save this file (you'll need it for GitHub secrets)
   - Click **"Next"** → **"Next"** → **"Continue to console"**

### 2. Enable Google Sign-in Authentication

**Step-by-step process:**

1. **Navigate to Authentication**
   - In the left sidebar, click **"Authentication"**
   - Click on **"Sign-in method"** tab

2. **Enable Google Provider**
   - Find **"Google"** in the providers list
   - Click on **"Google"** row
   - Toggle **"Enable"** to ON
   - **Project support email**: Select `kittureddy2000@gmail.com` from dropdown
   - Click **"Save"**

3. **Get OAuth Client IDs** (Important!)
   - After saving, you'll see **"Web SDK configuration"** section
   - **Copy the Web client ID** - it looks like: `934862983900-xxxxxxxxxxxxx.apps.googleusercontent.com`
   - Keep this copied - you'll need it for GitHub secrets

### 3. Add Web App (if needed)

1. **Check if Web App Exists**
   - Go to **Project settings** ⚙️ → **"Your apps"** section
   - Look for a Web app entry

2. **If No Web App Exists:**
   - Click **"Add app"** → **Web** (</> icon)
   - **App nickname**: `Fitness Tracker Production Web`
   - **Also set up Firebase Hosting**: ✅ Check this
   - **Choose existing site**: `fitness-tracker-p2025.web.app`
   - Click **"Register app"**

### 4. Update GitHub Repository Secrets

**Step-by-step process:**

1. **Navigate to Repository Secrets**
   - Go to https://github.com/krishnayadamakanti/Samaanai_fitness_tracker
   - Click **"Settings"** tab
   - In left sidebar, click **"Secrets and variables"** → **"Actions"**

2. **Update GOOGLE_CLIENT_ID_PRODUCTION Secret**
   - Find **"GOOGLE_CLIENT_ID_PRODUCTION"** in the list
   - Click **"Update"** (pencil icon)
   - **Value**: Paste the Web client ID you copied from step 2.3 above
   - Example: `934862983900-abcdef1234567890abcdef1234567890.apps.googleusercontent.com`
   - Click **"Update secret"**

3. **Update GOOGLE_SERVICES_PROD Secret**
   - Find **"GOOGLE_SERVICES_PROD"** in the list
   - Click **"Update"** (pencil icon)
   - **Encode the google-services.json file:**
     ```bash
     # On your computer, navigate to where you downloaded google-services.json
     cat google-services.json | base64
     ```
   - **Value**: Paste the entire base64 encoded string (it will be very long)
   - Click **"Update secret"**

### 5. Verification Steps

1. **Test the Setup**
   - Go to GitHub Actions: https://github.com/krishnayadamakanti/Samaanai_fitness_tracker/actions
   - Click **"Production Release"** workflow
   - Click **"Run workflow"** button
   - Select `main` branch
   - Click **"Run workflow"**

2. **Check Production Website**
   - Wait for workflow to complete (about 10-15 minutes)
   - Visit: https://fitness-tracker-p2025.web.app
   - Try Google Sign-in - it should work without the OAuth error

### 3. OAuth Client Configuration
The production project will automatically create OAuth clients with these patterns:
- Android: `934862983900-[unique-id].apps.googleusercontent.com`
- Web: `934862983900-[unique-id].apps.googleusercontent.com`

### 4. Verification
After setup, test the production build:
```bash
gh workflow run release.yml
```

## Files Modified
- `web/index.html` - Fixed to use `{{GOOGLE_CLIENT_ID}}` template
- `production-google-services.json` - Template for reference

## Next Steps
1. Complete Firebase Console setup for production project
2. Update GitHub secrets with real OAuth client IDs  
3. Test production release workflow
4. Remove template file: `production-google-services.json`