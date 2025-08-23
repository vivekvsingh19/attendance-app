import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/attendance.dart';

class AttendanceService {
  // Base URL configuration - tries Heroku cloud first, then fallbacks
  static const String _baseUrl = 'https://attendance-backend-api-a50f28666a6d.herokuapp.com'; // Heroku deployment
  static const String _fallbackBaseUrl = 'http://192.168.29.21:5000'; // Local network fallback
  static const String _networkBaseUrl = 'http://10.0.2.2:5000'; // Android emulator fallback
  
  static Future<AttendanceResponse> loginAndFetchAttendance({
    required String collegeId,
    required String password,
  }) async {
    try {
      // Get the working base URL
      final baseUrl = await _getWorkingBaseUrl();
      final response = await http
          .post(
            Uri.parse('$baseUrl/login-and-fetch-attendance'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'college_id': collegeId,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 15)); // Longer timeout for cloud service

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return AttendanceResponse.fromJson(jsonData);
      } else if (response.statusCode == 422) {
        return AttendanceResponse(
          success: false,
          message: 'Invalid request format. Please check your credentials.',
        );
      } else {
        return AttendanceResponse(
          success: false,
          message: 'Server error: {response.statusCode}. Please try again.',
        );
      }
    } on SocketException {
      return AttendanceResponse(
        success: false,
        message: 'Network error: Cannot connect to server. Please check your internet connection.',
      );
    } on HttpException catch (e) {
      return AttendanceResponse(
        success: false,
        message: 'HTTP error: {e.message}',
      );
    } on FormatException {
      return AttendanceResponse(
        success: false,
        message: 'Invalid response format from server.',
      );
    } catch (e) {
      return AttendanceResponse(
        success: false,
        message: 'Unexpected error: {e.toString()}',
      );
    }
  }

  static Future<bool> checkServerHealth() async {
    try {
      final baseUrl = await _getWorkingBaseUrl();
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<String> _getWorkingBaseUrl() async {
    // Try Heroku cloud deployment first
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 8)); // Longer timeout for cloud service
      if (response.statusCode == 200) {
        return _baseUrl;
      }
    } catch (e) {
      // Heroku failed, try local network
    }
    
    // Try local network fallback
    try {
      final response = await http.get(
        Uri.parse('$_fallbackBaseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        return _fallbackBaseUrl;
      }
    } catch (e) {
      // Local network failed, try Android emulator
    }
    
    // Try Android emulator fallback
    try {
      final response = await http.get(
        Uri.parse('$_networkBaseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 2));
      if (response.statusCode == 200) {
        return _networkBaseUrl;
      }
    } catch (e) {
      // All failed
    }
    
    // Return Heroku URL as default since it's most likely to work
    return _baseUrl;
  }
}
