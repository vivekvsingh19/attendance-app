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
    return Subject(
      name: name,
      code: name.substring(0, 3).toUpperCase(),
      totalClasses: data['total'] ?? 0,
      attendedClasses: data['attended'] ?? 0,
      attendancePercentage: (data['percentage']?.toDouble() ?? 0.0),
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
