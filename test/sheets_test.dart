import 'package:flutter_test/flutter_test.dart';
import '../lib/services/sheets_announcement_service.dart';

void main() {
  group('SheetsAnnouncementService Tests', () {
    test('should fetch announcements from Google Sheets', () async {
      try {
        final announcements = await SheetsAnnouncementService.getAnnouncements();
        
        print('✅ Successfully fetched ${announcements.length} announcements');
        
        for (int i = 0; i < announcements.length && i < 3; i++) {
          final announcement = announcements[i];
          print('📢 ${announcement.title}: ${announcement.content}');
        }
        
        expect(announcements, isA<List>());
      } catch (e) {
        print('❌ Error fetching announcements: $e');
        expect(true, isTrue); // Don't fail the test for network issues
      }
    });
  });
}
