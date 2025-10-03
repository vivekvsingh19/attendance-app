class AttendanceData {
  final String subject;
  final int total;
  final int attended;
  final double percentage;

  AttendanceData({
    required this.subject,
    required this.total,
    required this.attended,
    required this.percentage,
  });

  factory AttendanceData.fromJson(String subject, Map<String, dynamic> json) {
    return AttendanceData(
      subject: subject,
      total: json['total']?.toInt() ?? 0,
      attended: json['attended']?.toInt() ?? 0,
      percentage: (json['percentage']?.toDouble() ?? 0.0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subject': subject,
      'total': total,
      'attended': attended,
      'percentage': percentage,
    };
  }

  bool isLowAttendance(double threshold) => percentage < threshold;
  
  String get attendanceStatus {
    if (percentage >= 90) return 'Excellent';
    if (percentage >= 80) return 'Good';
    if (percentage >= 75) return 'Average';
    return 'Low';
  }
}

class AttendanceResponse {
  final bool success;
  final String message;
  final Map<String, AttendanceData>? data;

  AttendanceResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory AttendanceResponse.fromJson(Map<String, dynamic> json) {
    Map<String, AttendanceData>? attendanceData;
    
    if (json['data'] != null) {
      attendanceData = <String, AttendanceData>{};
      (json['data'] as Map<String, dynamic>).forEach((key, value) {
        attendanceData![key] = AttendanceData.fromJson(key, value);
      });
    }

    return AttendanceResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: attendanceData,
    );
  }
}
