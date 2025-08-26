#!/bin/bash
# Deploy Heroku Scheduler Script

# Set your Heroku app name
HEROKU_APP="attendance-backend-api"

echo "Setting up Heroku Scheduler..."

# Add Heroku Scheduler add-on (free)
heroku addons:create scheduler:standard -a $HEROKU_APP

# Set environment variables
heroku config:set HEROKU_APP_NAME=$HEROKU_APP -a $HEROKU_APP

echo ""
echo "🎯 Manual Setup Required:"
echo "1. Get your Heroku API token from: https://dashboard.heroku.com/account"
echo "2. Set it: heroku config:set HEROKU_API_TOKEN=your_token_here -a $HEROKU_APP"
echo "3. Add scheduled jobs in Heroku Dashboard:"
echo "   - Job 1: python backend/scheduler.py (every hour)"
echo ""
echo "Or use this command to add the scheduler job:"
echo "heroku addons:open scheduler -a $HEROKU_APP"
