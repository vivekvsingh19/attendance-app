import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../providers/attendance_provider.dart';
import 'projected_attendance_screen.dart';
import 'package:table_calendar/table_calendar.dart';

class BunkCalendarScreen extends StatefulWidget {
  const BunkCalendarScreen({Key? key}) : super(key: key);

  @override
  State<BunkCalendarScreen> createState() => _BunkCalendarScreenState();
}

class _BunkCalendarScreenState extends State<BunkCalendarScreen> {
  bool _calendarExpanded = true;
  // Timetable: Map weekday (1=Mon, 7=Sun) to list of subject names
  Map<int, List<String>> _timetable = {
    1: [], 2: [], 3: [], 4: [], 5: [], 6: [], 7: []
  };
  // Academic holidays: Set of DateTime (yyyy-mm-dd)
  final Set<DateTime> _academicHolidays = {
    DateTime(2025, 10, 2),
    DateTime(2025, 10, 18),
    DateTime(2025, 10, 19),
    DateTime(2025, 10, 20),
    DateTime(2025, 10, 21),
    DateTime(2025, 10, 22),
    DateTime(2025, 10, 23),
    DateTime(2025, 11, 5),
  };

  // Helper to get subject names for a given date
  List<String> _subjectsForDate(DateTime date, List subjects) {
    final weekday = date.weekday;
    return _timetable[weekday] ?? [];
  }

  // Helper to check if a date is an academic holiday
  bool _isAcademicHoliday(DateTime date) {
    return _academicHolidays.any((d) => _isSameDay(d, date));
  }

  // Dialog to edit timetable
  void _showEditTimetableDialog(List subjects) async {
    // Use a local dialog state for selection, persistently
    // Use a local dialog state for selection, persistently for the dialog
    List<List<String>> dialogTimetable = List.generate(6, (i) => List<String>.from(_timetable[i + 1] ?? []));
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                constraints: const BoxConstraints(maxWidth: 400, maxHeight: 520),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.edit_calendar, color: Color(0xFF1B7EE6)),
                        SizedBox(width: 8),
                        Text('Edit Timetable', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Select subjects for each weekday. This will apply to all weeks.',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.separated(
                        itemCount: 6,
                        separatorBuilder: (_, __) => const Divider(height: 18, thickness: 0.7),
                        itemBuilder: (context, i) {
                          final weekdayName = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"][i];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(weekdayName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF1B7EE6))),
                                  const Spacer(),
                                  if (dialogTimetable[i].isNotEmpty)
                                    TextButton(
                                      onPressed: () {
                                        setDialogState(() {
                                          dialogTimetable[i] = [];
                                        });
                                      },
                                      child: const Text('Clear All', style: TextStyle(fontSize: 12)),
                                    ),
                                ],
                              ),
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: subjects.map<Widget>((subj) {
                                  final selected = dialogTimetable[i].contains(subj.name);
                                  return FilterChip(
                                    label: Text(subj.name),
                                    selected: selected,
                                    selectedColor: const Color(0xFF1B7EE6).withOpacity(0.18),
                                    checkmarkColor: const Color(0xFF1B7EE6),
                                    backgroundColor: Colors.grey[100],
                                    labelStyle: TextStyle(color: selected ? const Color(0xFF1B7EE6) : Colors.black87, fontWeight: selected ? FontWeight.bold : FontWeight.normal),
                                    onSelected: (val) {
                                      setDialogState(() {
                                        if (val) {
                                          dialogTimetable[i].add(subj.name);
                                        } else {
                                          dialogTimetable[i].remove(subj.name);
                                        }
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1B7EE6),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {
                            setState(() {
                              for (int i = 0; i < 7; i++) {
                                _timetable[i + 1] = List<String>.from(dialogTimetable[i]);
                              }
                            });
                            Navigator.pop(context);
                          },
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Dialog to edit academic holidays
  void _showEditAcademicHolidaysDialog() async {
    DateTime? picked;
    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            constraints: const BoxConstraints(maxWidth: 380),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.holiday_village, color: Colors.deepOrange),
                      SizedBox(width: 8),
                      Text('Academic Holidays', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Holiday'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () async {
                      picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() {
                          _academicHolidays.add(DateTime(picked!.year, picked!.month, picked!.day));
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 14),
                  if (_academicHolidays.isEmpty)
                    const Text('No academic holidays added yet.', style: TextStyle(color: Colors.grey)),
                  ..._academicHolidays.map((d) => Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: Colors.orange[50],
                        child: ListTile(
                          leading: const Icon(Icons.event, color: Colors.deepOrange),
                          title: Text('${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}', style: const TextStyle(fontWeight: FontWeight.w600)),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _academicHolidays.removeWhere((h) => _isSameDay(h, d));
                              });
                            },
                          ),
                        ),
                      )),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  final Set<DateTime> _bunkDates = {};
  final Set<DateTime> _holidayDates = {};
  DateTime _focusedDay = DateTime.now();

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isWeekend(DateTime day) {
    return day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bunk Calendar'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1B7EE6),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF1B7EE6)),
        titleTextStyle: const TextStyle(
          color: Color(0xFF1B7EE6),
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Color(0xFF1B7EE6)),
            onSelected: (value) {
              final subjects = Provider.of<AttendanceProvider>(context, listen: false).subjects;
              if (value == 'timetable') {
                _showEditTimetableDialog(subjects);
              } else if (value == 'holidays') {
                _showEditAcademicHolidaysDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'timetable',
                child: ListTile(
                  leading: Icon(Icons.edit_calendar, color: Color(0xFF1B7EE6)),
                  title: Text('Edit Timetable'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'holidays',
                child: ListTile(
                  leading: Icon(Icons.holiday_village, color: Colors.deepOrange),
                  title: Text('Academic Holidays'),
                ),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body: Consumer<AttendanceProvider>(
        builder: (context, provider, child) {
          final subjects = provider.subjects;
          final themeBlue = const Color(0xFF1B7EE6);
          return Column(
            children: [
              // Removed Timetable and Academic Holidays buttons from main screen
              const SizedBox(height: 1),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: themeBlue.withOpacity(0.07),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                   
                    if (_calendarExpanded) ...[
                      const SizedBox(height: 6),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: TableCalendar(
                          firstDay: DateTime.now(),
                          lastDay: DateTime.now().add(const Duration(days: 365)),
                          focusedDay: _focusedDay,
                          selectedDayPredicate: (_) => false, // Disable single-date selection
                          calendarFormat: CalendarFormat.month,
                          daysOfWeekHeight: 30,
                          rowHeight: 38,
                          onDaySelected: (selectedDay, focusedDay) {
                            setState(() {
                              _focusedDay = focusedDay;
                              // Prevent marking weekends
                              if (_isWeekend(selectedDay)) return;
                              // Only allow future dates
                              if (selectedDay.isAfter(DateTime.now().subtract(const Duration(days: 1)))) {
                                // If already a holiday, do nothing on tap
                                if (_holidayDates.any((d) => _isSameDay(d, selectedDay)) || _isAcademicHoliday(selectedDay)) return;
                                final alreadyBunked = _bunkDates.any((d) => _isSameDay(d, selectedDay));
                                if (alreadyBunked) {
                                  _bunkDates.removeWhere((d) => _isSameDay(d, selectedDay));
                                } else {
                                  _bunkDates.add(selectedDay);
                                }
                              }
                            });
                          },
                          onDayLongPressed: (selectedDay, focusedDay) {
                            setState(() {
                              _focusedDay = focusedDay;
                              // Prevent marking weekends
                              if (_isWeekend(selectedDay)) return;
                              if (selectedDay.isAfter(DateTime.now().subtract(const Duration(days: 1)))) {
                                final alreadyHoliday = _holidayDates.any((d) => _isSameDay(d, selectedDay));
                                if (alreadyHoliday) {
                                  _holidayDates.removeWhere((d) => _isSameDay(d, selectedDay));
                                } else {
                                  // Remove from bunks if present
                                  _bunkDates.removeWhere((d) => _isSameDay(d, selectedDay));
                                  _holidayDates.add(selectedDay);
                                }
                              }
                            });
                          },
                          calendarStyle: CalendarStyle(
                            todayDecoration: BoxDecoration(
                              color: themeBlue.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            selectedDecoration: const BoxDecoration(), // No highlight for selected
                            weekendTextStyle: TextStyle(color: themeBlue.withOpacity(0.7)),
                            outsideDaysVisible: false,
                            cellMargin: const EdgeInsets.all(2),
                            cellPadding: const EdgeInsets.all(0),
                          ),
                          headerStyle: HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                            headerPadding: const EdgeInsets.symmetric(vertical: 4),
                            headerMargin: const EdgeInsets.only(bottom: 4),
                            titleTextStyle: TextStyle(
                              color: themeBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            leftChevronIcon: Icon(Icons.chevron_left, color: themeBlue, size: 20),
                            rightChevronIcon: Icon(Icons.chevron_right, color: themeBlue, size: 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          daysOfWeekStyle: DaysOfWeekStyle(
                            weekdayStyle: TextStyle(color: themeBlue, fontWeight: FontWeight.w600, fontSize: 12),
                            weekendStyle: TextStyle(color: themeBlue.withOpacity(0.7), fontWeight: FontWeight.w600, fontSize: 12),
                          ),
                          calendarBuilders: CalendarBuilders(
                            defaultBuilder: (context, day, focusedDay) {
                              final isBunked = _bunkDates.any((d) => _isSameDay(d, day));
                              final isHoliday = _holidayDates.any((d) => _isSameDay(d, day)) || _isWeekend(day) || _isAcademicHoliday(day);
                              final isToday = _isSameDay(day, DateTime.now());
                              Color? bgColor;
                              Color? textColor;
                              FontWeight? fontWeight;
                              if (isHoliday) {
                                bgColor = Colors.grey.withOpacity(0.18); // subtle blur/grey
                                textColor = Colors.grey.shade700;
                                fontWeight = FontWeight.w600;
                              } else if (isBunked) {
                                bgColor = themeBlue;
                                textColor = Colors.white;
                                fontWeight = FontWeight.bold;
                              } else if (isToday) {
                                bgColor = themeBlue.withOpacity(0.15);
                                textColor = themeBlue;
                                fontWeight = FontWeight.bold;
                              }
                              return Container(
                                margin: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: bgColor,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Center(
                                  child: Text(
                                    '${day.day}',
                                    style: TextStyle(
                                      color: textColor,
                                      fontWeight: fontWeight,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    print('Projected Attendance tapped');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Opening Projected Attendance...')),
                    );
                    Future.delayed(const Duration(milliseconds: 300), () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProjectedAttendanceScreen(
                            bunkDates: _bunkDates,
                            holidayDates: _holidayDates,
                            academicHolidays: _academicHolidays,
                            timetable: _timetable,
                            subjects: subjects,
                            isWeekend: _isWeekend,
                            isSameDay: _isSameDay,
                            subjectsForDate: _subjectsForDate,
                            isAcademicHoliday: _isAcademicHoliday,
                          ),
                        ),
                      );
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 2),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF67C9F5), Color(0xFF1B7EE6)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.analytics_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Projected Attendance',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: themeBlue),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.view_list, size: 16),
                    label: const Text('Show Subjects'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        builder: (context) {
                          return SafeArea(
                            child: SizedBox(
                              height: 140,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                itemCount: subjects.length,
                                itemBuilder: (context, idx) {
                                  final subject = subjects[idx];
                                  final int total = subject.totalClasses;
                                  final int attended = subject.attendedClasses;
                                  final int effectiveBunks = _bunkDates.where((d) {
                                    if (_holidayDates.any((h) => _isSameDay(h, d)) || _isWeekend(d) || _isAcademicHoliday(d)) return false;
                                    final subjectNames = _subjectsForDate(d, subjects);
                                    return subjectNames.contains(subject.name);
                                  }).length;
                                  final int projectedTotal = total + effectiveBunks;
                                  final int projectedAttended = attended;
                                  final double projectedPercent = projectedTotal == 0 ? 0 : (projectedAttended / projectedTotal) * 100;
                                  final double actualPercent = subject.attendancePercentage;
                                  // Color logic from SubjectCard
                                  final double threshold = provider.settings.attendanceThreshold;
                                  Color getStatusColor(double percent) {
                                    if (percent >= threshold + 10) return Colors.green;
                                    if (percent >= threshold) return Colors.yellow[700]!;
                                    return Colors.red;
                                  }
                                  final Color actualColor = getStatusColor(actualPercent);
                                  final Color projectedColor = getStatusColor(projectedPercent);
                                  final Color iconBgColor = actualColor.withOpacity(0.13);
                                  return Container(
                                    width: 200,
                                    margin: const EdgeInsets.only(right: 12),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: themeBlue.withOpacity(0.06),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                      border: Border.all(
                                        color: projectedColor.withOpacity(0.15),
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: iconBgColor,
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Icon(Icons.book_rounded, color: actualColor, size: 16),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                subject.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF1E293B),
                                                  fontSize: 14,
                                                  letterSpacing: -0.2,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Actual',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: actualColor,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                Text(
                                                  '${actualPercent.toStringAsFixed(1)}%',
                                                  style: TextStyle(
                                                    color: actualColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Projected',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: projectedColor,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                Text(
                                                  '${projectedPercent.toStringAsFixed(1)}%',
                                                  style: TextStyle(
                                                    color: projectedColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
