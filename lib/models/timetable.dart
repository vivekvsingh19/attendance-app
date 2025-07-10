class TimeTable {
  final String day;
  final List<TimeSlot> timeSlots;

  TimeTable({
    required this.day,
    required this.timeSlots,
  });
}

class TimeSlot {
  final String time;
  final String subject;
  final String room;
  final String faculty;

  TimeSlot({
    required this.time,
    required this.subject,
    required this.room,
    required this.faculty,
  });
}
