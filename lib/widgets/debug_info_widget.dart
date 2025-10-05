import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/attendance_provider.dart';
import '../utils/colors.dart';

class DebugInfoWidget extends StatelessWidget {
  const DebugInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Only show in debug mode
    if (!kDebugMode) {
      return const SizedBox.shrink();
    }

    return Consumer<AttendanceProvider>(
      builder: (context, provider, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.warning.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.bug_report_rounded,
                    color: AppColors.warning,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Debug Info',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildDebugRow(
                'Login Status',
                provider.isLoggedIn ? 'Logged In' : 'Not Logged In',
              ),
              _buildDebugRow(
                'Loading State',
                provider.isLoading ? 'Loading...' : 'Idle',
              ),
              _buildDebugRow('College ID', provider.collegeId ?? 'None'),
              _buildDebugRow(
                'Total Subjects',
                provider.subjects.length.toString(),
              ),
              _buildDebugRow('Error State', provider.error ?? 'None'),
              if (provider.subjects.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text(
                  'Subjects:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                ...provider.subjects.map(
                  (subject) => _buildDebugRow(
                    subject.name,
                    '${subject.attendedClasses}/${subject.totalClasses} (${subject.attendancePercentage.toStringAsFixed(1)}%)',
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildDebugRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
