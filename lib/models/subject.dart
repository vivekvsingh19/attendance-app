class Subject {
  final String name;
  final String code;
  final int totalClasses;
  final int attendedClasses;
  final double attendancePercentage;

  Subject({
    required this.name,
    required this.code,
    required this.totalClasses,
    required this.attendedClasses,
    required this.attendancePercentage,
  });

  factory Subject.fromAttendanceData(String name, Map<String, dynamic> data) {
    final int total = data['total'] ?? 0;
    final int attended = data['attended'] ?? 0;
    double percentage = (data['percentage']?.toDouble() ?? 0.0);
    if (percentage == 0.0 && total > 0) {
      percentage = (attended / total) * 100;
    }
    return Subject(
      name: name,
      code: name.substring(0, 3).toUpperCase(),
      totalClasses: total,
      attendedClasses: attended,
      attendancePercentage: percentage,
    );
  }

  bool get isLowAttendance => attendancePercentage < 75.0;
  
  String get status {
    if (attendancePercentage >= 90) return 'Excellent';
    if (attendancePercentage >= 80) return 'Good';
    if (attendancePercentage >= 75) return 'Average';
    return 'Low';
  }

  int get classesToAttend {
    if (attendancePercentage >= 75) return 0;
    // Calculate classes needed to reach 75%
    return ((0.75 * totalClasses - attendedClasses) / 0.25).ceil();
  }
}
