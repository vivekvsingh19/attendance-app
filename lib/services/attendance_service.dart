import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/attendance.dart';

class AttendanceService {
  // Base URL configuration - tries different localhost addresses
  static const String _baseUrl = 'http://10.0.2.2:8001'; // Android emulator localhost
  static const String _fallbackBaseUrl = 'http://localhost:8001'; // Regular localhost
  static const String _networkBaseUrl = 'http://192.168.1.9:8001'; // Network IP
  
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
          .timeout(const Duration(seconds: 10)); // Remove mock data on timeout

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
    // Try Android emulator localhost first
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 2));
      if (response.statusCode == 200) {
        return _baseUrl;
      }
    } catch (e) {
      // Android emulator localhost failed, try regular localhost
    }
    
    // Try regular localhost
    try {
      final response = await http.get(
        Uri.parse('$_fallbackBaseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 2));
      if (response.statusCode == 200) {
        return _fallbackBaseUrl;
      }
    } catch (e) {
      // Regular localhost failed, try network IP
    }
    
    // Try network IP
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
    
    // Return default if all fail
    return _baseUrl;
  }
}
