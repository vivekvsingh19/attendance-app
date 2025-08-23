import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/attendance.dart';
import '../models/subject.dart';
import '../models/settings.dart';
import '../services/attendance_service.dart';
import 'dart:convert';

class AttendanceProvider with ChangeNotifier {
  // Public method to load offline attendance (for use in SplashScreen)
  Future<void> loadOfflineAttendance() async {
    await _loadOfflineAttendance();
  }
  // Save attendance data to SharedPreferences as JSON
  Future<void> _saveAttendanceCache(List<AttendanceData> attendanceList) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = attendanceList.map((a) => a.toJson()).toList();
      await prefs.setString(_attendanceCacheKey, jsonEncode(jsonList));
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
          _error = 'Loaded last saved data (offline mode)';
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

  List<AttendanceData> get attendanceList => _attendanceList;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _isLoggedIn;
  String? get collegeId => _collegeId;

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
    return _attendanceList.where((attendance) => attendance.isLowAttendance).length;
  }

  Future<void> login(String collegeId, String password) async {
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
      );

      if (response.success && response.data != null) {
        _attendanceList = response.data!.values.toList();
        _isLoggedIn = true;
        _collegeId = collegeId;
        _password = password;
        // Save login credentials securely
        await _saveLoginCredentials(collegeId, password);
        // Save attendance cache for offline use
        await _saveAttendanceCache(_attendanceList);
        _error = null;
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
      );

      if (response.success && response.data != null) {
        _attendanceList = response.data!.values.toList();
        // Save attendance cache for offline use
        await _saveAttendanceCache(_attendanceList);
        _error = null;
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
      // Try to load offline attendance if available
      await _loadOfflineAttendance();
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
      );
      if (response.success && response.data != null) {
        _attendanceList = response.data!.values.toList();
        _isLoggedIn = true;
        _collegeId = savedCredentials['collegeId'];
        _password = savedCredentials['password'];
        _error = null;
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
    if (target != null) {
      _settings = _settings.copyWith(attendanceThreshold: target);
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

}
