class DatewiseAttendanceEntry {
  final String date;
  final List<SubjectAttendance> subjects;

  DatewiseAttendanceEntry({
    required this.date,
    required this.subjects,
  });

  factory DatewiseAttendanceEntry.fromJson(Map<String, dynamic> json) {
    final subjectsData = json['data'] as List<dynamic>? ?? [];
    final subjects = subjectsData.map((subjectMap) {
      final subject = subjectMap as Map<String, dynamic>;
      final subjectName = subject.keys.first;
      final status = subject[subjectName];
      return SubjectAttendance(
        subjectName: subjectName,
        status: status,
      );
    }).toList();

    return DatewiseAttendanceEntry(
      date: json['date'] ?? '',
      subjects: subjects,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'data': subjects.map((s) => {s.subjectName: s.status}).toList(),
    };
  }
}

class SubjectAttendance {
  final String subjectName;
  final String status; // 'P' for Present, 'A' for Absent, 'L' for Leave, etc.

  SubjectAttendance({
    required this.subjectName,
    required this.status,
  });

  bool get isPresent => status == 'P' || status == 'L';
  bool get isAbsent => status == 'A';
  
  String get statusText {
    switch (status) {
      case 'P':
        return 'Present';
      case 'A':
        return 'Absent';
      case 'L':
        return 'Leave';
      default:
        return status;
    }
  }
}
