# 🎓 Class Attendance App

A Flutter mobile application that helps students track their college attendance by fetching real-time data from their college portal via web scraping.

## ✨ Features

- **Secure Login**: Login with your college ID and password
- **Real-time Data**: Fetch attendance data directly from the college portal
- **Beautiful UI**: Modern, intuitive interface with Material Design
- **Attendance Overview**: View overall attendance statistics
- **Subject-wise Details**: Detailed attendance for each subject
- **Low Attendance Alerts**: Get notified when attendance drops below 75%
- **Offline Support**: View cached data when offline

## 🏗️ Architecture

The app uses a two-tier architecture:

1. **Python Backend (FastAPI)**: Handles web scraping and data processing
2. **Flutter Frontend**: Provides the mobile interface

### Backend (Python + FastAPI)
- Web scraping using `requests` and `BeautifulSoup`
- Handles ASP.NET login with ViewState management
- Secure session management
- RESTful API endpoints

### Frontend (Flutter)
- State management using Provider
- Responsive UI with Material Design
- Local storage for caching
- HTTP client for API communication

## 🚀 Setup Instructions

### Prerequisites
- Flutter SDK (>=3.7.2)
- Python 3.8+
- pip (Python package manager)

### Backend Setup

1. **Install Python dependencies:**
```bash
cd backend
pip install -r requirements.txt
```

2. **Start the backend server:**
```bash
python main.py
```

Or use the provided script:
```bash
./start_backend.sh
```

The API will be available at `http://localhost:8000`

### Frontend Setup

1. **Install Flutter dependencies:**
```bash
flutter pub get
```

2. **Run the app:**
```bash
flutter run
```

## 📱 App Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   ├── attendance.dart       # Attendance data models
│   ├── subject.dart          # Subject model
│   └── timetable.dart        # Timetable model
├── providers/
│   └── attendance_provider.dart  # State management
├── screens/
│   ├── login_screen.dart     # Login interface
│   ├── dashboard_screen.dart # Main dashboard
│   └── mark_attendance_screen.dart  # Manual attendance
├── services/
│   └── attendance_service.dart  # API communication
└── widgets/
    ├── stats_card.dart       # Statistics display
    └── subject_card.dart     # Subject information
```

## 🔌 API Endpoints

### POST `/login-and-fetch-attendance`
Login and fetch attendance data.

**Request:**
```json
{
  "college_id": "your_college_id",
  "password": "your_password"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Attendance data fetched successfully",
  "data": {
    "Physics": {
      "total": 30,
      "attended": 27,
      "percentage": 90.0
    },
    "Mathematics": {
      "total": 28,
      "attended": 20,
      "percentage": 71.43
    }
  }
}
```

### GET `/health`
Check API health status.

## 🎯 Target Website

The app is designed to work with AccSoft-based college portals, specifically:
- **Portal URL**: `https://portal.lnct.ac.in/Accsoft2/studentlogin.aspx`
- **Login Method**: ASP.NET forms authentication
- **Session Management**: Cookies and ViewState

## 🔧 Configuration

### Backend Configuration
- **Server Port**: 8000 (configurable in `main.py`)
- **CORS**: Enabled for all origins (configure for production)
- **Timeout**: 30 seconds for requests

### Frontend Configuration
- **API Base URL**: `http://localhost:8000` (update for production)
- **Theme**: Material Design with Indigo primary color

## 📊 Features Breakdown

### Dashboard Screen
- Overall attendance percentage
- Subject count and low attendance alerts
- Beautiful statistics cards
- Subject-wise attendance list

### Login Screen
- Secure credential input
- Form validation
- Loading states and error handling
- Information about the app

### Subject Details
- Individual subject statistics
- Attendance trends
- Visual progress indicators
- Low attendance warnings

## 🛠️ Development

### Running in Development Mode

1. **Start the backend:**
```bash
cd backend
python main.py
```

2. **Start the Flutter app:**
```bash
flutter run
```

### Building for Production

1. **Build the Flutter app:**
```bash
flutter build apk --release
```

2. **Deploy the backend:**
```bash
# Using Docker (recommended)
docker build -t attendance-backend .
docker run -p 8000:8000 attendance-backend
```

## 🔒 Security Features

- **Secure Storage**: Sensitive data encrypted locally
- **Session Management**: Proper session handling
- **Input Validation**: All inputs validated on both frontend and backend
- **Error Handling**: Comprehensive error handling and user feedback

## 🎨 UI/UX Features

- **Modern Design**: Clean, intuitive interface
- **Responsive Layout**: Works on all screen sizes
- **Loading States**: Smooth loading animations
- **Error States**: Clear error messages and recovery options
- **Color Coding**: Visual indicators for attendance status

## 📝 Future Enhancements

- [ ] Push notifications for low attendance
- [ ] Timetable integration
- [ ] Attendance predictions
- [ ] Multiple college support
- [ ] Dark mode support
- [ ] Biometric authentication

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## ⚠️ Disclaimer

This app is for educational purposes only. Please ensure you have permission to access your college portal and comply with your institution's terms of service.

## 📞 Support

For issues or questions:
- Create an issue on GitHub
- Contact the development team
- Check the documentation

---

Made with ❤️ for students who want to stay on top of their attendance!
