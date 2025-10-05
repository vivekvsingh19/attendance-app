import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/attendance_provider.dart';
import '../utils/colors.dart';
import '../utils/share_helper.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class SettingsScreen extends StatelessWidget {
  void _showLogoutDialog(BuildContext context, AttendanceProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(context);
              provider.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xFF1B7EE6)),
        automaticallyImplyLeading:
            false, // Remove back button since this is a tab
      ),
      body: Consumer<AttendanceProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Section
                // _buildProfileSection(provider, context),
                // const SizedBox(height: 24),
                // Attendance Settings
                _buildSettingsSection(
                  'Attendance Settings',
                  Icons.school_rounded,
                  [
                    _buildSettingTile(
                      'Target Attendance',
                      '${provider.settings.attendanceThreshold.toInt()}%',
                      Icons.flag_rounded,
                      AppColors.primary,
                      () => _showTargetDialog(context, provider),
                    ),
                    _buildSettingTile(
                      'Reminder Notifications',
                      provider.settings.reminderEnabled
                          ? 'Enabled'
                          : 'Disabled',
                      Icons.notifications_rounded,
                      provider.settings.reminderEnabled
                          ? AppColors.success
                          : AppColors.textSecondary,
                      () => _toggleReminders(provider),
                      showSwitch: true,
                      switchValue: provider.settings.reminderEnabled,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // App Settings
                _buildSettingsSection('App Settings', Icons.settings_rounded, [
                  _buildSettingTile(
                    'Export Attendance as PDF',
                    'Download all attendance data',
                    Icons.picture_as_pdf_rounded,
                    AppColors.primary,
                    () => _showExportPdfDialog(context, provider),
                  ),
                  _buildSettingTile(
                    'Share Options',
                    'Share app or attendance reports',
                    Icons.mobile_friendly_rounded,
                    const Color(0xFF10B981),
                    () => ShareHelper.showShareOptions(context, provider),
                  ),
                ]),
                const SizedBox(height: 16),
                // Logout Button
                _buildLogoutButton(context, provider),
                const SizedBox(height: 40),
                Center(
                  child: Text(
                    'Design & Made by Vivek Singh',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color.fromARGB(255, 230, 27, 27),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  // Widget _buildProfileSection(AttendanceProvider provider, BuildContext context) {
  // return Container(
  //   padding: const EdgeInsets.all(24),
  //   decoration: BoxDecoration(
  //     color: Colors.white,
  //     borderRadius: BorderRadius.circular(20),
  //     boxShadow: [
  //       BoxShadow(
  //         color: Colors.black.withOpacity(0.04),
  //         blurRadius: 20,
  //         offset: const Offset(0, 4),
  //       ),
  //     ],
  //   ),
  //   child: Row(
  //     children: [
  //       Container(
  //         padding: const EdgeInsets.all(16),
  //         decoration: const BoxDecoration(
  //           gradient: LinearGradient(
  //             colors: [Color(0xFF67C9F5), Color(0xFF1B7EE6)],
  //             begin: Alignment.topLeft,
  //             end: Alignment.bottomRight,
  //           ),
  //           borderRadius: BorderRadius.all(Radius.circular(16)),
  //         ),
  //         child: const Icon(
  //           Icons.person_rounded,
  //           color: Colors.white,
  //           size: 32,
  //         ),
  //       ),
  //       const SizedBox(width: 16),
  //       Expanded(
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text(
  //               provider.studentName != null && provider.studentName!.isNotEmpty
  //                   ? provider.studentName!
  //                   : 'Student Name',
  //               style: const TextStyle(
  //                 fontSize: 18,
  //                 fontWeight: FontWeight.w700,
  //                 color: Color(0xFF1E293B),
  //               ),
  //             ),
  //             const SizedBox(height: 4),
  //             Text(
  //               provider.settings.studentId.isNotEmpty
  //                   ? 'ID: ${provider.settings.studentId}'
  //                   : 'ID not set',
  //               style: const TextStyle(
  //                 fontSize: 14,
  //                 color: Color(0xFF64748B),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ],
  //   ),
  // );
  //}

  Widget _buildSettingsSection(
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingTile(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap, {
    bool showSwitch = false,
    bool switchValue = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (showSwitch)
              Switch(
                value: switchValue,
                onChanged: (value) => onTap(),
                activeThumbColor: AppColors.success,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              )
            else
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, AttendanceProvider provider) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showLogoutDialog(context, provider),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: AppColors.error,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.error,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTargetDialog(BuildContext context, AttendanceProvider provider) {
    final controller = TextEditingController(
      text: provider.settings.attendanceThreshold.toInt().toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Target Attendance'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Target Percentage',
            suffixText: '%',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null && value >= 50 && value <= 99) {
                provider.updateAttendanceThreshold(value.toDouble());
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showStudentIdDialog(BuildContext context, AttendanceProvider provider) {
    final controller = TextEditingController(text: provider.settings.studentId);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Student ID'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Student ID'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.updateStudentId(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showStudentNameDialog(
    BuildContext context,
    AttendanceProvider provider,
  ) {
    final controller = TextEditingController(text: provider.studentName ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Student Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Student Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.updateStudentName(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _toggleReminders(AttendanceProvider provider) {
    provider.toggleReminders();
  }

  void _showExportPdfDialog(BuildContext context, AttendanceProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Attendance'),
        content: const Text('Export all your attendance data as a PDF file.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _exportAttendanceAsPdf(context, provider);
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportAttendanceAsPdf(
    BuildContext context,
    AttendanceProvider provider,
  ) async {
    final pdf = pw.Document();

    final studentName = provider.studentName ?? 'Student';
    final studentId = provider.settings.studentId.isNotEmpty
        ? provider.settings.studentId
        : 'Not Set';
    final overallAttendance = provider.overallAttendancePercentage
        .toStringAsFixed(1);

    pdf.addPage(
      pw.Page(
        pageTheme: pw.PageTheme(
          margin: const pw.EdgeInsets.all(0),
          buildBackground: (context) => pw.Container(color: PdfColors.grey100),
        ),
        build: (pw.Context context) {
          List<pw.TableRow> tableRows = [
            pw.TableRow(
              children: [
                pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.symmetric(vertical: 4),
                  child: pw.Text(
                    'Subject',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue,
                    ),
                  ),
                ),
                pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.symmetric(vertical: 4),
                  child: pw.Text(
                    'Attended',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue,
                    ),
                  ),
                ),
                pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.symmetric(vertical: 4),
                  child: pw.Text(
                    'Total',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue,
                    ),
                  ),
                ),
                pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.symmetric(vertical: 4),
                  child: pw.Text(
                    'Percentage',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue,
                    ),
                  ),
                ),
                pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.symmetric(vertical: 4),
                  child: pw.Text(
                    'Classification',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ];
          if (provider.attendanceList.isNotEmpty) {
            tableRows.addAll(
              provider.attendanceList.map((detail) {
                final percent = detail.total > 0
                    ? (detail.attended / detail.total * 100)
                    : 0.0;
                String classification;
                PdfColor rowColor;
                if (percent >= provider.settings.attendanceThreshold) {
                  classification = 'Good';
                  rowColor = PdfColors.green;
                } else if (percent >=
                    provider.settings.attendanceThreshold - 10) {
                  classification = 'Average';
                  rowColor = PdfColors.amber;
                } else {
                  classification = 'Critical';
                  rowColor = PdfColors.red;
                }
                return pw.TableRow(
                  children: [
                    pw.Container(
                      alignment: pw.Alignment.center,
                      padding: const pw.EdgeInsets.symmetric(vertical: 4),
                      child: pw.Text(
                        detail.subject,
                        style: pw.TextStyle(fontSize: 14, color: rowColor),
                      ),
                    ),
                    pw.Container(
                      alignment: pw.Alignment.center,
                      padding: const pw.EdgeInsets.symmetric(vertical: 4),
                      child: pw.Text(
                        detail.attended.toString(),
                        style: pw.TextStyle(fontSize: 14, color: rowColor),
                      ),
                    ),
                    pw.Container(
                      alignment: pw.Alignment.center,
                      padding: const pw.EdgeInsets.symmetric(vertical: 4),
                      child: pw.Text(
                        detail.total.toString(),
                        style: pw.TextStyle(fontSize: 14, color: rowColor),
                      ),
                    ),
                    pw.Container(
                      alignment: pw.Alignment.center,
                      padding: const pw.EdgeInsets.symmetric(vertical: 4),
                      child: pw.Text(
                        '${percent.toStringAsFixed(1)}%',
                        style: pw.TextStyle(fontSize: 14, color: rowColor),
                      ),
                    ),
                    pw.Container(
                      alignment: pw.Alignment.center,
                      padding: const pw.EdgeInsets.symmetric(vertical: 4),
                      child: pw.Text(
                        classification,
                        style: pw.TextStyle(
                          fontSize: 14,
                          color: rowColor,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                );
              }),
            );
          } else {
            tableRows.add(
              pw.TableRow(
                children: [
                  pw.Container(
                    alignment: pw.Alignment.center,
                    padding: const pw.EdgeInsets.symmetric(vertical: 4),
                    child: pw.Text(
                      'No detailed attendance data available.',
                      style: pw.TextStyle(fontSize: 14, color: PdfColors.red),
                    ),
                  ),
                  pw.Container(
                    alignment: pw.Alignment.center,
                    padding: const pw.EdgeInsets.symmetric(vertical: 4),
                    child: pw.Text(''),
                  ),
                  pw.Container(
                    alignment: pw.Alignment.center,
                    padding: const pw.EdgeInsets.symmetric(vertical: 4),
                    child: pw.Text(''),
                  ),
                  pw.Container(
                    alignment: pw.Alignment.center,
                    padding: const pw.EdgeInsets.symmetric(vertical: 4),
                    child: pw.Text(''),
                  ),
                  pw.Container(
                    alignment: pw.Alignment.center,
                    padding: const pw.EdgeInsets.symmetric(vertical: 4),
                    child: pw.Text(''),
                  ),
                ],
              ),
            );
          }
          return pw.Stack(
            children: [
              pw.Positioned.fill(
                child: pw.Center(
                  child: pw.Transform.rotate(
                    angle: 0.5,
                    child: pw.Opacity(
                      opacity: 0.09,
                      child: pw.Text(
                        'Upasthit',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontSize: 120,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              pw.Center(
                child: pw.Container(
                  margin: const pw.EdgeInsets.symmetric(
                    vertical: 40,
                    horizontal: 32,
                  ),
                  padding: const pw.EdgeInsets.all(32),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(32),
                    ),
                    boxShadow: [
                      pw.BoxShadow(color: PdfColors.grey300, blurRadius: 24),
                    ],
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Attendance Report',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue800,
                        ),
                      ),
                      pw.SizedBox(height: 16),
                      pw.Text(
                        'Name: $studentName',
                        style: pw.TextStyle(
                          fontSize: 16,
                          color: PdfColors.black,
                        ),
                      ),
                      pw.Text(
                        'Student ID: $studentId',
                        style: pw.TextStyle(
                          fontSize: 16,
                          color: PdfColors.black,
                        ),
                      ),
                      pw.Text(
                        'Overall Attendance: $overallAttendance%',
                        style: pw.TextStyle(
                          fontSize: 16,
                          color: PdfColors.green800,
                        ),
                      ),
                      pw.SizedBox(height: 16),
                      pw.Text(
                        'Detailed Attendance:',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Table(
                        border: pw.TableBorder.all(),
                        defaultVerticalAlignment:
                            pw.TableCellVerticalAlignment.middle,
                        children: tableRows,
                      ),
                      pw.SizedBox(height: 32),
                      pw.Center(
                        child: pw.Text(
                          'Download Upasthit App from Play Store',
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    // Share the PDF using Printing.sharePdf
    final pdfBytes = await pdf.save();
    await Printing.sharePdf(bytes: pdfBytes, filename: 'attendance_report.pdf');
  }
}
