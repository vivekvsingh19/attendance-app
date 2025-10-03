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
    // Always calculate percentage from attended/total for accuracy
    double percentage = total > 0 ? (attended / total) * 100 : 0.0;
    
    return Subject(
      name: name,
      code: name.substring(0, 3).toUpperCase(),
      totalClasses: total,
      attendedClasses: attended,
      attendancePercentage: percentage,
    );
  }

  bool isLowAttendance(double threshold) => attendancePercentage < threshold;
  
  String getStatus(double threshold) {
    if (attendancePercentage >= threshold + 15) return 'Excellent';
    if (attendancePercentage >= threshold + 5) return 'Good';
    if (attendancePercentage >= threshold) return 'Average';
    return 'Low';
  }

  int getClassesToAttend(double threshold) {
    if (attendancePercentage >= threshold) return 0;
    // Calculate classes needed to reach the threshold
    final thresholdFraction = threshold / 100;
    return ((thresholdFraction * totalClasses - attendedClasses) / (1 - thresholdFraction)).ceil();
  }
}
