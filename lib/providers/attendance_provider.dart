import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/attendance.dart';
import '../models/subject.dart';
import '../models/settings.dart';
import '../models/datewise_attendance.dart';
import '../services/attendance_service.dart';
import '../utils/connectivity_helper.dart';
import 'dart:convert';

class AttendanceProvider with ChangeNotifier {
  // Public method to load offline attendance (for use in SplashScreen)
  Future<void> loadOfflineAttendance() async {
    await _loadOfflineAttendance();
    await _loadDatewiseCacheQuietly(); // Also load datewise cache silently
  }
  // Save attendance data to SharedPreferences as JSON
  Future<void> _saveAttendanceCache(List<AttendanceData> attendanceList) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = attendanceList.map((a) => a.toJson()).toList();
      await prefs.setString(_attendanceCacheKey, jsonEncode(jsonList));
      // Save the timestamp when data was last updated from server
      await prefs.setString('last_data_update', DateTime.now().toIso8601String());
    } catch (e) {
      debugPrint('Error saving attendance cache: $e');
    }
  }

  // Load attendance data from SharedPreferences and set state if available
  Future<void> _loadOfflineAttendance() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_attendanceCacheKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        final cached = jsonList.map((e) => AttendanceData.fromJson(e['subject'], Map<String, dynamic>.from(e))).toList();
        if (cached.isNotEmpty) {
          _attendanceList = cached;
          _isLoggedIn = true;
          
          // Also load cached datewise attendance
          await _loadDatewiseFromCache();
          
          // Load saved credentials as well
          final savedCredentials = await _loadSavedCredentials();
          if (savedCredentials != null) {
            _collegeId = savedCredentials['collegeId'];
            _password = savedCredentials['password'];
          }
          
          // Get the last update time for user information
          final lastUpdateString = prefs.getString('last_data_update');
          if (lastUpdateString != null) {
            final lastUpdate = DateTime.parse(lastUpdateString);
            final timeDiff = DateTime.now().difference(lastUpdate);
            _error = 'Using offline data (updated ${ConnectivityHelper.formatTimeDifference(timeDiff)})';
          } else {
            _error = 'Using offline data (offline mode)';
          }
          
          notifyListeners(); // Notify UI of the state change
        }
      }
    } catch (e) {
      debugPrint('Error loading attendance cache: $e');
    }
  }
  List<AttendanceData> _attendanceList = [];
  bool _isLoading = false;
  String? _error;
  bool _isLoggedIn = false;
  String? _collegeId;
  String? _password; // Store password for refresh functionality
  String _institutionType = "college"; // Store institution type
  String? _serverStatus; // Track which server is being used
  
  // Date-wise attendance data
  List<DatewiseAttendanceEntry> _datewiseAttendance = [];
  bool _isDatewiseLoading = false;
  String? _datewiseError;
  
  // Getters
  List<AttendanceData> get attendanceList => _attendanceList;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _isLoggedIn;
  String? get collegeId => _collegeId;
  String? get serverStatus => _serverStatus;
  
  // Date-wise attendance getters
  List<DatewiseAttendanceEntry> get datewiseAttendance => _datewiseAttendance;
  bool get isDatewiseLoading => _isDatewiseLoading;
  String? get datewiseError => _datewiseError;

  // Additional properties for the new HomeScreen
  static const String _targetAttendanceKey = 'target_attendance';
  AttendanceSettings _settings = const AttendanceSettings();
  String? _studentName;
  
  // Secure storage instance
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  // Key for offline attendance cache
  static const String _attendanceCacheKey = 'attendance_cache';

  // Getters for new properties
  AttendanceSettings get settings => _settings;
  String? get studentName => _studentName;
  
  double get overallAttendancePercentage => overallAttendance;
  
  int get totalSafeBunks {
    return subjects.fold(0, (sum, subject) {
      if (subject.attendancePercentage >= _settings.attendanceThreshold) {
        // Calculate safe bunks for this subject
        final safeBunks = ((subject.attendedClasses * 100 - _settings.attendanceThreshold * subject.totalClasses) / _settings.attendanceThreshold).floor();
        return sum + (safeBunks > 0 ? safeBunks : 0);
      }
      return sum;
    });
  }
  
  int get totalClassesNeeded {
    return subjects.fold(0, (sum, subject) {
      if (subject.attendancePercentage < _settings.attendanceThreshold) {
        // Calculate classes needed for this subject
        final classesNeeded = ((subject.totalClasses * _settings.attendanceThreshold - subject.attendedClasses * 100) / (100 - _settings.attendanceThreshold)).ceil();
        return sum + classesNeeded;
      }
      return sum;
    });
  }

  List<Subject> get subjects {
    return _attendanceList.map((attendance) => 
      Subject.fromAttendanceData(attendance.subject, {
        'total': attendance.total,
        'attended': attendance.attended,
        'percentage': attendance.percentage,
      })
    ).toList();
  }

  double get overallAttendance {
    if (_attendanceList.isEmpty) return 0.0;
    
    int totalClasses = _attendanceList.fold(0, (sum, item) => sum + item.total);
    int attendedClasses = _attendanceList.fold(0, (sum, item) => sum + item.attended);
    
    return totalClasses > 0 ? (attendedClasses / totalClasses) * 100 : 0.0;
  }

  int get totalSubjects => _attendanceList.length;

  int get lowAttendanceSubjects {
    return _attendanceList.where((attendance) => attendance.percentage < _settings.attendanceThreshold).length;
  }

  Future<void> login(String collegeId, String password, {String institutionType = "college"}) async {
    // Prevent multiple concurrent login attempts
    if (_isLoading) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Try real login
      AttendanceResponse response = await AttendanceService.loginAndFetchAttendance(
        collegeId: collegeId,
        password: password,
        institutionType: institutionType,
      );

      if (response.success && response.data != null) {
        _attendanceList = response.data!.values.toList();
        _isLoggedIn = true;
        _collegeId = collegeId;
        _password = password;
        _institutionType = institutionType; // Store institution type
        // Save login credentials securely
        await _saveLoginCredentials(collegeId, password);
        // Save attendance cache for offline use - this ensures most recent data is saved
        await _saveAttendanceCache(_attendanceList);
        _error = null;
        
        // Also fetch datewise attendance when user logs in
        try {
          await fetchDatewiseAttendance();
        } catch (e) {
          // Don't let datewise fetch error affect main login
          debugPrint('Failed to fetch datewise attendance during login: $e');
        }
      } else {
        _error = response.message;
        _isLoggedIn = false;
      }
    } catch (e) {
      _error = 'An unexpected error occurred: ${e.toString()}';
      _isLoggedIn = false;
      // Try to load offline attendance if available
      await _loadOfflineAttendance();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshAttendance() async {
    if (!_isLoggedIn || _collegeId == null || _password == null) {
      // Try to load saved credentials
      final savedCredentials = await _loadSavedCredentials();
      if (savedCredentials == null) {
        _error = 'No saved credentials found. Please login again.';
        notifyListeners();
        return;
      }
      _collegeId = savedCredentials['collegeId'];
      _password = savedCredentials['password'];
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Make fresh API call with saved credentials
      AttendanceResponse response = await AttendanceService.loginAndFetchAttendance(
        collegeId: _collegeId!,
        password: _password!,
        institutionType: _institutionType,
      );

      if (response.success && response.data != null) {
        _attendanceList = response.data!.values.toList();
        // Save attendance cache for offline use - this ensures most recent data is saved
        await _saveAttendanceCache(_attendanceList);
        _error = null;
        
        // Also fetch datewise attendance when main attendance is fetched
        try {
          debugPrint('refreshAttendance: Attempting to fetch datewise attendance');
          await fetchDatewiseAttendance();
        } catch (e) {
          // Don't let datewise fetch error affect main attendance
          debugPrint('Failed to fetch datewise attendance: $e');
        }
      } else {
        _error = response.message;
        // If login fails, it might be due to expired credentials
        if (response.message.contains('authentication failed') || 
            response.message.contains('Invalid credentials')) {
          await _clearLoginCredentials();
          _isLoggedIn = false;
          _collegeId = null;
          _password = null;
        }
      }
    } catch (e) {
      _error = 'Failed to refresh attendance: ${e.toString()}';
      // Load offline data if refresh fails, but notify user it's cached data
      await _loadOfflineAttendance();
      if (_attendanceList.isNotEmpty) {
        _error = 'Server unavailable - showing cached data. ${_error?.split('(').last ?? ''}';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Clear all data
      _attendanceList.clear();
      _isLoggedIn = false;
      _collegeId = null;
      _password = null;
      _studentName = null;
      _settings = const AttendanceSettings();
      _error = null;
      
      // Clear saved credentials
      await _clearLoginCredentials();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to logout: $e';
      notifyListeners();
    }
  }

  // Save login credentials securely
  Future<void> _saveLoginCredentials(String collegeId, String password) async {
    try {
      await _secureStorage.write(key: 'collegeId', value: collegeId);
      await _secureStorage.write(key: 'password', value: password);
      
      // Also save login state in shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('collegeId', collegeId);
    } catch (e) {
      debugPrint('Error saving login credentials: $e');
    }
  }

  // Load saved credentials
  Future<Map<String, String>?> _loadSavedCredentials() async {
    try {
      final collegeId = await _secureStorage.read(key: 'collegeId');
      final password = await _secureStorage.read(key: 'password');
      
      if (collegeId != null && password != null) {
        return {
          'collegeId': collegeId,
          'password': password,
        };
      }
      return null;
    } catch (e) {
      debugPrint('Error loading saved credentials: $e');
      return null;
    }
  }

  // Clear saved credentials
  Future<void> _clearLoginCredentials() async {
    try {
      await _secureStorage.delete(key: 'collegeId');
      await _secureStorage.delete(key: 'password');
      // Also clear shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isLoggedIn');
      await prefs.remove('collegeId');
    } catch (e) {
      debugPrint('Error clearing login credentials: $e');
    }
  }

  // Check if user has saved credentials and auto-login
  Future<bool> checkAndAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final wasLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    
    if (!wasLoggedIn) return false;
    
    final savedCredentials = await _loadSavedCredentials();
    if (savedCredentials == null) return false;
    
    // Attempt auto-login with saved credentials
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await AttendanceService.loginAndFetchAttendance(
        collegeId: savedCredentials['collegeId']!,
        password: savedCredentials['password']!,
        institutionType: _institutionType,
      );
      if (response.success && response.data != null) {
        _attendanceList = response.data!.values.toList();
        _isLoggedIn = true;
        _collegeId = savedCredentials['collegeId'];
        _password = savedCredentials['password'];
        // Save the fresh data immediately after successful fetch
        await _saveAttendanceCache(_attendanceList);
        _error = null;
        
        // Also fetch datewise attendance during auto-login
        try {
          await fetchDatewiseAttendance();
        } catch (e) {
          // Don't let datewise fetch error affect auto-login
          debugPrint('Failed to fetch datewise attendance during auto-login: $e');
        }
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // Auto-login failed, clear saved credentials
        await _clearLoginCredentials();
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      await _clearLoginCredentials();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Check if user has offline data and was previously logged in
  Future<bool> checkOfflineDataAndLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final wasLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      
      if (!wasLoggedIn) {
        return false; // User was never logged in
      }
      
      // Try to load offline attendance data
      await _loadOfflineAttendance();
      
      // Check if we have valid attendance data
      if (_attendanceList.isNotEmpty && _isLoggedIn) {
        // Set basic user info from preferences if available
        _collegeId = prefs.getString('collegeId');
        return true;
      } else {
        return false; // No valid offline data
      }
    } catch (e) {
      debugPrint('Error checking offline data: $e');
      return false;
    }
  }

  AttendanceData? getAttendanceForSubject(String subject) {
    try {
      return _attendanceList.firstWhere(
        (attendance) => attendance.subject.toLowerCase() == subject.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  Future<bool> testConnection() async {
    try {
      final isConnected = await AttendanceService.checkServerHealth();
      return isConnected;
    } catch (e) {
      return false;
    }
  }

  // Load settings from SharedPreferences
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final target = prefs.getDouble(_targetAttendanceKey);
    debugPrint('🐛 loadSettings: loaded threshold=$target');
    if (target != null) {
      _settings = _settings.copyWith(attendanceThreshold: target);
      debugPrint('🐛 loadSettings: updated settings.attendanceThreshold=${_settings.attendanceThreshold}');
      notifyListeners();
    }
  }

  // Update target attendance and persist
  Future<void> updateAttendanceThreshold(double value) async {
    _settings = _settings.copyWith(attendanceThreshold: value);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_targetAttendanceKey, value);
  }

  // Method to update student name
  void updateStudentName(String name) {
    _studentName = name;
    notifyListeners();
  }

  // Method to toggle reminder settings
  void toggleReminders() {
    _settings = _settings.copyWith(reminderEnabled: !_settings.reminderEnabled);
    notifyListeners();
  }

  // Method to update student ID
  void updateStudentId(String id) {
    _settings = _settings.copyWith(studentId: id);
    notifyListeners();
  }

  // Force refresh data from server, bypassing cache
  Future<void> forceRefreshFromServer() async {
    if (_collegeId == null || _password == null) {
      final savedCredentials = await _loadSavedCredentials();
      if (savedCredentials == null) {
        _error = 'No saved credentials found. Please login again.';
        notifyListeners();
        return;
      }
      _collegeId = savedCredentials['collegeId'];
      _password = savedCredentials['password'];
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await AttendanceService.loginAndFetchAttendance(
        collegeId: _collegeId!,
        password: _password!,
        institutionType: _institutionType,
      );

      if (response.success && response.data != null) {
        _attendanceList = response.data!.values.toList();
        await _saveAttendanceCache(_attendanceList);
        _error = 'Data refreshed successfully';
        
        // Clear error message after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          if (_error == 'Data refreshed successfully') {
            _error = null;
            notifyListeners();
          }
        });
      } else {
        _error = 'Failed to refresh: ${response.message}';
      }
    } catch (e) {
      _error = 'Connection failed. Using cached data.';
      await _loadOfflineAttendance();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Check if cached data is stale (older than 9 hours)
  Future<bool> isCachedDataStale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastUpdateString = prefs.getString('last_data_update');
      if (lastUpdateString == null) return true;
      
      final lastUpdate = DateTime.parse(lastUpdateString);
      final timeDiff = DateTime.now().difference(lastUpdate);
      return timeDiff.inHours > 9; // Consider data stale after 9 hours
    } catch (e) {
      return true; // If we can't determine, assume stale
    }
  }

  // Check if the cached date-wise data is stale (older than 9 hours)
  Future<bool> _isDatewiseDataStale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastUpdateString = prefs.getString('datewise_last_update');
      if (lastUpdateString == null) return true;
      
      final lastUpdate = DateTime.parse(lastUpdateString);
      final timeDiff = DateTime.now().difference(lastUpdate);
      return timeDiff.inHours > 9; // Consider data stale after 9 hours
    } catch (e) {
      return true; // If we can't determine, assume stale
    }
  }

  // Load date-wise attendance from cache first, then refresh if needed
  Future<void> loadDatewiseAttendance() async {
    // Always load from cache first, regardless of login state
    await _loadDatewiseFromCache();
    
    // If we have cached data, show it immediately (no loading state, no error messages)
    if (_datewiseAttendance.isNotEmpty) {
      notifyListeners();
      // Silently refresh in background if data is stale and user is logged in
      if (_isLoggedIn && _collegeId != null && _password != null) {
        if (await ConnectivityHelper.isConnectedToInternet() && await _isDatewiseDataStale()) {
          // Background refresh - don't show loading state or error messages
          await refreshDatewiseAttendance();
        }
      }
      return;
    }

    // If no cached data, check if user is logged in to fetch fresh data
    if (!_isLoggedIn || _collegeId == null || _password == null) {
      // User not logged in and no cached data - this is expected on first run
      // The UI will show the empty state with "Fetch Data" button
      _datewiseError = null;
      notifyListeners();
      return;
    }

    // User is logged in but no cached data - fetch from server with loading state
    if (await ConnectivityHelper.isConnectedToInternet()) {
      _isDatewiseLoading = true;
      _datewiseError = null;
      notifyListeners();
      
      try {
        final datewise = await AttendanceService.fetchDatewiseAttendance(
          collegeId: _collegeId!,
          password: _password!,
        );

        _datewiseAttendance = datewise;
        _datewiseError = null;

        // Cache the data
        await _saveDatewiseCache();
      } catch (e) {
        _datewiseError = 'Failed to fetch date-wise attendance: $e';
      } finally {
        _isDatewiseLoading = false;
        notifyListeners();
      }
    } else {
      _datewiseError = 'No internet connection';
      notifyListeners();
    }
  }

  // Fetch date-wise attendance data (force refresh)
  Future<void> fetchDatewiseAttendance() async {
    debugPrint('fetchDatewiseAttendance called - isLoggedIn: $_isLoggedIn, collegeId: $_collegeId');
    
    if (!_isLoggedIn || _collegeId == null || _password == null) {
      _datewiseError = 'User not logged in';
      debugPrint('fetchDatewiseAttendance failed: User not logged in');
      notifyListeners();
      return;
    }

    _isDatewiseLoading = true;
    _datewiseError = null;
    notifyListeners();

    try {
      // Skip connectivity check for now since main attendance is working
      // The connectivity helper seems to be giving false negatives
      debugPrint('fetchDatewiseAttendance: Attempting direct fetch (skipping connectivity check)');
      
      /*
      // Check connectivity first
      final hasInternet = await ConnectivityHelper.isConnectedToInternet();
      debugPrint('fetchDatewiseAttendance: Internet connectivity: $hasInternet');
      
      // If connectivity check fails but we have main attendance data, try anyway
      if (!hasInternet && _attendanceList.isNotEmpty) {
        debugPrint('fetchDatewiseAttendance: Connectivity check failed but main attendance exists, trying fetch anyway');
      } else if (!hasInternet) {
        debugPrint('fetchDatewiseAttendance: No internet, loading from cache');
        await _loadDatewiseFromCache();
        _datewiseError = 'offline - showing cached data';
        return;
      }
      */

      debugPrint('fetchDatewiseAttendance: Fetching from server...');
      // Fetch both date-wise and till-date attendance
      final datewise = await AttendanceService.fetchDatewiseAttendance(
        collegeId: _collegeId!,
        password: _password!,
      );

      debugPrint('fetchDatewiseAttendance: Received ${datewise.length} entries');
      _datewiseAttendance = datewise;
      _datewiseError = null;

      // Cache the data
      await _saveDatewiseCache();
      
    } catch (e) {
      debugPrint('fetchDatewiseAttendance error: $e');
      _datewiseError = 'Failed to fetch date-wise attendance: $e';
      // Try to load from cache if available
      await _loadDatewiseFromCache();
    } finally {
      _isDatewiseLoading = false;
      notifyListeners();
    }
  }

  // Refresh date-wise attendance from network (background refresh)
  Future<void> refreshDatewiseAttendance() async {
    if (!_isLoggedIn || _collegeId == null || _password == null) {
      return;
    }

    try {
      if (!await ConnectivityHelper.isConnectedToInternet()) {
        return;
      }

      // Fetch fresh data without showing loading state
      final datewise = await AttendanceService.fetchDatewiseAttendance(
        collegeId: _collegeId!,
        password: _password!,
      );

      _datewiseAttendance = datewise;
      _datewiseError = null;

      // Cache the fresh data
      await _saveDatewiseCache();
      
      notifyListeners();
    } catch (e) {
      debugPrint('Background refresh failed: $e');
      // Don't update error state for background refresh failures
    }
  }

  // Save date-wise attendance data to cache
  Future<void> _saveDatewiseCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save datewise attendance
      final datewiseJson = _datewiseAttendance.map((e) => e.toJson()).toList();
      await prefs.setString('datewise_cache', jsonEncode(datewiseJson));
      
      // Save timestamp
      await prefs.setString('datewise_last_update', DateTime.now().toIso8601String());
    } catch (e) {
      debugPrint('Error saving date-wise cache: $e');
    }
  }

  // Load date-wise attendance data from cache quietly (no error messages)
  Future<void> _loadDatewiseCacheQuietly() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load datewise attendance
      final datewiseJson = prefs.getString('datewise_cache');
      if (datewiseJson != null) {
        final List<dynamic> datewiseList = jsonDecode(datewiseJson);
        _datewiseAttendance = datewiseList
            .map((e) => DatewiseAttendanceEntry.fromJson(e))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading date-wise cache quietly: $e');
    }
  }

  // Load date-wise attendance data from cache
  Future<void> _loadDatewiseFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load datewise attendance
      final datewiseJson = prefs.getString('datewise_cache');
      if (datewiseJson != null) {
        final List<dynamic> datewiseList = jsonDecode(datewiseJson);
        _datewiseAttendance = datewiseList
            .map((e) => DatewiseAttendanceEntry.fromJson(e))
            .toList();
      }

      // Don't set any status messages for cached data - just like home screen
      // Only set error messages for actual problems, not normal cache usage
      _datewiseError = null;
      
    } catch (e) {
      debugPrint('Error loading date-wise cache: $e');
      _datewiseError = 'Failed to load cached data';
    }
  }

}
