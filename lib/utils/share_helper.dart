import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import '../models/subject.dart';
import '../providers/attendance_provider.dart';

class ShareHelper {
  // Share the app with a predefined message
  static Future<void> shareApp() async {
    const String message = '''
📱 Hey! Check out this amazing attendance tracker app!

🎯 Upasthit - Smart Attendance Tracker
✅ Instantly check your attendance (no need to visit website)
⚡ See critical & safe subjects, track how many lectures you can bunk
🎯 Set your own attendance target
📈 GPA calculator & more—all in one app!

Perfect for LNCT Group of Colleges students who want to stay on top of their attendance!


Download now: https://play.google.com/store/apps/details?id=com.upasthit.app&hl=en_US


    ''';
    
    await Share.share(
      message,
      subject: 'Check out Upasthit - Attendance Tracker App!',
    );
  }

  // Share attendance report with critical subjects
  static Future<void> shareAttendanceReport({
    required List<Subject> subjects,
    required double overallAttendance,
    required double threshold,
    String? studentName,
  }) async {
    final StringBuffer content = StringBuffer();
    
    // Header
    content.writeln('📊 ATTENDANCE REPORT');
    content.writeln('═' * 25);
    if (studentName != null && studentName.isNotEmpty) {
      content.writeln('Student: $studentName');
    }
    content.writeln('Overall Attendance: ${overallAttendance.toStringAsFixed(1)}%');
    content.writeln('Target Threshold: ${threshold.toStringAsFixed(0)}%');
    content.writeln('');
    
    // Status
    final String status = overallAttendance >= threshold ? '✅ GOOD' : '⚠️ CRITICAL';
    content.writeln('Status: $status');
    content.writeln('');
    
    // Subject-wise breakdown
    content.writeln('📚 SUBJECT BREAKDOWN:');
    content.writeln('─' * 25);
    
    for (int i = 0; i < subjects.length; i++) {
      final subject = subjects[i];
      final String statusIcon = subject.attendancePercentage >= threshold ? '✅' : '❌';
      content.writeln('${i + 1}. ${subject.name}');
      content.writeln('   $statusIcon ${subject.attendancePercentage.toStringAsFixed(1)}% (${subject.attendedClasses}/${subject.totalClasses})');
      content.writeln('');
    }
    
    // Critical subjects
    final criticalSubjects = subjects.where((s) => s.attendancePercentage < threshold).toList();
    if (criticalSubjects.isNotEmpty) {
      content.writeln('🚨 CRITICAL SUBJECTS:');
      content.writeln('─' * 20);
      for (final subject in criticalSubjects) {
        final classesNeeded = _calculateClassesNeeded(subject, threshold);
        content.writeln('• ${subject.name}: ${subject.attendancePercentage.toStringAsFixed(1)}%');
        if (classesNeeded > 0) {
          content.writeln('  Need to attend $classesNeeded more classes');
        }
      }
      content.writeln('');
    }
    
    content.writeln('📱 Shared from Upasthit Attendance App');
    content.writeln('Download: https://play.google.com/store/apps/details?id=com.upasthit.app&hl=en_US');
    
    await Share.share(
      content.toString(),
      subject: 'My Attendance Report - ${overallAttendance.toStringAsFixed(1)}%',
    );
  }

  // Share critical subjects details
  static Future<void> shareCriticalSubjects({
    required List<Subject> subjects,
    required double threshold,
    String? studentName,
  }) async {
    final criticalSubjects = subjects.where((s) => s.attendancePercentage < threshold).toList();
    
    if (criticalSubjects.isEmpty) {
      await Share.share(
        '🎉 Great news! All subjects are above the attendance threshold of ${threshold.toStringAsFixed(0)}%!\n\n📱 Shared from Upasthit Attendance App',
        subject: 'All Subjects Above Threshold!',
      );
      return;
    }

    final StringBuffer content = StringBuffer();
    
    content.writeln('🚨 CRITICAL ATTENDANCE ALERT');
    content.writeln('═' * 30);
    if (studentName != null && studentName.isNotEmpty) {
      content.writeln('Student: $studentName');
    }
    content.writeln('Threshold: ${threshold.toStringAsFixed(0)}%');
    content.writeln('');
    
    content.writeln('⚠️ SUBJECTS BELOW THRESHOLD:');
    content.writeln('─' * 28);
    
    for (int i = 0; i < criticalSubjects.length; i++) {
      final subject = criticalSubjects[i];
      final classesNeeded = _calculateClassesNeeded(subject, threshold);
      
      content.writeln('${i + 1}. ${subject.name}');
      content.writeln('   Current: ${subject.attendancePercentage.toStringAsFixed(1)}% (${subject.attendedClasses}/${subject.totalClasses})');
      if (classesNeeded > 0) {
        content.writeln('   Action: Attend $classesNeeded more classes');
      }
      content.writeln('');
    }
    
    content.writeln('💡 TIP: Use Upasthit app to track and improve your attendance!');
    content.writeln('📱 Download: https://play.google.com/store/apps/details?id=com.upasthit.app&hl=en_US');
    
    await Share.share(
      content.toString(),
      subject: 'Critical Attendance Alert - Action Needed!',
    );
  }

  // Show share options dialog
  static Future<void> showShareOptions(BuildContext context, AttendanceProvider provider) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Share Options',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            ListTile(
              leading: const Icon(Icons.share, color: Color(0xFF667EEA)),
              title: const Text('Share App'),
              subtitle: const Text('Share the app with friends'),
              onTap: () {
                Navigator.pop(context);
                shareApp();
              },
            ),
            
            if (provider.subjects.isNotEmpty) ...[
              ListTile(
                leading: const Icon(Icons.assessment, color: Color(0xFF10B981)),
                title: const Text('Share Attendance Report'),
                subtitle: const Text('Share your complete attendance summary'),
                onTap: () {
                  Navigator.pop(context);
                  shareAttendanceReport(
                    subjects: provider.subjects,
                    overallAttendance: provider.overallAttendancePercentage,
                    threshold: provider.settings.attendanceThreshold,
                    studentName: provider.studentName,
                  );
                },
              ),
              
              ListTile(
                leading: const Icon(Icons.warning, color: Color(0xFFF59E0B)),
                title: const Text('Share Critical Subjects'),
                subtitle: const Text('Share subjects below attendance threshold'),
                onTap: () {
                  Navigator.pop(context);
                  shareCriticalSubjects(
                    subjects: provider.subjects,
                    threshold: provider.settings.attendanceThreshold,
                    studentName: provider.studentName,
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Helper method to calculate classes needed
  static int _calculateClassesNeeded(Subject subject, double threshold) {
    if (subject.attendancePercentage >= threshold) return 0;
    
    final double needed = (threshold * subject.totalClasses - subject.attendedClasses * 100) / (100 - threshold);
    return needed.ceil().clamp(0, double.infinity).toInt();
  }
}
