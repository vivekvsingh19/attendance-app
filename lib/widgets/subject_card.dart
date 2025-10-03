import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/subject.dart';
import '../utils/colors.dart';
import '../providers/attendance_provider.dart';

class SubjectCard extends StatelessWidget {
  final Subject subject;
  final VoidCallback? onTap;

  const SubjectCard({
    super.key,
    required this.subject,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AttendanceProvider>(
      builder: (context, provider, child) {
        final double threshold = provider.settings.attendanceThreshold;
        final Color statusColor = AppColors.getAttendanceColor(subject.attendancePercentage, threshold);
        final bool isLowAttendance = subject.attendancePercentage < threshold;
    
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: statusColor.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with subject name and status
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.book_rounded,
                          color: statusColor,
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
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Code: ${subject.code}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: statusColor.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getStatusIcon(subject.attendancePercentage, threshold),
                              color: statusColor,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _getStatusText(subject.attendancePercentage, threshold),
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Attendance stats
                  Row(
                    children: [
                      _buildStatItem(
                        'Attended',
                        subject.attendedClasses.toString(),
                        Icons.check_circle_rounded,
                        AppColors.success,
                      ),
                      const SizedBox(width: 20),
                      _buildStatItem(
                        'Total',
                        subject.totalClasses.toString(),
                        Icons.class_rounded,
                        AppColors.info,
                      ),
                      const SizedBox(width: 20),
                      _buildStatItem(
                        'Percentage',
                        '${subject.attendancePercentage.toStringAsFixed(1)}%',
                        Icons.trending_up_rounded,
                        statusColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Progress bar with threshold indicator
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Progress',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            '${subject.attendancePercentage.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final double progressBarWidth = constraints.maxWidth;
                          final double thresholdPosition = (threshold / 100) * progressBarWidth;
                          
                          return Stack(
                            children: [
                              // Background progress bar
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: subject.attendancePercentage / 100,
                                  backgroundColor: AppColors.borderLight,
                                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                                  minHeight: 6,
                                ),
                              ),
                              // Threshold indicator line
                              Positioned(
                                left: thresholdPosition - 1, // Center the line (2px width / 2)
                                top: 0,
                                bottom: 0,
                                child: Container(
                                  width: 2,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[700],
                                    borderRadius: BorderRadius.circular(1),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 2,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 6),
                      // Threshold indicator text
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '0%',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: subject.attendancePercentage >= threshold 
                                ? Colors.green.withOpacity(0.1)
                                : Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: subject.attendancePercentage >= threshold 
                                  ? Colors.green.withOpacity(0.3)
                                  : Colors.orange.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              'Target: ${threshold.toInt()}%',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: subject.attendancePercentage >= threshold 
                                  ? Colors.green[700]
                                  : Colors.orange[700],
                              ),
                            ),
                          ),
                          Text(
                            '100%',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  // Action recommendations
                  if (isLowAttendance) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.error.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_rounded,
                            color: AppColors.error,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Need ${_calculateClassesNeeded(subject, threshold)} more classes to reach ${threshold.toInt()}%',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  // Bunk system
                  const SizedBox(height: 16),
                  _buildBunkSystem(subject, threshold),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 14,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  IconData _getStatusIcon(double percentage, double threshold) {
    if (percentage >= threshold + 15) return Icons.stars_rounded;
    if (percentage >= threshold + 5) return Icons.check_circle_rounded;
    if (percentage >= threshold) return Icons.trending_up_rounded;
    return Icons.warning_rounded;
  }

  String _getStatusText(double percentage, double threshold) {
    if (percentage >= threshold + 15) return 'Excellent';
    if (percentage >= threshold + 5) return 'Good';
    if (percentage >= threshold) return 'Safe';
    if (percentage >= threshold - 10) return 'Warning';
    return 'Critical';
  }

  int _calculateClassesNeeded(Subject subject, double threshold) {
    return subject.getClassesToAttend(threshold);
  }

  Widget _buildBunkSystem(Subject subject, double threshold) {
    final int safeBunks = _calculateSafeBunks(subject, threshold);
    final bool canBunk = safeBunks > 0;
    final bool isAboveThreshold = subject.attendancePercentage >= threshold;
    
    if (!isAboveThreshold) {
      return const SizedBox.shrink(); // Don't show bunk system if below threshold
    }
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: canBunk 
            ? const Color(0xFF10B981).withOpacity(0.1) 
            : const Color(0xFF6366F1).withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: canBunk 
              ? const Color(0xFF10B981).withOpacity(0.2) 
              : const Color(0xFF6366F1).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            canBunk ? Icons.celebration_rounded : Icons.shield_rounded,
            color: canBunk 
                ? const Color(0xFF10B981) 
                : const Color(0xFF6366F1),
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              canBunk 
                  ? 'You can safely bunk $safeBunks ${safeBunks == 1 ? 'class' : 'classes'} and stay above ${threshold.toInt()}%'
                  : 'No safe bunks available. Current percentage: ${subject.attendancePercentage.toStringAsFixed(1)}%',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _calculateSafeBunks(Subject subject, double threshold) {
    if (subject.attendancePercentage < threshold) return 0;
    
    final int attended = subject.attendedClasses;
    final int total = subject.totalClasses;
    
    // Calculate safe bunks: (attended) / (total + x) >= threshold/100
    // Solving: attended >= (threshold/100) * (total + x)
    // attended >= threshold/100 * total + threshold/100 * x
    // attended - threshold/100 * total >= threshold/100 * x
    // x <= (attended - threshold/100 * total) / (threshold/100)
    // x <= (attended * 100 - threshold * total) / threshold
    
    final double numerator = attended * 100 - threshold * total;
    
    if (numerator <= 0) return 0; // Already at or below threshold
    
    final int safeBunks = (numerator / threshold).floor();
    return safeBunks > 0 ? safeBunks : 0;
  }
}
