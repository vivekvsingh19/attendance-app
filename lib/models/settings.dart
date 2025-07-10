import 'package:flutter/material.dart';

class AttendanceSettings {
  final double attendanceThreshold;
  final String studentId;
  final bool reminderEnabled;
  final TimeOfDay reminderTime;

  const AttendanceSettings({
    this.attendanceThreshold = 75.0,
    this.studentId = '',
    this.reminderEnabled = true,
    this.reminderTime = const TimeOfDay(hour: 8, minute: 0),
  });

  AttendanceSettings copyWith({
    double? attendanceThreshold,
    String? studentId,
    bool? reminderEnabled,
    TimeOfDay? reminderTime,
  }) {
    return AttendanceSettings(
      attendanceThreshold: attendanceThreshold ?? this.attendanceThreshold,
      studentId: studentId ?? this.studentId,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attendanceThreshold': attendanceThreshold,
      'studentId': studentId,
      'reminderEnabled': reminderEnabled,
      'reminderTime': {
        'hour': reminderTime.hour,
        'minute': reminderTime.minute,
      },
    };
  }

  factory AttendanceSettings.fromJson(Map<String, dynamic> json) {
    return AttendanceSettings(
      attendanceThreshold: json['attendanceThreshold']?.toDouble() ?? 75.0,
      studentId: json['studentId'] ?? '',
      reminderEnabled: json['reminderEnabled'] ?? true,
      reminderTime: json['reminderTime'] != null
          ? TimeOfDay(
              hour: json['reminderTime']['hour'] ?? 8,
              minute: json['reminderTime']['minute'] ?? 0,
            )
          : const TimeOfDay(hour: 8, minute: 0),
    );
  }

  @override
  String toString() {
    return 'AttendanceSettings(attendanceThreshold: $attendanceThreshold, studentId: $studentId, reminderEnabled: $reminderEnabled, reminderTime: $reminderTime)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AttendanceSettings &&
        other.attendanceThreshold == attendanceThreshold &&
        other.studentId == studentId &&
        other.reminderEnabled == reminderEnabled &&
        other.reminderTime == reminderTime;
  }

  @override
  int get hashCode {
    return attendanceThreshold.hashCode ^
        studentId.hashCode ^
        reminderEnabled.hashCode ^
        reminderTime.hashCode;
  }
}
