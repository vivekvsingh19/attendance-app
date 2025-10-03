import 'package:share_plus/share_plus.dart';

class ShareHelper {
  // Share the app with a predefined message
  static Future<void> shareApp() async {
    const String message = '''
📱 Hey! Check out this amazing attendance tracker app!

🎯 Upasthit - Smart Attendance Tracker
✅ Track your class attendance easily
📊 Get detailed reports and insights  
⚡ Never miss the minimum attendance requirement
🎨 Beautiful and intuitive interface

Perfect for students who want to stay on top of their attendance!

Download now: https://github.com/vivekvsingh19/attendance-app

#AttendanceTracker #StudentLife #Education
    ''';
    
    await Share.share(
      message,
      subject: 'Check out Upasthit - Attendance Tracker App!',
    );
  }
}
