import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/attendance_provider.dart';
import '../utils/colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: Consumer<AttendanceProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Section
                _buildProfileSection(provider, context),
                const SizedBox(height: 24),
                
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
                      provider.settings.reminderEnabled ? 'Enabled' : 'Disabled',
                      Icons.notifications_rounded,
                      provider.settings.reminderEnabled ? AppColors.success : AppColors.textSecondary,
                      () => _toggleReminders(provider),
                      showSwitch: true,
                      switchValue: provider.settings.reminderEnabled,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                
                // App Settings
                _buildSettingsSection(
                  'App',
                  Icons.settings_rounded,
                  [
                    _buildSettingTile(
                      'Refresh Data',
                      'Sync with server',
                      Icons.refresh_rounded,
                      AppColors.success,
                      () => _refreshData(context, provider),
                    ),
                    _buildSettingTile(
                      'About',
                      'Version 1.0.0',
                      Icons.info_outline_rounded,
                      AppColors.textSecondary,
                      () => _showAboutDialog(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Logout Button
                _buildLogoutButton(context, provider),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileSection(AttendanceProvider provider, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.studentName?.isNotEmpty == true 
                      ? provider.studentName! 
                      : 'Student',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: ${provider.settings.studentId.isNotEmpty ? provider.settings.studentId : 'Not Set'}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${provider.overallAttendancePercentage.toStringAsFixed(1)}% Attendance',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(String title, IconData icon, List<Widget> children) {
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
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 18,
              ),
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
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
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
                activeColor: AppColors.success,
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
          decoration: const InputDecoration(
            labelText: 'Student ID',
          ),
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

  void _showStudentNameDialog(BuildContext context, AttendanceProvider provider) {
    final controller = TextEditingController(text: provider.studentName ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Student Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Student Name',
          ),
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

  void _refreshData(BuildContext context, AttendanceProvider provider) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Refreshing attendance data...')),
    );
    await provider.refreshAttendance();
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About BunkMate'),
        content: const Text(
          'BunkMate v1.0.0\n\n'
          'A modern attendance tracking app for students.\n\n'
          'Features:\n'
          '• Real-time attendance tracking\n'
          '• Smart bunk calculator\n'
          '• Beautiful modern UI\n'
          '• Customizable targets\n\n'
          'Made with ❤️ for students',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

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
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
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
}
