import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/attendance_provider.dart';
import '../widgets/subject_card.dart';
import '../utils/colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Header with branding and overall percentage
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF667EEA).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/images/75+.png',
                        width: 24,
                        height: 24,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Upasthit',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Spacer(),
                  Consumer<AttendanceProvider>(
                    builder: (context, provider, child) {
                      final threshold = provider.settings.attendanceThreshold;
                      final percentage = provider.overallAttendancePercentage;
                      final color = AppColors.getAttendanceColor(percentage, threshold);
                      
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: color.withOpacity(0.2),
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
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                percentage >= threshold ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                                color: color,
                                size: 14,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${percentage.toStringAsFixed(1)}%',
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            // Main Content
            Expanded(
              child: Consumer<AttendanceProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  // Debug: Print subjects length and first subject if available
                  print('Subjects count: \'${provider.subjects.length}\'');
                  if (provider.subjects.isNotEmpty) {
                    final s = provider.subjects[0];
                    print('First subject: Name: \'${s.name}\', Code: \'${s.code}\', Attended: \'${s.attendedClasses}\', Total: \'${s.totalClasses}\', Percentage: \'${s.attendancePercentage}\'');
                  }
                  if (provider.error != null) {
                    return Center(
                      child: Text(
                        provider.error!,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    );
                  }
                  if (provider.subjects.isEmpty) {
                    return Center(
                      child: Text(
                        'No subjects found. Please refresh or check your data.',
                        style: const TextStyle(color: Colors.orange, fontSize: 16),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      await provider.refreshAttendance();
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // User Info Section
                          // _buildUserInfoCard(provider),
                          // const SizedBox(height: 24),
                          
                          // Quick View Stats
                          _buildQuickViewStats(provider),
                          const SizedBox(height: 32),

                          // Mini Calculator
                          // const MiniCalculator(),
                          // const SizedBox(height: 32),

                          // Subjects Section Header
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.subject_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'My Subjects',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1E293B),
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: () => _showAllSubjects(context),
                                icon: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF667EEA).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.view_list_rounded,
                                    color: Color(0xFF667EEA),
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Subjects List
                          if (provider.subjects.isNotEmpty)
                            ...provider.subjects.map((subject) => Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: SubjectCard(subject: subject),
                            ))
                          else
                            _buildEmptySubjectsCard(provider),
                          
                          const SizedBox(height: 100), // Bottom padding for navigation
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickViewStats(AttendanceProvider provider) {
    final threshold = provider.settings.attendanceThreshold;
    final percentage = provider.overallAttendancePercentage;
    final totalSubjects = provider.subjects.length;
    final criticalSubjects = provider.subjects.where((s) => s.attendancePercentage < 75.0).length;
    final safeSubjects = provider.subjects.where((s) => s.attendancePercentage >= 75.0).length;
    
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.analytics_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Quick Overview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Overall Attendance Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.getAttendanceColor(percentage, threshold).withOpacity(0.1),
                  AppColors.getAttendanceColor(percentage, threshold).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.getAttendanceColor(percentage, threshold).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.getAttendanceColor(percentage, threshold).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    percentage >= threshold ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                    color: AppColors.getAttendanceColor(percentage, threshold),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.getAttendanceColor(percentage, threshold),
                        ),
                      ),
                      const Text(
                        'Overall Attendance',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Subjects Overview Row
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Total Subjects',
                  value: '$totalSubjects',
                  color: const Color(0xFF6366F1),
                  icon: Icons.subject_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'Critical Subjects',
                  value: '$criticalSubjects',
                  color: const Color(0xFFEF4444),
                  icon: Icons.warning_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'Safe Subjects',
                  value: '$safeSubjects',
                  color: const Color(0xFF10B981),
                  icon: Icons.check_circle_rounded,
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
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySubjectsCard(AttendanceProvider provider) {
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF667EEA).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.school_rounded,
              color: Color(0xFF667EEA),
              size: 32,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No subjects added yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your first subject to start tracking attendance',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _showAddSubjectDialog(null),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Subject'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667EEA),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
          ),
        ],
      ),
    );
  }

  void _showAllSubjects(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Consumer<AttendanceProvider>(
        builder: (context, provider, child) {
          return DraggableScrollableSheet(
            initialChildSize: 0.7,
            maxChildSize: 0.9,
            minChildSize: 0.5,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          const Text(
                            'All Subjects',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: provider.subjects.length,
                        itemBuilder: (context, index) {
                          final subject = provider.subjects[index];
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
        },
      ),
    );
  }

  void _showAddSubjectDialog(BuildContext? context) {
    // This would show a dialog to add a new subject
    // For now, we'll just show a simple placeholder
    if (context != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Add Subject'),
          content: const Text('Subject creation feature coming soon!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}
