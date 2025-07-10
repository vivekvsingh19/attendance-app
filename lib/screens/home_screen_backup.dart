// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../providers/attendance_provider.dart';
// import '../models/subject.dart';
// import '../widgets/subject_card.dart';
// import '../widgets/mini_calculator.dart';
// import '../utils/colors.dart';

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key}); // Enhanced with safe bunks!
  

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8FAFC),
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Header with branding and overall percentage
//             Container(
//               padding: const EdgeInsets.all(20),
//               child: Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       gradient: const LinearGradient(
//                         colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       ),
//                       borderRadius: BorderRadius.circular(12),
//                       boxShadow: [
//                         BoxShadow(
//                           color: const Color(0xFF667EEA).withOpacity(0.3),
//                           blurRadius: 8,
//                           offset: const Offset(0, 2),
//                         ),
//                       ],
//                     ),
//                     child: const Icon(
//                       Icons.school_rounded,
//                       color: Colors.white,
//                       size: 20,
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   const Text(
//                     'BunkMate',
//                     style: TextStyle(
//                       fontSize: 22,
//                       fontWeight: FontWeight.w700,
//                       color: Color(0xFF1E293B),
//                       letterSpacing: -0.5,
//                     ),
//                   ),
//                   const Spacer(),
//                   Consumer<AttendanceProvider>(
//                     builder: (context, provider, child) {
//                       final threshold = provider.settings.attendanceThreshold;
//                       final percentage = provider.overallAttendancePercentage;
//                       final color = AppColors.getAttendanceColor(percentage, threshold);
                      
//                       return Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(16),
//                           border: Border.all(
//                             color: color.withOpacity(0.2),
//                             width: 1,
//                           ),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.04),
//                               blurRadius: 8,
//                               offset: const Offset(0, 2),
//                             ),
//                           ],
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Container(
//                               padding: const EdgeInsets.all(4),
//                               decoration: BoxDecoration(
//                                 color: color.withOpacity(0.1),
//                                 borderRadius: BorderRadius.circular(6),
//                               ),
//                               child: Icon(
//                                 percentage >= threshold ? Icons.trending_up_rounded : Icons.trending_down_rounded,
//                                 color: color,
//                                 size: 14,
//                               ),
//                             ),
//                             const SizedBox(width: 8),
//                             Text(
//                               '${percentage.toStringAsFixed(1)}%',
//                               style: TextStyle(
//                                 color: color,
//                                 fontWeight: FontWeight.w700,
//                                 fontSize: 13,
//                               ),
//                             ),
//                           ],
//                         ),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),
//             Expanded(
//               child: Consumer<AttendanceProvider>(
//                 builder: (context, provider, child) {
//                   if (provider.isLoading) {
//                     return const Center(
//                       child: CircularProgressIndicator(),
//                     );
//                   }

//                   return RefreshIndicator(
//                     onRefresh: () async {
//                       await provider.refreshAttendance();
//                     },
//                     child: SingleChildScrollView(
//                       physics: const AlwaysScrollableScrollPhysics(),
//                       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // User Info Section
//                           _buildUserInfoCard(provider),
//                           const SizedBox(height: 24),
                          
//                           // Quick View Stats
//                           _buildQuickViewStats(provider),
//                           const SizedBox(height: 32),

//                           // Mini Calculator
//                           const MiniCalculator(),
//                           const SizedBox(height: 32),

//                           // Subjects Section Header
//                           Row(
//                             children: [
//                               Container(
//                                 padding: const EdgeInsets.all(8),
//                                 decoration: BoxDecoration(
//                                   gradient: const LinearGradient(
//                                     colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
//                             begin: Alignment.topLeft,
//                             end: Alignment.bottomRight,
//                           ),
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: const Icon(
//                           Icons.subject_rounded,
//                           color: Colors.white,
//                           size: 18,
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       const Text(
//                         'Your Subjects',
//                         style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.w700,
//                           color: Color(0xFF1E293B),
//                           letterSpacing: -0.3,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 20),

//                   // Subjects List
//                   if (provider.subjects.isEmpty)
//                     _buildEmptyState(context)
//                   else
//                     _buildSubjectsList(provider.subjects),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildUserInfoCard(AttendanceProvider provider) {
//     return Consumer<AttendanceProvider>(
//       builder: (context, provider, child) {
//         final overallPercentage = provider.overallAttendancePercentage;
//         final threshold = provider.settings.attendanceThreshold;
//         final statusColor = AppColors.getAttendanceColor(overallPercentage, threshold);
        
//         String statusText;
//         IconData statusIcon;
//         if (overallPercentage >= threshold + 10) {
//           statusText = 'Excellent';
//           statusIcon = Icons.stars_rounded;
//         } else if (overallPercentage >= threshold) {
//           statusText = 'Good';
//           statusIcon = Icons.check_circle_rounded;
//         } else if (overallPercentage >= threshold - 10) {
//           statusText = 'Warning';
//           statusIcon = Icons.warning_rounded;
//         } else {
//           statusText = 'Critical';
//           statusIcon = Icons.error_rounded;
//         }

//         return Container(
//           padding: const EdgeInsets.all(24),
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [
//                 Colors.white,
//                 statusColor.withOpacity(0.02),
//               ],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//             borderRadius: BorderRadius.circular(20),
//             border: Border.all(
//               color: statusColor.withOpacity(0.1),
//               width: 1,
//             ),
//             boxShadow: [
//               BoxShadow(
//                 color: statusColor.withOpacity(0.08),
//                 blurRadius: 20,
//                 offset: const Offset(0, 4),
//               ),
//             ],
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Header with Status Badge
//               Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       gradient: const LinearGradient(
//                         colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       ),
//                       borderRadius: BorderRadius.circular(16),
//                       boxShadow: [
//                         BoxShadow(
//                           color: const Color(0xFF667EEA).withOpacity(0.3),
//                           blurRadius: 8,
//                           offset: const Offset(0, 2),
//                         ),
//                       ],
//                     ),
//                     child: const Icon(
//                       Icons.person_rounded,
//                       color: Colors.white,
//                       size: 22,
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   const Expanded(
//                     child: Text(
//                       'Student Profile',
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.w700,
//                         color: Color(0xFF1E293B),
//                         letterSpacing: -0.3,
//                       ),
//                     ),
//                   ),
//                   // Status Badge
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                     decoration: BoxDecoration(
//                       color: statusColor.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(20),
//                       border: Border.all(
//                         color: statusColor.withOpacity(0.2),
//                         width: 1,
//                       ),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(
//                           statusIcon,
//                           color: statusColor,
//                           size: 16,
//                         ),
//                         const SizedBox(width: 6),
//                         Text(
//                           statusText,
//                           style: TextStyle(
//                             color: statusColor,
//                             fontWeight: FontWeight.w600,
//                             fontSize: 12,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 24),
              
//               // Student Name
//               _buildInfoRow(
//                 Icons.person_rounded,
//                 'Student Name',
//                 provider.studentName?.isNotEmpty == true 
//                     ? provider.studentName! 
//                     : 'Not Available',
//                 const Color(0xFF8B5CF6),
//               ),
//               const SizedBox(height: 16),
              
//               // Student ID
//               _buildInfoRow(
//                 Icons.badge_rounded,
//                 'Student ID',
//                 provider.settings.studentId.isNotEmpty 
//                     ? provider.settings.studentId 
//                     : 'Not Available',
//                 const Color(0xFF667EEA),
//               ),
//               const SizedBox(height: 16),
              
//               // Total Subjects
//               _buildInfoRow(
//                 Icons.auto_stories_rounded,
//                 'Total Subjects',
//                 '${provider.subjects.length} subject${provider.subjects.length != 1 ? 's' : ''}',
//                 const Color(0xFF10B981),
//               ),
//               const SizedBox(height: 16),
              
//               // Overall Attendance with Enhanced Display
//               _buildAttendanceRow(
//                 provider.overallAttendancePercentage,
//                 provider.settings.attendanceThreshold,
//                 provider,
//               ),
//               const SizedBox(height: 16),
              
//               // Target Attendance
//               _buildTargetRow(provider, context),
              
//               // Additional Stats Row
//               if (provider.subjects.isNotEmpty) ...[
//                 const SizedBox(height: 20),
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFF8FAFC),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(
//                       color: const Color(0xFFE2E8F0),
//                       width: 1,
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: _buildMiniStat(
//                           'Safe Bunks',
//                           '${provider.totalSafeBunks}',
//                           Icons.free_breakfast_rounded,
//                           const Color(0xFF10B981),
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       Expanded(
//                         child: _buildMiniStat(
//                           'Classes Needed',
//                           '${provider.totalClassesNeeded}',
//                           Icons.schedule_rounded,
//                           const Color(0xFFEF4444),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildMiniStat(String label, String value, IconData icon, Color color) {
//     return Column(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Icon(
//             icon,
//             color: color,
//             size: 16,
//           ),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w700,
//             color: color,
//           ),
//         ),
//         const SizedBox(height: 2),
//         Text(
//           label,
//           style: const TextStyle(
//             fontSize: 11,
//             fontWeight: FontWeight.w500,
//             color: Color(0xFF64748B),
//           ),
//           textAlign: TextAlign.center,
//         ),
//       ],
//     );
//   }

//   Widget _buildInfoRow(IconData icon, String label, String value, Color iconColor) {
//     return Row(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: iconColor.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Icon(
//             icon,
//             size: 16,
//             color: iconColor,
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 label,
//                 style: const TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.w500,
//                   color: Color(0xFF64748B),
//                 ),
//               ),
//               const SizedBox(height: 2),
//               Text(
//                 value,
//                 style: const TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w600,
//                   color: Color(0xFF1E293B),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildAttendanceRow(double percentage, double threshold, AttendanceProvider provider) {
//     final color = AppColors.getAttendanceColor(percentage, threshold);
//     final isGood = percentage >= threshold;
    
//     // Calculate total classes and attended classes across all subjects
//     final totalClasses = provider.subjects.fold(0, (sum, subject) => sum + subject.totalClasses);
//     final attendedClasses = provider.subjects.fold(0, (sum, subject) => sum + subject.attendedClasses);
    
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color: color.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(
//                   color: color.withOpacity(0.2),
//                   width: 1,
//                 ),
//               ),
//               child: Icon(
//                 isGood ? Icons.trending_up_rounded : Icons.trending_down_rounded,
//                 size: 20,
//                 color: color,
//               ),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Overall Attendance',
//                     style: const TextStyle(
//                       fontSize: 13,
//                       fontWeight: FontWeight.w500,
//                       color: Color(0xFF64748B),
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Row(
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                         decoration: BoxDecoration(
//                           gradient: LinearGradient(
//                             colors: [
//                               color,
//                               color.withOpacity(0.8),
//                             ],
//                           ),
//                           borderRadius: BorderRadius.circular(8),
//                           boxShadow: [
//                             BoxShadow(
//                               color: color.withOpacity(0.3),
//                               blurRadius: 4,
//                               offset: const Offset(0, 2),
//                             ),
//                           ],
//                         ),
//                         child: Text(
//                           '${percentage.toStringAsFixed(1)}%',
//                           style: const TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w700,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       Text(
//                         isGood ? 'Above Target' : 'Below Target',
//                         style: TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.w600,
//                           color: color,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   // Add total classes information
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFF1F5F9),
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(
//                         color: const Color(0xFFE2E8F0),
//                         width: 1,
//                       ),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(
//                           Icons.class_rounded,
//                           size: 14,
//                           color: const Color(0xFF667EEA),
//                         ),
//                         const SizedBox(width: 6),
//                         Text(
//                           '$attendedClasses/$totalClasses classes',
//                           style: const TextStyle(
//                             fontSize: 12,
//                             fontWeight: FontWeight.w600,
//                             color: Color(0xFF475569),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 16),
        
//         // Progress Bar with Enhanced Visualization
//         Container(
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: const Color(0xFFF8FAFC),
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(
//               color: const Color(0xFFE2E8F0),
//               width: 1,
//             ),
//           ),
//           child: Column(
//             children: [
//               // Progress bar
//               Row(
//                 children: [
//                   Text(
//                     'Progress',
//                     style: const TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w600,
//                       color: Color(0xFF64748B),
//                     ),
//                   ),
//                   const Spacer(),
//                   Text(
//                     '${percentage.toStringAsFixed(1)}%',
//                     style: TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w700,
//                       color: color,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(8),
//                 child: LinearProgressIndicator(
//                   value: percentage / 100,
//                   backgroundColor: const Color(0xFFE2E8F0),
//                   valueColor: AlwaysStoppedAnimation<Color>(color),
//                   minHeight: 8,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               // Threshold indicator
//               Row(
//                 children: [
//                   Container(
//                     width: 12,
//                     height: 2,
//                     decoration: BoxDecoration(
//                       color: const Color(0xFF64748B),
//                       borderRadius: BorderRadius.circular(1),
//                     ),
//                   ),
//                   const SizedBox(width: 6),
//                   Text(
//                     'Target: ${threshold.toStringAsFixed(0)}%',
//                     style: const TextStyle(
//                       fontSize: 11,
//                       fontWeight: FontWeight.w500,
//                       color: Color(0xFF64748B),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildTargetRow(AttendanceProvider provider, BuildContext context) {
//     return Row(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(10),
//           decoration: BoxDecoration(
//             gradient: const LinearGradient(
//               colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
//             ),
//             borderRadius: BorderRadius.circular(12),
//             boxShadow: [
//               BoxShadow(
//                 color: const Color(0xFF667EEA).withOpacity(0.3),
//                 blurRadius: 4,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: const Icon(
//             Icons.flag_rounded,
//             size: 20,
//             color: Colors.white,
//           ),
//         ),
//         const SizedBox(width: 16),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Target Attendance',
//                 style: TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w500,
//                   color: Color(0xFF64748B),
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                     decoration: BoxDecoration(
//                       gradient: const LinearGradient(
//                         colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
//                       ),
//                       borderRadius: BorderRadius.circular(8),
//                       boxShadow: [
//                         BoxShadow(
//                           color: const Color(0xFF667EEA).withOpacity(0.3),
//                           blurRadius: 4,
//                           offset: const Offset(0, 2),
//                         ),
//                       ],
//                     ),
//                     child: Text(
//                       '${provider.settings.attendanceThreshold.toInt()}%',
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w700,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   InkWell(
//                     onTap: () => _showTargetAttendanceDialog(context, provider),
//                     borderRadius: BorderRadius.circular(10),
//                     child: Container(
//                       padding: const EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: const Color(0xFF667EEA).withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(10),
//                         border: Border.all(
//                           color: const Color(0xFF667EEA).withOpacity(0.2),
//                           width: 1,
//                         ),
//                       ),
//                       child: const Icon(
//                         Icons.edit_rounded,
//                         size: 16,
//                         color: Color(0xFF667EEA),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildQuickViewStats(AttendanceProvider provider) {
//     // Add null safety and error handling
//     if (provider.subjects.isEmpty) {
//       return Container(
//         padding: const EdgeInsets.all(24),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.04),
//               blurRadius: 20,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Header
//             Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(10),
//                   decoration: BoxDecoration(
//                     gradient: const LinearGradient(
//                       colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: const Icon(
//                     Icons.analytics_rounded,
//                     color: Colors.white,
//                     size: 20,
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 const Text(
//                   'Quick Overview',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w700,
//                     color: Color(0xFF1E293B),
//                     letterSpacing: -0.3,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 24),
//             const Center(
//               child: Text(
//                 'No subjects available for statistics',
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Color(0xFF64748B),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     try {
//       final totalSubjects = provider.subjects.length;
//       final threshold = provider.settings.attendanceThreshold;
      
//       // Safe calculations
//       final subjectsBelowTarget = provider.subjects
//           .where((subject) => subject.attendancePercentage < threshold)
//           .length;
      
//       final subjectsAboveTarget = provider.subjects
//           .where((subject) => subject.attendancePercentage >= threshold)
//           .length;
      
//       // Critical subjects: less than 75% of the target threshold
//       // For example, if target is 100%, critical is < 75%
//       final criticalThreshold = threshold * 0.75;
//       final criticalSubjects = provider.subjects
//           .where((subject) => subject.attendancePercentage < criticalThreshold)
//           .length;

//       return Builder(
//         builder: (context) {
//           return Container(
//             padding: const EdgeInsets.all(24),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(20),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.04),
//                   blurRadius: 20,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Header
//                 Row(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(10),
//                       decoration: BoxDecoration(
//                         gradient: const LinearGradient(
//                           colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                         ),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: const Icon(
//                         Icons.analytics_rounded,
//                         color: Colors.white,
//                         size: 20,
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     const Text(
//                       'Quick Overview',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w700,
//                         color: Color(0xFF1E293B),
//                         letterSpacing: -0.3,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 24),
                
//                 // Stats Grid
//                 Row(
//                   children: [
//                     Expanded(
//                       child: _buildStatCard(
//                         'Total',
//                         totalSubjects.toString(),
//                         Icons.auto_stories_rounded,
//                         const Color(0xFF667EEA),
//                         'Subjects',
//                         () => _showAllSubjects(context, provider),
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: _buildStatCard(
//                         'Below',
//                         subjectsBelowTarget.toString(),
//                         Icons.trending_down_rounded,
//                         const Color(0xFFEF4444),
//                         'Target',
//                         () => _showSubjectsByFilter(context, provider, 'below'),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: _buildStatCard(
//                         'Above',
//                         subjectsAboveTarget.toString(),
//                         Icons.trending_up_rounded,
//                         const Color(0xFF10B981),
//                         'Target',
//                         () => _showSubjectsByFilter(context, provider, 'above'),
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: _buildStatCard(
//                         'Critical',
//                         criticalSubjects.toString(),
//                         Icons.warning_rounded,
//                         const Color(0xFFF59E0B),
//                         'Urgent',
//                         () => _showSubjectsByFilter(context, provider, 'critical'),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 // Add total classes information
//                 Row(
//                   children: [
//                     Expanded(
//                       child: _buildStatCard(
//                         'Total',
//                         '${provider.subjects.fold(0, (sum, subject) => sum + subject.totalClasses)}',
//                         Icons.class_rounded,
//                         const Color(0xFF667EEA),
//                         'Classes',
//                         null,
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: _buildStatCard(
//                         'Attended',
//                         '${provider.subjects.fold(0, (sum, subject) => sum + subject.attendedClasses)}',
//                         Icons.check_circle_rounded,
//                         const Color(0xFF10B981),
//                         'Classes',
//                         null,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           );
//         },
//       );
//     } catch (e) {
//       // Error fallback
//       return Container(
//         padding: const EdgeInsets.all(24),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.04),
//               blurRadius: 20,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(10),
//                   decoration: BoxDecoration(
//                     gradient: const LinearGradient(
//                       colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: const Icon(
//                     Icons.analytics_rounded,
//                     color: Colors.white,
//                     size: 20,
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 const Text(
//                   'Quick Overview',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w700,
//                     color: Color(0xFF1E293B),
//                     letterSpacing: -0.3,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 24),
//             const Center(
//               child: Text(
//                 'Error loading statistics',
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Color(0xFFEF4444),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       );
//     }
//   }

//   Widget _buildStatCard(String title, String value, IconData icon, Color color, String subtitle, VoidCallback? onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.06),
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(
//             color: color.withOpacity(0.1),
//             width: 1,
//           ),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [                  Row(
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.all(8),
//                         decoration: BoxDecoration(
//                           color: color.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: Icon(
//                           icon,
//                           size: 16,
//                           color: color,
//                         ),
//                       ),
//                       const Spacer(),
//                       Flexible(
//                         child: Text(
//                           value,
//                           style: TextStyle(
//                             fontSize: 24,
//                             fontWeight: FontWeight.w800,
//                             color: color,
//                             letterSpacing: -0.5,
//                           ),
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                     ],
//                   ),
//             const SizedBox(height: 12),
//             Text(
//               title,
//               style: const TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//                 color: Color(0xFF1E293B),
//               ),
//             ),
//             const SizedBox(height: 2),
//             Text(
//               subtitle,
//               style: const TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w500,
//                 color: Color(0xFF64748B),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyState(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(32),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 20,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(24),
//             decoration: BoxDecoration(
//               color: const Color(0xFF667EEA).withOpacity(0.1),
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: const Icon(
//               Icons.auto_stories_rounded,
//               size: 48,
//               color: Color(0xFF667EEA),
//             ),
//           ),
//           const SizedBox(height: 24),
//           const Text(
//             'No subjects yet',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.w700,
//               color: Color(0xFF1E293B),
//               letterSpacing: -0.3,
//             ),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             'Add your subjects to start tracking attendance and get insights',
//             style: TextStyle(
//               color: Color(0xFF64748B),
//               fontSize: 14,
//               height: 1.5,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 32),
//           Container(
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: [
//                 BoxShadow(
//                   color: const Color(0xFF667EEA).withOpacity(0.3),
//                   blurRadius: 12,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: ElevatedButton.icon(
//               onPressed: () {
//                 // Navigate to add subject
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.transparent,
//                 shadowColor: Colors.transparent,
//                 padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//               ),
//               icon: const Icon(
//                 Icons.add_rounded,
//                 color: Colors.white,
//                 size: 20,
//               ),
//               label: const Text(
//                 'Add Your First Subject',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w600,
//                   fontSize: 14,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSubjectsList(List<Subject> subjects) {
//     return Column(
//       children: subjects.asMap().entries.map((entry) {
//         final index = entry.key;
//         final subject = entry.value;
//         return Padding(
//           padding: EdgeInsets.only(
//             bottom: index == subjects.length - 1 ? 0 : 16,
//           ),
//           child: SubjectCard(subject: subject),
//         );
//       }).toList(),
//     );
//   }

//   void _showTargetAttendanceDialog(BuildContext context, AttendanceProvider provider) {
//     final TextEditingController controller = TextEditingController(
//       text: provider.settings.attendanceThreshold.toInt().toString(),
//     );

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: Colors.white,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//         title: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 gradient: const LinearGradient(
//                   colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
//                 ),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: const Icon(
//                 Icons.flag_rounded,
//                 color: Colors.white,
//                 size: 18,
//               ),
//             ),
//             const SizedBox(width: 12),
//             const Text(
//               'Set Target',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w700,
//                 color: Color(0xFF1E293B),
//               ),
//             ),
//           ],
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Set your attendance target percentage (50-99%):',
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Color(0xFF64748B),
//               ),
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: controller,
//               keyboardType: TextInputType.number,
//               decoration: InputDecoration(
//                 labelText: 'Target Percentage',
//                 suffixText: '%',
//                 hintText: 'e.g., 75',
//                 filled: true,
//                 fillColor: const Color(0xFFF8FAFC),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(
//                     color: const Color(0xFFE2E8F0),
//                     width: 1,
//                   ),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(
//                     color: const Color(0xFFE2E8F0),
//                     width: 1,
//                   ),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(
//                     color: const Color(0xFF667EEA),
//                     width: 2,
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: const Color(0xFF667EEA).withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: const Row(
//                 children: [
//                   Icon(
//                     Icons.info_outline_rounded,
//                     color: Color(0xFF667EEA),
//                     size: 16,
//                   ),
//                   SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       'Maximum target is 99%. Setting 100% would make calculations impractical.',
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Color(0xFF667EEA),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             style: TextButton.styleFrom(
//               foregroundColor: const Color(0xFF64748B),
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//             ),
//             child: const Text(
//               'Cancel',
//               style: TextStyle(fontWeight: FontWeight.w600),
//             ),
//           ),
//           Container(
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
//               ),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: ElevatedButton(
//               onPressed: () {
//                 final value = int.tryParse(controller.text);
//                 if (value != null && value >= 50 && value <= 99) {
//                   provider.updateAttendanceThreshold(value.toDouble());
//                   Navigator.pop(context);
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text('Target attendance updated to $value%'),
//                       backgroundColor: const Color(0xFF10B981),
//                       behavior: SnackBarBehavior.floating,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                   );
//                 } else {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text('Please enter a value between 50 and 99'),
//                       backgroundColor: Color(0xFFEF4444),
//                       behavior: SnackBarBehavior.floating,
//                     ),
//                   );
//                 }
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.transparent,
//                 shadowColor: Colors.transparent,
//                 padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               child: const Text(
//                 'Update',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showAllSubjects(BuildContext context, AttendanceProvider provider) {
//     if (provider.subjects.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('No subjects available yet!'),
//           backgroundColor: Color(0xFF667EEA),
//         ),
//       );
//       return;
//     }

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => DraggableScrollableSheet(
//         initialChildSize: 0.7,
//         minChildSize: 0.5,
//         maxChildSize: 0.9,
//         builder: (context, scrollController) => Container(
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//           ),
//           child: Column(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(20),
//                 child: Row(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         gradient: const LinearGradient(
//                           colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                         ),
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: const Icon(
//                         Icons.auto_stories_rounded,
//                         color: Colors.white,
//                         size: 18,
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     const Text(
//                       'All Subjects',
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.w700,
//                         color: Color(0xFF1E293B),
//                       ),
//                     ),
//                     const Spacer(),
//                     IconButton(
//                       onPressed: () => Navigator.pop(context),
//                       icon: const Icon(Icons.close_rounded),
//                     ),
//                   ],
//                 ),
//               ),
//               Expanded(
//                 child: ListView.builder(
//                   controller: scrollController,
//                   padding: const EdgeInsets.symmetric(horizontal: 20),
//                   itemCount: provider.subjects.length,
//                   itemBuilder: (context, index) {
//                     final subject = provider.subjects[index];
//                     return Container(
//                       margin: const EdgeInsets.only(bottom: 12),
//                       child: SubjectCard(subject: subject),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _showSubjectsByFilter(BuildContext context, AttendanceProvider provider, String filter) {
//     List<Subject> filteredSubjects;
//     String title;
//     IconData icon;
//     Color color;

//     switch (filter) {
//       case 'below':
//         filteredSubjects = provider.subjects
//             .where((subject) => subject.attendancePercentage < provider.settings.attendanceThreshold)
//             .toList();
//         title = 'Below Target';
//         icon = Icons.trending_down_rounded;
//         color = const Color(0xFFEF4444);
//         break;
//       case 'above':
//         filteredSubjects = provider.subjects
//             .where((subject) => subject.attendancePercentage >= provider.settings.attendanceThreshold)
//             .toList();
//         title = 'Above Target';
//         icon = Icons.trending_up_rounded;
//         color = const Color(0xFF10B981);
//         break;
//       case 'critical':
//         // Critical subjects: less than 75% of the target threshold
//         final criticalThreshold = provider.settings.attendanceThreshold * 0.75;
//         filteredSubjects = provider.subjects
//             .where((subject) => subject.attendancePercentage < criticalThreshold)
//             .toList();
//         title = 'Critical Subjects';
//         icon = Icons.warning_rounded;
//         color = const Color(0xFFF59E0B);
//         break;
//       default:
//         filteredSubjects = provider.subjects;
//         title = 'All Subjects';
//         icon = Icons.auto_stories_rounded;
//         color = const Color(0xFF667EEA);
//     }

//     if (filteredSubjects.isEmpty) {
//       String message;
//       switch (filter) {
//         case 'below':
//           message = 'Great! All subjects are meeting your target attendance.';
//           break;
//         case 'above':
//           message = 'No subjects are currently above your target attendance.';
//           break;
//         case 'critical':
//           message = 'Excellent! No subjects are in critical condition.';
//           break;
//         default:
//           message = 'No subjects available.';
//       }
      
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(message),
//           backgroundColor: filter == 'below' || filter == 'critical' ? const Color(0xFF10B981) : color,
//         ),
//       );
//       return;
//     }

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => DraggableScrollableSheet(
//         initialChildSize: 0.7,
//         minChildSize: 0.5,
//         maxChildSize: 0.9,
//         builder: (context, scrollController) => Container(
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//           ),
//           child: Column(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(20),
//                 child: Row(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: color.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Icon(
//                         icon,
//                         color: color,
//                         size: 18,
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Text(
//                       title,
//                       style: const TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.w700,
//                         color: Color(0xFF1E293B),
//                       ),
//                     ),
//                     const Spacer(),
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                       decoration: BoxDecoration(
//                         color: color.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Text(
//                         '${filteredSubjects.length}',
//                         style: TextStyle(
//                           color: color,
//                           fontWeight: FontWeight.w600,
//                           fontSize: 14,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     IconButton(
//                       onPressed: () => Navigator.pop(context),
//                       icon: const Icon(Icons.close_rounded),
//                     ),
//                   ],
//                 ),
//               ),
//               Expanded(
//                 child: ListView.builder(
//                   controller: scrollController,
//                   padding: const EdgeInsets.symmetric(horizontal: 20),
//                   itemCount: filteredSubjects.length,
//                   itemBuilder: (context, index) {
//                     final subject = filteredSubjects[index];
//                     return Container(
//                       margin: const EdgeInsets.only(bottom: 12),
//                       child: SubjectCard(subject: subject),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
