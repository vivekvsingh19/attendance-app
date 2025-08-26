# 🕐 Scheduled Backend Deployment Guide

Your attendance backend can now run on a schedule to save costs! Here are your options:

## 📊 Cost Comparison

| Option | Cost | Uptime | Setup Difficulty |
|--------|------|--------|------------------|
| Current Heroku 24/7 | $7/month | 100% | Easy |
| **Scheduled Heroku** | $2.30/month | 33% (8hrs/day) | Medium |
| **Railway Scheduled** | Free | 33% | Easy |
| **Vercel Serverless** | Free | On-demand | Easy |

## 🎯 Option 1: Heroku with Sleep Mode (Recommended)

### Deploy with Built-in Sleep Mode:
```bash
# 1. Enable sleep mode
heroku config:set SLEEP_MODE_ENABLED=true -a attendance-backend-api

# 2. Deploy updated code
git add .
git commit -m "Add scheduled sleep mode"
git push heroku main

# 3. Your app will now automatically sleep outside of:
#    - 7:00 AM - 12:00 PM IST
#    - 4:00 PM - 7:00 PM IST
```

**Benefits:**
- ✅ Still runs 24/7 but rejects requests during inactive hours
- ✅ Saves server resources
- ✅ Immediate response during active hours
- ❌ Still charges $7/month

### Deploy with Auto-Scaling (Maximum Savings):
```bash
# 1. Install dependencies
pip install pytz

# 2. Add Heroku Scheduler
heroku addons:create scheduler:standard -a attendance-backend-api

# 3. Get your Heroku API token from: https://dashboard.heroku.com/account
heroku config:set HEROKU_API_TOKEN=your_token_here -a attendance-backend-api

# 4. Add scheduled jobs in Heroku Dashboard:
heroku addons:open scheduler -a attendance-backend-api

# Add this job to run every hour:
python backend/scheduler.py
```

**Benefits:**
- ✅ Reduces cost to ~$2.30/month (66% savings!)
- ✅ Automatically scales dynos up/down
- ❌ 30-second cold start when scaling up

## 🚀 Option 2: Railway.app (Free!)

```bash
# 1. Go to railway.app and connect your GitHub repo
# 2. Your railway.json is already configured
# 3. Deploy - completely free for your usage!
```

## ⚡ Option 3: Vercel Serverless (Free + Instant)

```bash
# 1. Install Vercel CLI
npm install -g vercel

# 2. Deploy
vercel

# 3. Your app will be completely serverless and free!
```

## 📱 Update Your Flutter App

You'll need to update your Flutter app to handle sleep mode responses:

```dart
// Add this to your API service
if (response.statusCode == 503) {
  // Service is sleeping
  final data = json.decode(response.body);
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Service Unavailable'),
      content: Text('Attendance service is active during:\n7:00 AM - 12:00 PM\n4:00 PM - 7:00 PM (IST)\n\nNext active: ${data['details']['next_active_at']}'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('OK'),
        ),
      ],
    ),
  );
}
```

## 🔧 Test Your Schedule

```bash
# Test health endpoint
curl https://your-app.herokuapp.com/health

# Response during active hours:
{
  "status": "healthy",
  "service_active": true,
  "sleep_mode_enabled": true,
  "current_time_ist": "10:30 AM",
  "active_hours": ["7:00 AM - 12:00 PM", "4:00 PM - 7:00 PM"]
}

# Response during inactive hours:
{
  "success": false,
  "message": "Service is currently in sleep mode",
  "details": {
    "next_active_at": "4:00 PM"
  }
}
```

## 🎯 Recommended Approach:

**For immediate cost savings:** Use Option 1 (Sleep Mode) - Deploy today and save resources immediately.

**For maximum savings:** Use Option 2 (Railway.app) - Move to completely free hosting.

**For production apps:** Use Option 3 (Vercel) - Serverless with instant scaling.

Which option would you like to implement first?
