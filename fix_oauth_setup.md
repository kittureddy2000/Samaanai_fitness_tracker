# Fix Google Sign-In OAuth Client Configuration

## 🔧 **Step-by-Step Fix**

### **1. Firebase Console Configuration**

1. Go to: https://console.firebase.google.com/project/fitness-tracker-8d0ae/overview
2. Click "Authentication" → "Sign-in method"
3. Click "Google" provider
4. **Enable Google Sign-In** if not already enabled
5. Add these domains to "Authorized domains":
   - `fitness-tracker-8d0ae.web.app`
   - `fitness-tracker-8d0ae.firebaseapp.com`
   - `localhost` (for local development)

### **2. Google Cloud Console Configuration**

1. Go to: https://console.cloud.google.com/apis/credentials?project=fitness-tracker-8d0ae
2. Find your OAuth 2.0 Client ID (should be named something like "Web client")
3. Click on it to edit
4. Add these to "Authorized JavaScript origins":
   ```
   https://fitness-tracker-8d0ae.web.app
   https://fitness-tracker-8d0ae.firebaseapp.com
   http://localhost:8081
   http://localhost:3000
   http://localhost:8080
   ```
5. Add these to "Authorized redirect URIs":
   ```
   https://fitness-tracker-8d0ae.web.app/__/auth/handler
   https://fitness-tracker-8d0ae.firebaseapp.com/__/auth/handler
   http://localhost:8081/__/auth/handler
   http://localhost:3000/__/auth/handler
   http://localhost:8080/__/auth/handler
   ```

### **3. Alternative: Create New OAuth Client**

If the above doesn't work:

1. Go to Google Cloud Console
2. Click "Create Credentials" → "OAuth client ID"
3. Choose "Web application"
4. Name: "Fitness Tracker Web"
5. Add the authorized origins and redirect URIs above
6. Copy the new Client ID and update Firebase

### **4. Test the Fix**

1. Wait 5-10 minutes for changes to propagate
2. Visit: https://fitness-tracker-8d0ae.web.app
3. Try Google Sign-In again

## 🚨 **Common Issues & Solutions**

### **Error 401: invalid_client**
- **Cause**: OAuth client not found or not configured
- **Solution**: Check that the OAuth client ID in Firebase matches the one in Google Cloud Console

### **Error 403: access_denied**
- **Cause**: Domain not authorized
- **Solution**: Add your domain to authorized origins in Google Cloud Console

### **Error 400: redirect_uri_mismatch**
- **Cause**: Redirect URI not configured
- **Solution**: Add the correct redirect URIs to Google Cloud Console

### **Error: "The OAuth client was not found"**
- **Cause**: Firebase project not properly linked to Google Cloud project
- **Solution**: 
  1. Go to Firebase Console → Project Settings
  2. Check that the Google Cloud project is correctly linked
  3. If not, click "Change" and select the correct project

## 🔍 **Troubleshooting Steps**

1. **Verify Firebase Configuration**:
   - Check that your `firebase.json` has the correct project ID
   - Ensure Firebase CLI is logged in: `firebase login`

2. **Check Google Cloud Project**:
   - Make sure you're in the correct Google Cloud project
   - Verify that the OAuth consent screen is configured

3. **Test Local Development**:
   - Run: `flutter run -d chrome --web-port=8081`
   - Try Google Sign-In locally first

4. **Clear Browser Cache**:
   - Clear browser cache and cookies
   - Try in incognito/private mode

## 📞 **Need Help?**

If you're still having issues:
1. Check that all domains are added correctly
2. Wait for changes to propagate (can take up to 10 minutes)
3. Clear browser cache and try again
4. Check browser console for detailed error messages
5. Try the app in an incognito window

## 🚀 **Quick Test**

After making changes:
1. Wait 5-10 minutes
2. Visit: https://fitness-tracker-8d0ae.web.app
3. Click "Sign in with Google"
4. If it works, the OAuth configuration is correct! 