import 'package:flutter/material.dart';
import 'package:upgrader/upgrader.dart';

class UpdateHelper {
  // Create a custom upgrader configuration for force updates
  static Upgrader getForceUpdateUpgrader() {
    return Upgrader(
      durationUntilAlertAgain: const Duration(hours: 1), // Check every hour
      debugDisplayAlways: false, // Set to true for testing
      debugDisplayOnce: false, // Set to true for testing
      countryCode: 'IN',
      languageCode: 'en',
    );
  }

  // Create a custom upgrader configuration for optional updates
  static Upgrader getOptionalUpdateUpgrader() {
    return Upgrader(
      durationUntilAlertAgain: const Duration(days: 7), // Check weekly
      debugDisplayAlways: false,
      debugDisplayOnce: false,
      countryCode: 'IN',
      languageCode: 'en',
    );
  }

  // Custom upgrade dialog widget
  static Widget buildCustomUpgradeAlert({
    required Widget child,
    bool forceUpdate = false,
  }) {
    return UpgradeAlert(
      upgrader: forceUpdate ? getForceUpdateUpgrader() : getOptionalUpdateUpgrader(),
      dialogStyle: UpgradeDialogStyle.material,
      child: child,
    );
  }

  // Custom upgrade card for in-app display
  static Widget buildUpgradeCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.system_update,
                  color: Colors.blue[700],
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'App Update Available',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'A new version of Upasthit is available with improved features and bug fixes.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            UpgradeCard(
              upgrader: getOptionalUpdateUpgrader(),
            ),
          ],
        ),
      ),
    );
  }

  // Check if update is available programmatically
  static Future<bool> isUpdateAvailable() async {
    final upgrader = getOptionalUpdateUpgrader();
    await upgrader.initialize();
    return upgrader.isUpdateAvailable();
  }

  // Show custom update dialog
  static Future<void> showCustomUpdateDialog(BuildContext context) async {
    final upgrader = getForceUpdateUpgrader();
    await upgrader.initialize();
    
    if (upgrader.isUpdateAvailable()) {
      showDialog(
        context: context,
        barrierDismissible: false, // Force update - can't dismiss
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.system_update, color: Colors.blue),
              SizedBox(width: 8),
              Text('Update Required'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'A new version of Upasthit is available. Please update to continue using the app.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 12),
              Text(
                '✨ What\'s new:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• Improved performance'),
              Text('• Bug fixes and stability improvements'),
              Text('• Enhanced user experience'),
            ],
          ),
          actions: [
            ElevatedButton.icon(
              onPressed: () => upgrader.sendUserToAppStore(),
              icon: const Icon(Icons.download),
              label: const Text('Update Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }
  }
}
