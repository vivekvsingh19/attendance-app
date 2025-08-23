import 'package:http/http.dart' as http;
import '../models/announcement.dart';

class SheetsAnnouncementService {
  // Your Google Sheets CSV export URL
  static const String csvUrl = 'https://docs.google.com/spreadsheets/d/1uyhF0UhGhBVWLecOkdNaOHsLCNxfw7bRxUdx96ril04/export?format=csv';
  
  static Future<List<Announcement>> getAnnouncements() async {
    try {
      final response = await http.get(Uri.parse(csvUrl));
      
      if (response.statusCode == 200) {
        List<Announcement> announcements = [];
        List<String> lines = response.body.split('\n');
        
        // Skip header row (first line)
        for (int i = 1; i < lines.length; i++) {
          if (lines[i].trim().isNotEmpty) {
            List<String> values = lines[i].split(',');
            if (values.length >= 4) {
              // Clean up the values by removing quotes
              String id = values[0].replaceAll('"', '').trim();
              String title = values[1].replaceAll('"', '').trim();
              String content = values[2].replaceAll('"', '').trim();
              String timestamp = values[3].replaceAll('"', '').trim();
              String important = values.length > 4 ? values[4].replaceAll('"', '').trim() : '';
              
              if (title.isNotEmpty && content.isNotEmpty) {
                announcements.add(Announcement(
                  id: id.isEmpty ? DateTime.now().millisecondsSinceEpoch.toString() : id,
                  title: title,
                  content: content,
                  createdAt: _parseDate(timestamp),
                  isImportant: important.toLowerCase() == 'true' || important == '1',
                ));
              }
            }
          }
        }
        
        // Sort by createdAt, newest first
        announcements.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return announcements;
      }
    } catch (e) {
      print('Error fetching announcements from sheets: $e');
    }
    return [];
  }
  
  static DateTime _parseDate(String dateString) {
    try {
      // Try to parse various date formats
      if (dateString.isEmpty) return DateTime.now();
      
      // If it's already in ISO format
      if (dateString.contains('T')) {
        return DateTime.parse(dateString);
      }
      
      // If it's in MM/DD/YYYY format
      if (dateString.contains('/')) {
        List<String> parts = dateString.split('/');
        if (parts.length == 3) {
          int month = int.parse(parts[0]);
          int day = int.parse(parts[1]);
          int year = int.parse(parts[2]);
          return DateTime(year, month, day);
        }
      }
      
      // If it's in DD-MM-YYYY format
      if (dateString.contains('-')) {
        List<String> parts = dateString.split('-');
        if (parts.length == 3) {
          int day = int.parse(parts[0]);
          int month = int.parse(parts[1]);
          int year = int.parse(parts[2]);
          return DateTime(year, month, day);
        }
      }
      
      return DateTime.now();
    } catch (e) {
      return DateTime.now();
    }
  }
}
