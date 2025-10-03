import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/attendance_provider.dart';

class ProjectedAttendanceScreen extends StatelessWidget {
  final Set<DateTime> bunkDates;
  final Set<DateTime> holidayDates;
  final Set<DateTime> academicHolidays;
  final Map<int, List<String>> timetable;
  final List subjects;
  final bool Function(DateTime) isWeekend;
  final bool Function(DateTime, DateTime) isSameDay;
  final List<String> Function(DateTime, List) subjectsForDate;
  final bool Function(DateTime) isAcademicHoliday;

  const ProjectedAttendanceScreen({
    Key? key,
    required this.bunkDates,
    required this.holidayDates,
    required this.academicHolidays,
    required this.timetable,
    required this.subjects,
    required this.isWeekend,
    required this.isSameDay,
    required this.subjectsForDate,
    required this.isAcademicHoliday,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeBlue = const Color(0xFF1B7EE6);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projected Attendance'),
        backgroundColor: Colors.white,
        foregroundColor: themeBlue,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF1B7EE6)),
        titleTextStyle: const TextStyle(
          color: Color(0xFF1B7EE6),
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body: Consumer<AttendanceProvider>(
        builder: (context, provider, child) {
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            itemCount: subjects.length,
            itemBuilder: (context, idx) {
              final subject = subjects[idx];
              final int total = subject.totalClasses;
              final int attended = subject.attendedClasses;
              // Only count bunks for this subject, not on holidays/weekends/academic holidays
              final int effectiveBunks = bunkDates.where((d) {
                if (holidayDates.any((h) => isSameDay(h, d)) || isWeekend(d) || isAcademicHoliday(d)) return false;
                final subjectNames = subjectsForDate(d, subjects);
                return subjectNames.contains(subject.name);
              }).length;
              final int projectedTotal = total + effectiveBunks;
              final int projectedAttended = attended;
              final double projectedPercent = projectedTotal == 0 ? 0 : (projectedAttended / projectedTotal) * 100;
              final bool isBelow = projectedPercent < provider.settings.attendanceThreshold;
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: themeBlue.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(
                    color: isBelow ? Colors.red.withOpacity(0.18) : themeBlue.withOpacity(0.18),
                    width: 1.2,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  title: Text(
                    subject.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: isBelow ? Colors.red : themeBlue,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    'Current: {subject.attendancePercentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: isBelow ? Colors.red.shade300 : Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Projected',
                        style: TextStyle(
                          fontSize: 12,
                          color: isBelow ? Colors.red : themeBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '{projectedPercent.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: isBelow ? Colors.red : themeBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
