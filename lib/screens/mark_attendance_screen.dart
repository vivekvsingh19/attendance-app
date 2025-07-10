import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/attendance_provider.dart';

class MarkAttendanceScreen extends StatefulWidget {
  const MarkAttendanceScreen({super.key});

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  String? selectedSubject;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mark Attendance',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.indigo,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<AttendanceProvider>(
        builder: (context, provider, child) {
          if (provider.attendanceList.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.class_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No subjects available',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Subject',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Subject Selection
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedSubject,
                      hint: const Text('Choose a subject'),
                      isExpanded: true,
                      items: provider.attendanceList.map((attendance) {
                        return DropdownMenuItem<String>(
                          value: attendance.subject,
                          child: Text(attendance.subject),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedSubject = value;
                        });
                      },
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Selected Subject Details
                if (selectedSubject != null) ...[
                  const Text(
                    'Current Status',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Builder(
                    builder: (context) {
                      final attendance = provider.getAttendanceForSubject(selectedSubject!);
                      if (attendance == null) return const SizedBox.shrink();
                      
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Total Classes',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    attendance.total.toString(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Attended',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    attendance.attended.toString(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Percentage',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    '${attendance.percentage.toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: attendance.isLowAttendance ? Colors.red : Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _markAttendance(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.check_circle),
                          label: const Text(
                            'Mark Present',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _markAttendance(false),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.cancel),
                          label: const Text(
                            'Mark Absent',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  void _markAttendance(bool isPresent) {
    if (selectedSubject == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isPresent ? 'Mark Present' : 'Mark Absent'),
        content: Text(
          'Are you sure you want to mark yourself ${isPresent ? 'present' : 'absent'} for $selectedSubject?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _confirmMarkAttendance(isPresent);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _confirmMarkAttendance(bool isPresent) {
    // In a real app, you would send this data to the backend
    // For now, we'll just show a success message
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Attendance marked ${isPresent ? 'present' : 'absent'} for $selectedSubject',
        ),
        backgroundColor: isPresent ? Colors.green : Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
    
    // Reset selection
    setState(() {
      selectedSubject = null;
    });
  }
}
