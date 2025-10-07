import 'package:flutter/material.dart';
import 'package:upgrader/upgrader.dart';

class ForcedUpdateWrapper extends StatelessWidget {
  final Widget child;

  const ForcedUpdateWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      upgrader: Upgrader(
        // Very frequent checks for updates - will check every 10 seconds if no update
        durationUntilAlertAgain: const Duration(seconds: 10),
        // Enable debug for testing (set to false for production)
        debugDisplayAlways: false, // Set to true for testing
        debugDisplayOnce: false, // Set to true for testing
        countryCode: 'IN',
        languageCode: 'en',
        // Custom messages to make it clear update is mandatory
        messages: UpgraderMessages(code: 'en'),
      ),
      // Use material dialog style - more persistent
      dialogStyle: UpgradeDialogStyle.material,
      // Use PopScope to prevent back navigation during update dialog
      child: PopScope(
        canPop: false, // This prevents the back button from working
        onPopInvokedWithResult: (didPop, result) {
          // Custom logic when user tries to go back
          // Show a snackbar or dialog informing them they must update
          if (!didPop) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please update the app to continue using it.'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        child: child,
      ),
    );
  }
}
