import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import '../providers/attendance_provider.dart';
import '../providers/announcement_provider.dart';
import '../widgets/subject_card.dart';
import '../utils/colors.dart';
import '../utils/share_helper.dart';
import '../models/subject.dart';
import 'gpa_calculator_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Auto-refresh announcements when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnnouncementProvider>().refreshIfNeeded();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Header with branding and overall percentage
            Container(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  // Container(
                  // padding: const EdgeInsets.all(8),
                  // decoration: BoxDecoration(
                  //  borderRadius: BorderRadius.circular(12),
                  // ),
                  Image.asset('assets/images/75+.png', width: 34, height: 34),
                  //),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'उपस्थित (UPASTHIT)',
                          style: GoogleFonts.inknutAntiqua(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E293B),
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'By Vivek Singh',
                          style: GoogleFonts.inriaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color.fromARGB(255, 37, 120, 197),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Share button
                  Consumer<AttendanceProvider>(
                    builder: (context, provider, child) {
                      return IconButton(
                        onPressed:
                            () =>
                                ShareHelper.showShareOptions(context, provider),
                        icon: const Icon(Icons.share_rounded),
                        style: IconButton.styleFrom(
                          // backgroundColor: const Color(0xFF667EEA).withOpacity(0.1),
                          foregroundColor: const Color(0xFF667EEA),
                          padding: const EdgeInsets.all(12),
                        ),
                        tooltip: 'Share Options',
                      );
                    },
                  ),
                ],
              ),
            ),

            // Floating Announcement Banner
            Consumer<AnnouncementProvider>(
              builder: (context, provider, child) {
                if (provider.announcements.isEmpty) {
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 6,
                    ),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.shade200,
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.notifications_none,
                          color: Colors.grey.shade400,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'All caught up! No new announcements.',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final latestAnnouncement = provider.announcements.first;
                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 6,
                  ),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade100, width: 0.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.campaign_outlined,
                          color: Colors.blue.shade600,
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    latestAnnouncement.title,
                                    style: TextStyle(
                                      color: Colors.grey.shade800,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (latestAnnouncement.isImportant)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Important',
                                      style: TextStyle(
                                        color: Colors.red.shade600,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              latestAnnouncement.content,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatTimeAgo(latestAnnouncement.createdAt),
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 10,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // Main Content - Attendance
            Expanded(
              child: Consumer<AttendanceProvider>(
                builder: (context, provider, child) {
                  // Do not block the entire screen while attendance refreshes in background.
                  // Show cached data immediately and an inline loader when provider.isLoading.
                  return Column(
                    children: [
                      if (provider.isLoading)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 6,
                          ),
                          child: Row(
                            children: const [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('Refreshing attendance...'),
                            ],
                          ),
                        ),
                      // Show offline indicator if using cached data
                      if (provider.error != null &&
                          provider.error!.contains('offline'))
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
                                  provider.error!,
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
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            // Force refresh attendance data from server
                            await provider.forceRefreshFromServer();
                            // Also refresh announcements
                            final announcementProvider =
                                context.read<AnnouncementProvider>();
                            await announcementProvider.fetchAnnouncements();
                          },
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Quick View Stats
                                _buildQuickViewStats(provider, context),
                                const SizedBox(height: 16),
                                // Calculator Cards Row
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildStatCard(
                                        title: 'Calculator',
                                        value: '',
                                        color: const Color(0xFF9F7AEA),
                                        icon: Icons.calculate_outlined,
                                        onTap: () => _showCalculator(context),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildStatCard(
                                        title: 'GPA Calculator',
                                        value: '',
                                        color: const Color(0xFF4FC3F7),
                                        icon: Icons.grade_rounded,
                                        onTap:
                                            () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (context) =>
                                                        GPACalculatorScreen(),
                                              ),
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Date-wise Attendance Card
                                // Row(
                                //   children: [
                                //     Expanded(
                                //       child: _buildStatCard(
                                //         title: 'Date-wise Attendance',
                                //         value: '',
                                //         color: const Color(0xFF10B981),
                                //         icon: Icons.calendar_month_rounded,
                                //         onTap: () => Navigator.push(
                                //           context,
                                //           MaterialPageRoute(builder: (context) => const DatewiseAttendanceScreen()),
                                //         ),
                                //       ),
                                //     ),
                                //   ],
                                // ),
                                const SizedBox(height: 32),
                                // Visual Graph Section
                                _buildAttendanceGraph(provider),
                                const SizedBox(height: 32),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickViewStats(
    AttendanceProvider provider,
    BuildContext context,
  ) {
    final threshold = provider.settings.attendanceThreshold;
    final percentage = provider.overallAttendancePercentage;
    final totalSubjects = provider.subjects.length;
    final criticalSubjects =
        provider.subjects
            .where((subject) => subject.attendancePercentage < threshold)
            .length;
    final safeBunks = provider.totalSafeBunks;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          // Row(
          //   children: [
          //     Container(
          //       padding: const EdgeInsets.all(10),
          //       decoration: BoxDecoration(
          //         gradient: const LinearGradient(
          //           colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          //           begin: Alignment.topLeft,
          //           end: Alignment.bottomRight,
          //         ),
          //         borderRadius: BorderRadius.circular(12),
          //       ),
          //       child: const Icon(
          //         Icons.analytics_rounded,
          //         color: Colors.white,
          //         size: 20,
          //       ),
          //     ),
          //     const SizedBox(width: 16),
          //     // const Text(
          //     //   'Quick Overview',
          //     //   style: TextStyle(
          //     //     fontSize: 18,
          //     //     fontWeight: FontWeight.w700,
          //     //     color: Color(0xFF1E293B),
          //     //     letterSpacing: -0.3,
          //     //   ),
          //     // ),
          //   ],
          // ),
          // const SizedBox(height: 24),

          // Overall Attendance - Horizontal Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.getAttendanceColor(
                    percentage,
                    threshold,
                  ).withOpacity(0.1),
                  AppColors.getAttendanceColor(
                    percentage,
                    threshold,
                  ).withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.getAttendanceColor(
                  percentage,
                  threshold,
                ).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  percentage >= threshold
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  color: AppColors.getAttendanceColor(percentage, threshold),
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Overall Attendance',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.getAttendanceColor(
                            percentage,
                            threshold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.getAttendanceColor(
                      percentage,
                      threshold,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    percentage >= threshold ? 'Good' : 'Critical',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.getAttendanceColor(
                        percentage,
                        threshold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Three Stats Row
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Total Subjects',
                  value: '$totalSubjects',
                  color: const Color(0xFF667EEA),
                  icon: Icons.auto_stories_rounded,
                  onTap: () => _showAllSubjects(context, provider),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'Critical Subjects',
                  value: '$criticalSubjects',
                  color: const Color(0xFFEF4444),
                  icon: Icons.warning_rounded,
                  onTap: () => _showCriticalSubjects(context, provider),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'Safe Bunks',
                  value: '$safeBunks',
                  color: const Color(0xFF10B981),
                  icon: Icons.free_breakfast_rounded,
                  onTap: () => _showSafeBunksInfo(context, provider),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110, // Fixed height for consistency
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
          boxShadow:
              onTap != null
                  ? [
                    BoxShadow(
                      color: color.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            if (value.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showCalculator(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildCalculatorModal(context),
    );
  }

  Widget _buildCalculatorModal(BuildContext context) {
    String display = '0';
    String expression = '';
    String operation = '';
    double firstNumber = 0;
    double secondNumber = 0;
    bool isOperationPressed = false;
    bool showResult = false;

    return StatefulBuilder(
      builder: (context, setState) {
        String formatNumber(double number) {
          if (number == number.roundToDouble()) {
            return number.toInt().toString();
          }
          return number.toString();
        }

        void onButtonPressed(String buttonText) {
          setState(() {
            if (buttonText == 'C') {
              display = '0';
              expression = '';
              operation = '';
              firstNumber = 0;
              secondNumber = 0;
              isOperationPressed = false;
              showResult = false;
            } else if (buttonText == '+' ||
                buttonText == '-' ||
                buttonText == '×' ||
                buttonText == '÷') {
              if (operation.isNotEmpty && !isOperationPressed) {
                // Complete pending operation first
                secondNumber = double.parse(display);
                switch (operation) {
                  case '+':
                    firstNumber = firstNumber + secondNumber;
                    break;
                  case '-':
                    firstNumber = firstNumber - secondNumber;
                    break;
                  case '×':
                    firstNumber = firstNumber * secondNumber;
                    break;
                  case '÷':
                    firstNumber =
                        secondNumber != 0 ? firstNumber / secondNumber : 0;
                    break;
                }
                display = formatNumber(firstNumber);
                expression = '${formatNumber(firstNumber)} $buttonText ';
              } else {
                firstNumber = double.parse(display);
                expression = '${formatNumber(firstNumber)} $buttonText ';
              }
              operation = buttonText;
              isOperationPressed = true;
              showResult = false;
            } else if (buttonText == '=') {
              if (operation.isNotEmpty && !showResult) {
                secondNumber = double.parse(display);
                double result;
                switch (operation) {
                  case '+':
                    result = firstNumber + secondNumber;
                    break;
                  case '-':
                    result = firstNumber - secondNumber;
                    break;
                  case '×':
                    result = firstNumber * secondNumber;
                    break;
                  case '÷':
                    result = secondNumber != 0 ? firstNumber / secondNumber : 0;
                    break;
                  default:
                    result = 0;
                }
                
                if (result.isInfinite || result.isNaN) {
                  display = 'Error';
                  expression = '';
                } else {
                  display = formatNumber(result);
                  expression = '${formatNumber(firstNumber)} $operation ${formatNumber(secondNumber)} =';
                }
                
                operation = '';
                firstNumber = result.isInfinite || result.isNaN ? 0 : result;
                isOperationPressed = false;
                showResult = true;
              }
            } else if (buttonText == '.') {
              if (!display.contains('.')) {
                if (isOperationPressed || display == '0' || showResult) {
                  display = '0.';
                  isOperationPressed = false;
                  showResult = false;
                } else {
                  display += '.';
                }
              }
            } else if (buttonText == '⌫') {
              // Backspace functionality
              if (display.length > 1 && display != '0') {
                display = display.substring(0, display.length - 1);
              } else {
                display = '0';
              }
              showResult = false;
            } else {
              // Number button pressed
              if (isOperationPressed || display == '0' || showResult) {
                display = buttonText;
                isOperationPressed = false;
                showResult = false;
              } else {
                display += buttonText;
              }
            }
          });
        }

        Widget buildButton(String text, {Color? color, Color? textColor}) {
          return Expanded(
            child: Container(
              height: 60,
              margin: const EdgeInsets.all(4),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: color ?? Colors.grey.shade100,
                  foregroundColor: textColor ?? Colors.black87,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: () => onButtonPressed(text),
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }

        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.8,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Handle bar
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF9F7AEA).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.calculate_outlined,
                                color: Color(0xFF9F7AEA),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Calculator',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close_rounded),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Calculator display
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Expression history (small text)
                        if (expression.isNotEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              expression,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.right,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        // Main display (large text)
                        Text(
                          display,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Calculator buttons
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          // Row 1: C, ⌫, ÷, ×
                          Row(
                            children: [
                              buildButton(
                                'C',
                                color: Colors.red.shade100,
                                textColor: Colors.red.shade700,
                              ),
                              buildButton(
                                '⌫',
                                color: Colors.orange.shade100,
                                textColor: Colors.orange.shade700,
                              ),
                              buildButton(
                                '÷',
                                color: const Color(0xFF9F7AEA).withOpacity(0.1),
                                textColor: const Color(0xFF9F7AEA),
                              ),
                              buildButton(
                                '×',
                                color: const Color(0xFF9F7AEA).withOpacity(0.1),
                                textColor: const Color(0xFF9F7AEA),
                              ),
                            ],
                          ),
                          // Row 2: 7, 8, 9, -
                          Row(
                            children: [
                              buildButton('7'),
                              buildButton('8'),
                              buildButton('9'),
                              buildButton(
                                '-',
                                color: const Color(0xFF9F7AEA).withOpacity(0.1),
                                textColor: const Color(0xFF9F7AEA),
                              ),
                            ],
                          ),
                          // Row 3: 4, 5, 6, +
                          Row(
                            children: [
                              buildButton('4'),
                              buildButton('5'),
                              buildButton('6'),
                              buildButton(
                                '+',
                                color: const Color(0xFF9F7AEA).withOpacity(0.1),
                                textColor: const Color(0xFF9F7AEA),
                              ),
                            ],
                          ),
                          // Row 4: 1, 2, 3, =
                          Row(
                            children: [
                              buildButton('1'),
                              buildButton('2'),
                              buildButton('3'),
                              Expanded(
                                child: Container(
                                  height: 60,
                                  margin: const EdgeInsets.all(4),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF9F7AEA),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                    ),
                                    onPressed: () => onButtonPressed('='),
                                    child: const Text(
                                      '=',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Row 5: 0 (wide), ., (empty)
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Container(
                                  height: 60,
                                  margin: const EdgeInsets.all(4),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey.shade100,
                                      foregroundColor: Colors.black87,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                    ),
                                    onPressed: () => onButtonPressed('0'),
                                    child: const Text(
                                      '0',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              buildButton('.'),
                              const Expanded(child: SizedBox()),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  Widget _buildAttendanceGraph(AttendanceProvider provider) {
    if (provider.subjects.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.bar_chart_rounded,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No Data Available',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Attendance graph will appear here once you have subjects',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final threshold = provider.settings.attendanceThreshold;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Attendance Overview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Target: ${threshold.toInt()}%',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Scroll hint for many subjects
          if (provider.subjects.length > 6)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.swipe_left_rounded,
                    size: 16,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Swipe to view all subjects',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

          // Graph
          SizedBox(
            height: 180,
            child:
                provider.subjects.length <= 6
                    ? CustomPaint(
                      painter: AttendanceBarChartPainter(
                        provider.subjects,
                        threshold,
                      ),
                      size: const Size(double.infinity, 180),
                    )
                    : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width:
                            provider.subjects.length * 60.0, // 60px per subject
                        child: CustomPaint(
                          painter: AttendanceBarChartPainter(
                            provider.subjects,
                            threshold,
                          ),
                          size: Size(provider.subjects.length * 60.0, 180),
                        ),
                      ),
                    ),
          ),

          const SizedBox(height: 20),

          // Legend - Top performing subjects
          const Text(
            'Subject Performance',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),

          // Show top 3 subjects
          ...provider.subjects.take(3).map((subject) {
            final color = AppColors.getAttendanceColor(
              subject.attendancePercentage,
              threshold,
            );
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      subject.name,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                  Text(
                    '${subject.attendancePercentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              ),
            );
          }),

          if (provider.subjects.length > 3) ...[
            const SizedBox(height: 4),
            Text(
              '+${provider.subjects.length - 3} more subjects',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showAllSubjects(BuildContext context, AttendanceProvider provider) {
    if (provider.subjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No subjects available yet!'),
          backgroundColor: Color(0xFF667EEA),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => _buildSubjectsModal(
            context: context,
            title: 'All Subjects',
            subjects: provider.subjects,
            icon: Icons.auto_stories_rounded,
            color: const Color(0xFF667EEA),
          ),
    );
  }

  void _showCriticalSubjects(
    BuildContext context,
    AttendanceProvider provider,
  ) {
    final threshold = provider.settings.attendanceThreshold;
    final criticalSubjects =
        provider.subjects
            .where((subject) => subject.attendancePercentage < threshold)
            .toList();

    if (criticalSubjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Great! No subjects are below target attendance.'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => _buildSubjectsModal(
            context: context,
            title: 'Critical Subjects',
            subjects: criticalSubjects,
            icon: Icons.warning_rounded,
            color: const Color(0xFFEF4444),
            subtitle: 'Below ${threshold.toStringAsFixed(0)}% target',
          ),
    );
  }

  void _showSafeBunksInfo(BuildContext context, AttendanceProvider provider) {
    final threshold = provider.settings.attendanceThreshold;
    final safeBunkSubjects =
        provider.subjects
            .where((subject) => subject.attendancePercentage >= threshold)
            .toList();

    if (safeBunkSubjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No subjects have safe bunks available.'),
          backgroundColor: Color(0xFFF59E0B),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => _buildSafeBunksModal(
            context: context,
            subjects: safeBunkSubjects,
            threshold: threshold,
          ),
    );
  }

  Widget _buildSubjectsModal({
    required BuildContext context,
    required String title,
    required List<Subject> subjects,
    required IconData icon,
    required Color color,
    String? subtitle,
  }) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Handle bar
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(icon, color: color, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              if (subtitle != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  subtitle,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Subjects list
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: subjects.length,
                  itemBuilder: (context, index) {
                    final subject = subjects[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: SubjectCard(subject: subject),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSafeBunksModal({
    required BuildContext context,
    required List<Subject> subjects,
    required double threshold,
  }) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Handle bar
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.free_breakfast_rounded,
                            color: Color(0xFF10B981),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Safe Bunks Available',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Classes you can skip safely',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Safe bunks list
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: subjects.length,
                  itemBuilder: (context, index) {
                    final subject = subjects[index];
                    final safeBunks = _calculateSafeBunks(subject, threshold);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF10B981).withOpacity(0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.book_rounded,
                              color: Color(0xFF10B981),
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  subject.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${subject.attendancePercentage.toStringAsFixed(1)}% attendance',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF10B981,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  safeBunks > 0
                                      ? '$safeBunks bunks'
                                      : 'No bunks',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF10B981),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  int _calculateSafeBunks(Subject subject, double threshold) {
    if (subject.attendancePercentage < threshold) return 0;

    // Calculate how many classes can be bunked while staying above threshold
    final safeBunks =
        ((subject.attendedClasses * 100 - threshold * subject.totalClasses) /
                threshold)
            .floor();
    return safeBunks > 0 ? safeBunks : 0;
  }
}

class PieChartPainter extends CustomPainter {
  final List<Subject> subjects;
  final double threshold;

  PieChartPainter(this.subjects, this.threshold);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    final colors = [
      const Color(0xFF667EEA),
      const Color(0xFFEF4444),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFFEC4899),
      const Color(0xFF8B5CF6),
      const Color(0xFF06B6D4),
      const Color(0xFFF97316),
    ];

    double totalClasses = subjects.fold(
      0,
      (sum, subject) => sum + subject.totalClasses,
    );

    if (totalClasses == 0) {
      // Draw empty circle
      final paint =
          Paint()
            ..color = Colors.grey.shade300
            ..style = PaintingStyle.fill;
      canvas.drawCircle(center, radius, paint);
      return;
    }

    double startAngle = -pi / 2; // Start from top

    for (int i = 0; i < subjects.length; i++) {
      final subject = subjects[i];
      final sweepAngle = (subject.totalClasses / totalClasses) * 2 * pi;

      final paint =
          Paint()
            ..color = colors[i % colors.length]
            ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // Draw border
      final borderPaint =
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        borderPaint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class AttendanceBarChartPainter extends CustomPainter {
  final List<Subject> subjects;
  final double threshold;

  AttendanceBarChartPainter(this.subjects, this.threshold);

  @override
  void paint(Canvas canvas, Size size) {
    if (subjects.isEmpty) return;

    final paint = Paint()..style = PaintingStyle.fill;
    final borderPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = Colors.grey.shade300;

    const double padding = 20;
    const double bottomPadding = 40;
    final double availableWidth = size.width - (padding * 2);
    final double availableHeight = size.height - padding - bottomPadding;

    // Dynamic bar width based on number of subjects
    final double barWidth =
        subjects.length <= 6
            ? (availableWidth / subjects.length - 8).clamp(30, 80)
            : 40; // Fixed width for scrollable view

    final double spacing = subjects.length <= 6 ? 8 : 12;

    // Draw threshold line
    final thresholdY = padding + availableHeight * (1 - threshold / 100);
    final thresholdPaint =
        Paint()
          ..color = Colors.red.withOpacity(0.6)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(padding, thresholdY),
      Offset(size.width - padding, thresholdY),
      thresholdPaint,
    );

    // Draw threshold label
    final thresholdTextPainter = TextPainter(
      text: TextSpan(
        text: '${threshold.toInt()}%',
        style: TextStyle(
          color: Colors.red.withOpacity(0.8),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    thresholdTextPainter.layout();
    thresholdTextPainter.paint(
      canvas,
      Offset(size.width - padding - 30, thresholdY - 15),
    );

    // Draw bars
    for (int i = 0; i < subjects.length; i++) {
      final subject = subjects[i];
      final percentage = subject.attendancePercentage;
      final barHeight = availableHeight * (percentage / 100);
      final x = padding + (i * (barWidth + spacing));
      final y = padding + availableHeight - barHeight;

      // Determine bar color based on performance
      Color barColor;
      if (percentage >= threshold + 15) {
        barColor = const Color(0xFF059669); // Dark Green - Excellent
      } else if (percentage >= threshold + 5) {
        barColor = const Color(0xFF10B981); // Green - Very Good
      } else if (percentage >= threshold) {
        barColor = const Color(0xFF3B82F6); // Blue - Good
      } else if (percentage >= threshold - 10) {
        barColor = const Color(0xFFF59E0B); // Orange - Warning
      } else {
        barColor = const Color(0xFFEF4444); // Red - Critical
      }

      paint.color = barColor;

      // Draw bar with rounded top
      final barRect = RRect.fromRectAndCorners(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        topLeft: const Radius.circular(4),
        topRight: const Radius.circular(4),
      );

      canvas.drawRRect(barRect, paint);

      // Draw border
      canvas.drawRRect(barRect, borderPaint);

      // Draw percentage text on top of bar
      if (barHeight > 20) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: '${percentage.toInt()}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
          textDirection: TextDirection.ltr,
        );

        textPainter.layout();
        final textX = x + (barWidth - textPainter.width) / 2;
        final textY = y + 3;

        if (textY + textPainter.height < y + barHeight - 3) {
          textPainter.paint(canvas, Offset(textX, textY));
        }
      }

      // Draw subject name at bottom (abbreviated for many subjects)
      final subjectName =
          subjects.length > 10
              ? subject.name.length > 4
                  ? subject.name.substring(0, 4)
                  : subject.name
              : subject.name.length > 8
              ? '${subject.name.substring(0, 8)}...'
              : subject.name;

      final labelPainter = TextPainter(
        text: TextSpan(
          text: subjectName,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: subjects.length > 10 ? 8 : 9,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );

      labelPainter.layout(maxWidth: barWidth + 5);
      final labelX = x + (barWidth - labelPainter.width) / 2;
      final labelY = size.height - bottomPadding + 5;
      labelPainter.paint(canvas, Offset(labelX, labelY));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

extension StrokeDash on Paint {
  set strokeDashArray(List<double> dashArray) {
    // This is a simplified version - Flutter doesn't have built-in dash support
    // In a real implementation, you'd use a custom path or third-party package
  }
}
