class AppConfig {
  // Server Configuration
  static const String herokuUrl = 'https://attendance-backend-api-a50f28666a6d.herokuapp.com'; // Your deployed Heroku app
  static const String localUrl = 'http://localhost:8000';
  static const String networkUrl = 'http://192.168.1.9:8000'; // Update to your local IP
  static const String emulatorUrl = 'http://10.0.2.2:8000';
  
  // Cache Configuration
  static const Duration clientCacheTimeout = Duration(hours: 6);
  static const Duration requestTimeout = Duration(seconds: 15);
  
  // App Settings
  static const String appName = 'UPASTHIT';
  static const String version = '1.2.0';
  
  // Feature Flags
  static const bool enableCaching = true;
  static const bool enableOfflineMode = true;
  static const bool enableDebugLogs = false;
  
  // Server Priority (first working server is used)
  static const List<String> serverUrls = [
    herokuUrl,    // Primary: Heroku with 6-hour caching
    networkUrl,   // Fallback: Local network
    emulatorUrl,  // Fallback: Android emulator
    localUrl,     // Fallback: Localhost
  ];
  
  // Performance Settings
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  
  // UI Settings
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const double defaultPadding = 16.0;
  
  // Attendance Settings
  static const double defaultAttendanceThreshold = 75.0;
  static const int lowAttendanceWarning = 70;
}
