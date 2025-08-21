#!/bin/bash

echo "🚀 Starting Heroku Deployment for Attendance Backend"

# Step 1: Login to Heroku
echo "📝 Please login to Heroku..."
heroku login

# Step 2: Create Heroku app
echo "🆕 Creating Heroku app..."
read -p "Enter your desired app name (or press enter for auto-generated): " APP_NAME

if [ -z "$APP_NAME" ]; then
    heroku create
else
    heroku create $APP_NAME
fi

# Get the app name and URL
APP_INFO=$(heroku apps:info --json)
APP_NAME=$(echo $APP_INFO | python3 -c "import sys, json; print(json.load(sys.stdin)['name'])")
APP_URL="https://${APP_NAME}.herokuapp.com"

echo "✅ App created: $APP_NAME"
echo "🌐 URL will be: $APP_URL"

# Step 3: Add files to git
echo "📦 Adding files to git..."
git add .
git commit -m "Prepare for Heroku deployment"

# Step 4: Deploy to Heroku
echo "🚀 Deploying to Heroku..."
git push heroku main

# Step 5: Test the deployment
echo "🧪 Testing deployment..."
sleep 10
curl -s "$APP_URL/health" && echo "✅ Health check passed!" || echo "❌ Health check failed"

echo "🎉 Deployment complete!"
echo "📱 Your API is now available at: $APP_URL"
echo "🔧 To update the Flutter app, change the base URL to: $APP_URL"

# Step 6: Show logs
echo "📋 Recent logs:"
heroku logs --tail --num 20
