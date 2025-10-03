# 🌐 Enhanced Server Fallback System

Your attendance app now has a robust fallback system that automatically switches between servers!

## 🎯 How It Works

1. **Primary**: Heroku cloud server (always tried first)
2. **Fallback**: Your local PC server (when Heroku is down)
3. **Backup**: Android emulator server (for development)

## 🚀 Quick Start

### Manual Control:
```bash
# Start fallback server when needed
./start_fallback_server.sh start

# Stop fallback server
./start_fallback_server.sh stop

# Check status of both servers
./start_fallback_server.sh status

# Auto mode (recommended) - starts local server only if Heroku is down
./start_fallback_server.sh auto
```

### Automatic Monitoring:
```bash
# Run monitoring script (checks every time you run it)
./monitor_servers.sh

# To automate this, add to crontab (runs every 5 minutes):
crontab -e
# Add this line:
*/5 * * * * /home/vivek-singh/classattendence/monitor_servers.sh
```

## 📱 App Behavior

Your Flutter app will now:

- ✅ **Try Heroku first** (8 second timeout)
- ✅ **Fallback to local PC** (3 second timeout) 
- ✅ **Last resort: emulator** (2 second timeout)
- ✅ **Cache working server** for 5 minutes (faster subsequent requests)
- ✅ **Show status messages** in console/logs

## 🔧 Configuration

### Update your local server IP:
Edit `/lib/services/attendance_service.dart` line 8:
```dart
static const String _fallbackBaseUrl = 'http://YOUR_PC_IP:5000';
```

### Get your PC IP:
```bash
# On Linux:
ip route get 1.1.1.1 | awk '{print $7}'

# Or:
hostname -I | awk '{print $1}'
```

## 🎉 Benefits

- **Zero downtime**: If Heroku fails, local server takes over
- **Faster response**: Uses cached server info
- **Smart switching**: Only runs local server when needed
- **Easy monitoring**: Simple scripts to manage everything
- **Cost effective**: Reduces Heroku usage when possible

## 📋 Logs & Monitoring

- **App logs**: Shows which server is being used
- **Server logs**: `backend/server.log`
- **Monitor logs**: `server_monitor.log`

## 🛡️ Best Practices

1. Keep your local backend environment ready
2. Run monitoring script regularly
3. Check logs periodically
4. Test fallback occasionally

Your system is now bulletproof! 🚀
