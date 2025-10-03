import 'dart:io';

class ConnectivityHelper {
  // Simple connectivity check
  static Future<bool> isConnectedToInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } catch (_) {}
    return false;
  }

  // Check if server is reachable
  static Future<bool> isServerReachable(String serverUrl) async {
    try {
      final uri = Uri.parse(serverUrl);
      final client = HttpClient();
      final request = await client.getUrl(uri);
      request.headers.set('Connection', 'close');
      final response = await request.close().timeout(const Duration(seconds: 5));
      client.close();
      return response.statusCode < 500; // Accept any response that's not server error
    } catch (_) {
      return false;
    }
  }

  // Format time difference for user-friendly display
  static String formatTimeDifference(Duration difference) {
    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ${difference.inMinutes % 60}m ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return 'over a week ago';
    }
  }
}
