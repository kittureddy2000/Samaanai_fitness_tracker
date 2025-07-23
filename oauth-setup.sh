#!/bin/bash

# OAuth Setup Script for Firebase Project
PROJECT_ID="fitness-tracker-8d0ae"
DOMAIN="fitness-tracker-8d0ae.web.app"
ALT_DOMAIN="fitness-tracker-8d0ae.firebaseapp.com"

echo "🔧 Setting up OAuth for project: $PROJECT_ID"

# Set the project
gcloud config set project $PROJECT_ID

echo "📋 Checking existing OAuth clients..."
gcloud auth application-default oauth-clients list

echo ""
echo "🌐 Required OAuth Configuration:"
echo "Authorized JavaScript origins:"
echo "  - https://$DOMAIN"
echo "  - https://$ALT_DOMAIN"
echo ""
echo "Authorized redirect URIs:"
echo "  - https://$DOMAIN/__/auth/handler"
echo "  - https://$ALT_DOMAIN/__/auth/handler"
echo ""
echo "🔗 Manual setup required at:"
echo "https://console.cloud.google.com/apis/credentials?project=$PROJECT_ID"