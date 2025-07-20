# Setup OAuth Client ID for Google Sign-In

## 🚨 **Current Issue**
You're getting "The OAuth client was not found" because the OAuth client ID is not properly configured.

## 🔧 **Step-by-Step Fix**

### **1. Go to Google Cloud Console**

1. Visit: https://console.cloud.google.com/apis/credentials?project=fitness-tracker-8d0ae
2. Make sure you're in the correct project: `fitness-tracker-8d0ae`

### **2. Create New OAuth Client ID**

1. Click **"Create Credentials"** → **"OAuth client ID"**
2. Choose **"Web application"**
3. Name: **"Fitness Tracker Web Client"**
4. Add these **Authorized JavaScript origins**:
   ```
   https://fitness-tracker-8d0ae.web.app
   https://fitness-tracker-8d0ae.firebaseapp.com
   http://localhost:8081
   http://localhost:3000
   http://localhost:8080
   ```
5. Add these **Authorized redirect URIs**:
   ```
   https://fitness-tracker-8d0ae.web.app/__/auth/handler
   https://fitness-tracker-8d0ae.firebaseapp.com/__/auth/handler
   http://localhost:8081/__/auth/handler
   http://localhost:3000/__/auth/handler
   http://localhost:8080/__/auth/handler
   ```
6. Click **"Create"**

### **3. Copy the Client ID**

After creation, you'll get a Client ID like: `123456789-abcdefghijklmnop.apps.googleusercontent.com`

### **4. Update Firebase Configuration**

1. Go to: https://console.firebase.google.com/project/fitness-tracker-8d0ae/overview
2. Click **"Project Settings"** (gear icon)
3. Scroll down to **"Your apps"** section
4. Click on your web app (should be named something like "fitness-tracker")
5. Click **"Add app"** → **"Web"** if you don't see a web app
6. Copy the new Client ID and update the configuration

### **5. Alternative: Update Existing OAuth Client**

If you already have an OAuth client:

1. Go to Google Cloud Console → Credentials
2. Find your existing OAuth 2.0 Client ID
3. Click on it to edit
4. Add the authorized origins and redirect URIs above
5. Click **"Save"**

## 🧪 **Test the Fix**

1. Wait 5-10 minutes for changes to propagate
2. Clear browser cache
3. Try Google Sign-In again at: http://localhost:8081

## 🔍 **Troubleshooting**

### **If still getting "OAuth client not found":**

1. **Check Project Linking**:
   - Go to Firebase Console → Project Settings
   - Verify the Google Cloud project is correctly linked
   - Should show: `fitness-tracker-8d0ae`

2. **Check OAuth Consent Screen**:
   - Go to Google Cloud Console → OAuth consent screen
   - Make sure it's configured for your app

3. **Verify Client ID**:
   - The Client ID in your Firebase config should match the one in Google Cloud Console

## 📞 **Need Help?**

If you're still having issues:
1. Check that you're in the correct Google Cloud project
2. Verify all URLs are added correctly (no typos)
3. Wait for changes to propagate
4. Try in incognito mode 