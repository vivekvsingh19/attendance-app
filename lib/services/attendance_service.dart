import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/attendance.dart';
import '../models/datewise_attendance.dart';

class AttendanceService {
  // Base URL configuration - tries Heroku cloud first, then fallbacks
  static const String _baseUrl =
      'https://attendance-backend-api-a50f28666a6d.herokuapp.com'; // Your deployed Heroku app
  static const String _fallbackBaseUrl =
      'http://192.168.1.9:8000'; // Local network fallback (updated IP and port)
  static const String _networkBaseUrl =
      'http://10.0.2.2:8000'; // Android emulator fallback (updated port)

  static Future<AttendanceResponse> loginAndFetchAttendance({
    required String collegeId,
    required String password,
    String institutionType = "college", // "college" or "university"
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
              'institution_type': institutionType,
            }),
          )
          .timeout(
            const Duration(seconds: 15),
          ); // Longer timeout for cloud service

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
          message: 'Server error: ${response.statusCode}. Please try again.',
        );
      }
    } on SocketException {
      return AttendanceResponse(
        success: false,
        message:
            'Network error: Cannot connect to server. Please check your internet connection.',
      );
    } on HttpException {
      return AttendanceResponse(
        success: false,
        message: 'HTTP error occurred.',
      );
    } on FormatException {
      return AttendanceResponse(
        success: false,
        message: 'Invalid response format from server.',
      );
    } catch (e) {
      return AttendanceResponse(
        success: false,
        message: 'Unexpected error: ${e.toString()}',
      );
    }
  }

  static Future<bool> checkServerHealth() async {
    try {
      final baseUrl = await _getWorkingBaseUrl();
      final response = await http
          .get(
            Uri.parse('$baseUrl/health'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<String> _getWorkingBaseUrl() async {
    print('🔍 Checking server availability...');

    // Try Heroku first since it's the main deployment
    try {
      print('🌐 Trying Heroku: $_baseUrl');
      final response = await http
          .get(
            Uri.parse('$_baseUrl/health'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(
            const Duration(seconds: 8),
          ); // Longer timeout for cloud service
      if (response.statusCode == 200) {
        print('✅ Heroku is online!');
        return _baseUrl;
      }
    } catch (e) {
      print('❌ Heroku failed: $e');
    }

    // Try local network for development
    try {
      print('🏠 Trying local network: $_fallbackBaseUrl');
      final response = await http
          .get(
            Uri.parse('$_fallbackBaseUrl/health'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        print('✅ Local network is online!');
        return _fallbackBaseUrl;
      }
    } catch (e) {
      print('❌ Local network failed: $e');
      // Local network failed, try Android emulator
    }

    // Try Android emulator (10.0.2.2) fallback
    try {
      print('📱 Trying Android emulator: $_networkBaseUrl');
      final response = await http
          .get(
            Uri.parse('$_networkBaseUrl/health'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        print('✅ Android emulator is online!');
        return _networkBaseUrl;
      }
    } catch (e) {
      print('❌ Android emulator failed: $e');
    }

    print('⚠️ All servers failed, using Heroku as default');
    // Return Heroku URL as default since it's the main deployment
    return _baseUrl;
  }

  // Fetch date-wise attendance data
  static Future<List<DatewiseAttendanceEntry>> fetchDatewiseAttendance({
    required String collegeId,
    required String password,
    String institutionType = "college", // "college" or "university"
  }) async {
    try {
      final baseUrl = await _getWorkingBaseUrl();
      // Use GET request with query parameters to match backend
      final uri = Uri.parse('$baseUrl/dateWise').replace(
        queryParameters: {
          'username': collegeId,
          'password': password,
          'institution_type': institutionType,
        },
      );

      final response = await http
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData is Map && jsonData.containsKey('success')) {
          if (jsonData['success'] == true && jsonData.containsKey('data')) {
            final data = jsonData['data'] as List;
            // The API returns [forward, backward] arrays, we want the forward array (first one)
            if (data.isNotEmpty && data[0] is List) {
              final forwardData = data[0] as List;
              return forwardData
                  .map((item) => DatewiseAttendanceEntry.fromJson(item))
                  .toList();
            }
          } else {
            throw Exception(
              jsonData['message'] ?? 'Failed to fetch date-wise attendance',
            );
          }
        } else if (jsonData is List) {
          // If it's directly a list, assume it's the forward data
          return jsonData
              .map((item) => DatewiseAttendanceEntry.fromJson(item))
              .toList();
        }
        return [];
      } else {
        throw Exception(
          'Failed to fetch date-wise attendance: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching date-wise attendance: $e');
    }
  }
}
