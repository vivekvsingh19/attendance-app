class DailyAttendanceSummary {
  final String date;
  final int present;
  final int totalLectures;
  final double percentage;

  DailyAttendanceSummary({
    required this.date,
    required this.present,
    required this.totalLectures,
    required this.percentage,
  });

  factory DailyAttendanceSummary.fromJson(Map<String, dynamic> json) {
    return DailyAttendanceSummary(
      date: json['date'] ?? '',
      present: json['present']?.toInt() ?? 0,
      totalLectures: json['totalLectures']?.toInt() ?? 0,
      percentage: (json['percentage']?.toDouble() ?? 0.0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'present': present,
      'totalLectures': totalLectures,
      'percentage': percentage,
    };
  }

  String get attendanceStatus {
    if (percentage >= 90) return 'Excellent';
    if (percentage >= 80) return 'Good';
    if (percentage >= 75) return 'Average';
    return 'Low';
  }

  bool isLowAttendance(double threshold) => percentage < threshold;
}
