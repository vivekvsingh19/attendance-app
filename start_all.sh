#!/bin/bash

# Class Attendance App - Quick Start Script

echo "🚀 Starting Class Attendance App..."

# Function to check if a port is in use
check_port() {
    if lsof -Pi :$1 -sTCP:LISTEN -t >/dev/null ; then
        echo "Port $1 is already in use"
        return 0
    else
        return 1
    fi
}

# Kill any existing backend processes
echo "🔄 Stopping existing backend processes..."
pkill -f "python.*main.py" 2>/dev/null || true

# Start backend
echo "🌐 Starting backend server..."
cd backend
source attendance_env/bin/activate
python main.py &
BACKEND_PID=$!

# Wait for backend to start
echo "⏳ Waiting for backend to start..."
sleep 3

# Check if backend is running
if check_port 8000; then
    echo "✅ Backend running on http://localhost:8000"
else
    echo "❌ Backend failed to start"
    exit 1
fi

# Move back to project root
cd ..

# Test backend health
echo "🔍 Testing backend health..."
if curl -s http://localhost:8000/health > /dev/null; then
    echo "✅ Backend health check passed"
else
    echo "❌ Backend health check failed"
    kill $BACKEND_PID 2>/dev/null
    exit 1
fi

# Test login endpoint
echo "🔐 Testing login endpoint..."
LOGIN_RESPONSE=$(curl -s -X POST "http://localhost:8000/login-and-fetch-attendance" \
    -H "Content-Type: application/json" \
    -d '{"college_id": "0827CS211178", "password": "Vivek@123"}')

if echo "$LOGIN_RESPONSE" | grep -q '"success":true'; then
    echo "✅ Login endpoint working"
    echo "📊 Sample response: $(echo "$LOGIN_RESPONSE" | jq -r '.message')"
else
    echo "❌ Login endpoint failed"
    echo "Response: $LOGIN_RESPONSE"
    kill $BACKEND_PID 2>/dev/null
    exit 1
fi

echo ""
echo "🎉 Backend is ready!"
echo ""
echo "📱 Available Flutter targets:"
flutter devices 2>/dev/null | grep -E "•|Found"

echo ""
echo "🚀 Choose your platform:"
echo "1. Run on Android: flutter run -d [android-device-id]"
echo "2. Run on Chrome: flutter run -d chrome"
echo "3. Run on Linux: flutter run -d linux (may have build issues)"

echo ""
echo "💡 Or run manually:"
echo "   flutter run"

echo ""
echo "🔄 To stop backend: kill $BACKEND_PID"
echo "📋 Backend logs: Check terminal output above"
echo "🌐 Backend URL: http://localhost:8000"

# Keep script running so backend stays alive
echo ""
echo "⏳ Backend running in background (PID: $BACKEND_PID)"
echo "   Press Ctrl+C to stop all services"

# Trap Ctrl+C to clean up
trap "echo '🛑 Stopping backend...'; kill $BACKEND_PID 2>/dev/null; exit" INT

# Wait for user to stop
wait
