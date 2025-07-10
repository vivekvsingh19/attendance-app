#!/bin/bash

echo "🎓 Class Attendance App - Complete Setup"
echo "========================================"

# Check if backend is running
echo "Checking backend server..."
if curl -s "http://localhost:8000/health" > /dev/null; then
    echo "✅ Backend server is running"
else
    echo "⚠️  Backend server not running. Starting it now..."
    cd backend
    source attendance_env/bin/activate
    python main.py &
    BACKEND_PID=$!
    echo "Backend started with PID: $BACKEND_PID"
    cd ..
    sleep 3
fi

echo ""
echo "🚀 Your Class Attendance App is ready!"
echo ""
echo "Features available:"
echo "✅ Secure login with college credentials"
echo "✅ Real-time attendance data from college portal"
echo "✅ Beautiful dashboard with statistics"
echo "✅ Test mode with dummy data (toggle in app)"
echo "✅ Connection testing feature"
echo ""
echo "To use the app:"
echo "1. Run: flutter run"
echo "2. Enable 'Test Mode' for demo data"
echo "3. Or use real college portal credentials"
echo ""
echo "Troubleshooting:"
echo "- Use 'Test Connection' button to check backend"
echo "- Enable 'Test Mode' if network issues persist"
echo "- Backend API: http://localhost:8000"
echo ""
echo "Happy tracking! 📚✨"
