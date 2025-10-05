import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../providers/attendance_provider.dart';
import '../models/datewise_attendance.dart';

class DatewiseAttendanceScreen extends StatefulWidget {
  const DatewiseAttendanceScreen({super.key});

  @override
  State<DatewiseAttendanceScreen> createState() =>
      _DatewiseAttendanceScreenState();
}

class _DatewiseAttendanceScreenState extends State<DatewiseAttendanceScreen> {
  bool _sortNewestFirst =
      true; // Default: newest first to show recent attendance

  // Parse date format like "25 Aug 2025" to DateTime
  DateTime _parseDate(String dateStr) {
    try {
      // Handle format like "25 Aug 2025"
      final parts = dateStr.trim().split(' ');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final monthStr = parts[1];
        final year = int.parse(parts[2]);

        // Map month abbreviations to numbers
        const monthMap = {
          'Jan': 1,
          'Feb': 2,
          'Mar': 3,
          'Apr': 4,
          'May': 5,
          'Jun': 6,
          'Jul': 7,
          'Aug': 8,
          'Sep': 9,
          'Oct': 10,
          'Nov': 11,
          'Dec': 12,
        };

        final month = monthMap[monthStr];
        if (month != null) {
          return DateTime(year, month, day);
        }
      }

      // Fallback: try standard DateTime.parse
      return DateTime.parse(dateStr);
    } catch (e) {
      debugPrint('Failed to parse date: $dateStr - $e');
      // Return a default date if parsing fails
      return DateTime.now();
    }
  }

  @override
  void initState() {
    super.initState();

    // Load date-wise attendance data (cache first, then refresh if needed)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AttendanceProvider>();
      debugPrint(
        'DatewiseAttendanceScreen initState - isLoggedIn: ${provider.isLoggedIn}',
      );
      provider.loadDatewiseAttendance();

      // Also try to force fetch if logged in and no data
      if (provider.isLoggedIn && provider.datewiseAttendance.isEmpty) {
        debugPrint(
          'DatewiseAttendanceScreen: Force fetching datewise attendance',
        );
        provider.fetchDatewiseAttendance();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          'Date-wise Attendance',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.blue),
        actions: [
          // Filter/Sort button
          IconButton(
            icon: Icon(
              _sortNewestFirst ? Iconsax.arrow_down_1 : Iconsax.arrow_up_2,
            ),
            tooltip: _sortNewestFirst
                ? 'Sort: Newest First'
                : 'Sort: Oldest First',
            onPressed: () {
              setState(() {
                _sortNewestFirst = !_sortNewestFirst;
              });
            },
          ),

          // Debug button to manually fetch datewise attendance
        ],
      ),
      body: Consumer<AttendanceProvider>(
        builder: (context, provider, child) {
          // Do not block the entire screen while attendance refreshes in background.
          // Show cached data immediately and an inline loader when provider.isDatewiseLoading.
          return Column(
            children: [
              if (provider.isDatewiseLoading)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 6,
                  ),
                  child: const Row(
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Text('Refreshing attendance...'),
                    ],
                  ),
                ),
              // Show offline indicator if using cached data
              if (provider.datewiseError != null &&
                  provider.datewiseError!.contains('offline'))
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  margin: const EdgeInsets.only(bottom: 8),
                  color: Colors.orange.shade50,
                  child: Row(
                    children: [
                      Icon(
                        Icons.cloud_off_outlined,
                        size: 16,
                        color: Colors.orange.shade700,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          provider.datewiseError!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ),
                      Text(
                        'Pull to refresh',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.orange.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(child: _buildDailyView(provider.datewiseAttendance)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDailyView(List<DatewiseAttendanceEntry> datewiseData) {
    if (datewiseData.isEmpty) {
      return Consumer<AttendanceProvider>(
        builder: (context, provider, child) {
          // Check if user is logged in
          if (!provider.isLoggedIn) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.login, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'Please log in first',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Go to Settings and log in to view attendance data',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            );
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text(
                  'No date-wise attendance data',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pull down to refresh',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          );
        },
      );
    }

    return Consumer<AttendanceProvider>(
      builder: (context, provider, child) {
        // Sort the data based on the current sort preference
        final sortedData = List<DatewiseAttendanceEntry>.from(datewiseData);
        sortedData.sort((a, b) {
          try {
            // Handle date format like "25 Aug 2025"
            final dateA = _parseDate(a.date);
            final dateB = _parseDate(b.date);
            if (_sortNewestFirst) {
              return dateB.compareTo(dateA); // Newest first
            } else {
              return dateA.compareTo(dateB); // Oldest first
            }
          } catch (e) {
            debugPrint('Error parsing dates: ${a.date}, ${b.date} - $e');
            // Fallback to string comparison if date parsing fails
            if (_sortNewestFirst) {
              return b.date.compareTo(a.date);
            } else {
              return a.date.compareTo(b.date);
            }
          }
        });

        return RefreshIndicator(
          onRefresh: () async {
            if (provider.isLoggedIn) {
              await context
                  .read<AttendanceProvider>()
                  .fetchDatewiseAttendance();
            }
          },
          color: const Color(0xFF10B981),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedData.length,
            itemBuilder: (context, index) {
              final entry = sortedData[index];
              return _buildDateCard(entry);
            },
          ),
        );
      },
    );
  }

  Widget _buildDateCard(DatewiseAttendanceEntry entry) {
    final presentCount = entry.subjects.where((s) => s.isPresent).length;
    final totalCount = entry.subjects.length;
    final attendancePercentage = totalCount > 0
        ? (presentCount / totalCount) * 100
        : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: _getDateCardBorderColor(attendancePercentage),
          width: 1,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(20),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getDateCardColor(attendancePercentage),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.calendar_today_rounded,
              color: _getDateCardIconColor(attendancePercentage),
              size: 20,
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.date,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$totalCount ${totalCount == 1 ? 'lecture' : 'lectures'}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              // Summary stats
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getPercentageBackgroundColor(
                        attendancePercentage,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${attendancePercentage.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _getPercentageTextColor(attendancePercentage),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$presentCount/$totalCount',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ],
          ),
          children: [
            const SizedBox(height: 8),
            // Subjects list
            ...entry.subjects.asMap().entries.map((mapEntry) {
              final idx = mapEntry.key;
              final subject = mapEntry.value;
              final isLast = idx == entry.subjects.length - 1;

              return Container(
                margin: EdgeInsets.only(bottom: isLast ? 0 : 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: subject.isPresent
                      ? const Color(0xFF10B981).withOpacity(0.05)
                      : const Color(0xFFEF4444).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: subject.isPresent
                        ? const Color(0xFF10B981).withOpacity(0.1)
                        : const Color(0xFFEF4444).withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    // Status icon
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: subject.isPresent
                            ? const Color(0xFF10B981).withOpacity(0.1)
                            : const Color(0xFFEF4444).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        subject.isPresent
                            ? Icons.check_circle_rounded
                            : Icons.cancel_rounded,
                        color: subject.isPresent
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Subject name
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subject.subjectName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subject.isPresent ? 'Present' : 'Absent',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: subject.isPresent
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFEF4444),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: subject.isPresent
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        subject.statusText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Color _getDateCardBorderColor(double percentage) {
    if (percentage >= 75) return const Color(0xFF10B981).withOpacity(0.2);
    if (percentage >= 50) return const Color(0xFFF59E0B).withOpacity(0.2);
    return const Color(0xFFEF4444).withOpacity(0.2);
  }

  Color _getDateCardColor(double percentage) {
    if (percentage >= 75) return const Color(0xFF10B981).withOpacity(0.1);
    if (percentage >= 50) return const Color(0xFFF59E0B).withOpacity(0.1);
    return const Color(0xFFEF4444).withOpacity(0.1);
  }

  Color _getDateCardIconColor(double percentage) {
    if (percentage >= 75) return const Color(0xFF10B981);
    if (percentage >= 50) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  Color _getPercentageBackgroundColor(double percentage) {
    if (percentage >= 75) return const Color(0xFF10B981).withOpacity(0.1);
    if (percentage >= 50) return const Color(0xFFF59E0B).withOpacity(0.1);
    return const Color(0xFFEF4444).withOpacity(0.1);
  }

  Color _getPercentageTextColor(double percentage) {
    if (percentage >= 75) return const Color(0xFF10B981);
    if (percentage >= 50) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }
}
