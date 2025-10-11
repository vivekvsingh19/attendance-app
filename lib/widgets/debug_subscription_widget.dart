import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/subscription_provider.dart';

/// 🐛 Debug widget to check subscription status
/// Add this to your Settings screen or anywhere during testing
class DebugSubscriptionWidget extends StatelessWidget {
  const DebugSubscriptionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16),
      child: ExpansionTile(
        leading: Icon(Icons.bug_report, color: Colors.orange),
        title: Text(
          '🐛 Debug Subscription',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Tap to check subscription status'),
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _checkDetailedStatus(context),
                  icon: Icon(Icons.search),
                  label: Text('Check Detailed Status'),
                ),
                SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () => _forceRefresh(context),
                  icon: Icon(Icons.refresh),
                  label: Text('Force Refresh'),
                ),
                SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () => _restorePurchases(context),
                  icon: Icon(Icons.restore),
                  label: Text('Restore Purchases'),
                ),
                SizedBox(height: 8),
                _buildProviderStatus(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderStatus(BuildContext context) {
    final subscription = context.watch<SubscriptionProvider>();
    return Card(
      color: Colors.grey[100],
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Provider Status:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            _statusRow('Premium', subscription.isPremium),
            _statusRow('In Trial', subscription.isInTrialPeriod),
            _statusRow('Loading', subscription.isLoading),
            if (subscription.error != null)
              Text(
                'Error: ${subscription.error}',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }

  Widget _statusRow(String label, bool value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            value ? Icons.check_circle : Icons.cancel,
            color: value ? Colors.green : Colors.red,
            size: 16,
          ),
          SizedBox(width: 8),
          Text('$label: ${value ? "YES" : "NO"}'),
        ],
      ),
    );
  }

  Future<void> _checkDetailedStatus(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      final customerInfo = await Purchases.getCustomerInfo();

      final debugInfo = StringBuffer();
      debugInfo.writeln('🔍 SUBSCRIPTION DEBUG\n');
      debugInfo.writeln('Customer ID:');
      debugInfo.writeln('${customerInfo.originalAppUserId}\n');
      debugInfo.writeln('All Entitlements:');
      debugInfo.writeln(
        '${customerInfo.entitlements.all.keys.isEmpty ? "None" : customerInfo.entitlements.all.keys.join(", ")}\n',
      );
      debugInfo.writeln('Active Entitlements:');
      debugInfo.writeln(
        '${customerInfo.entitlements.active.keys.isEmpty ? "None" : customerInfo.entitlements.active.keys.join(", ")}\n',
      );
      debugInfo.writeln('Has pro_access:');
      debugInfo.writeln(
        '${customerInfo.entitlements.active.containsKey("pro_access") ? "✅ YES" : "❌ NO"}\n',
      );

      if (customerInfo.entitlements.active.containsKey('pro_access')) {
        final entitlement = customerInfo.entitlements.active['pro_access'];
        debugInfo.writeln('Expiration:');
        debugInfo.writeln('${entitlement?.expirationDate}\n');
        debugInfo.writeln('Period Type:');
        debugInfo.writeln('${entitlement?.periodType}\n');
      }

      debugInfo.writeln('All Products:');
      debugInfo.writeln(
        '${customerInfo.allPurchasedProductIdentifiers.isEmpty ? "None" : customerInfo.allPurchasedProductIdentifiers.join(", ")}',
      );

      // Also print to console
      debugPrint('=' * 50);
      debugPrint(debugInfo.toString());
      debugPrint('=' * 50);

      Navigator.pop(context); // Close loading dialog

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.info, color: Colors.blue),
              SizedBox(width: 8),
              Text('Subscription Debug'),
            ],
          ),
          content: SingleChildScrollView(
            child: SelectableText(
              debugInfo.toString(),
              style: TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
            TextButton(
              onPressed: () {
                // Copy to clipboard would go here if needed
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Info printed to console')),
                );
                Navigator.pop(context);
              },
              child: Text('View Console'),
            ),
          ],
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to get subscription info:\n\n$e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _forceRefresh(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      final subscription = context.read<SubscriptionProvider>();
      await subscription.checkSubscriptionStatus();

      Navigator.pop(context); // Close loading dialog

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(
                subscription.isPremium ? Icons.check_circle : Icons.cancel,
                color: subscription.isPremium ? Colors.green : Colors.red,
              ),
              SizedBox(width: 8),
              Text('Status Refreshed'),
            ],
          ),
          content: Text(
            subscription.isPremium
                ? '✅ Premium Active${subscription.isInTrialPeriod ? " (Trial)" : ""}'
                : '❌ No Active Subscription',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Close loading dialog

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to refresh:\n\n$e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _restorePurchases(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      final subscription = context.read<SubscriptionProvider>();
      final restored = await subscription.restorePurchases();

      Navigator.pop(context); // Close loading dialog

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(
                restored ? Icons.check_circle : Icons.info,
                color: restored ? Colors.green : Colors.orange,
              ),
              SizedBox(width: 8),
              Text('Restore Purchases'),
            ],
          ),
          content: Text(
            restored
                ? '✅ Purchases restored successfully!\n\nYou now have premium access.'
                : 'ℹ️ No purchases found to restore.\n\nIf you just purchased, please wait a moment and try again.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Close loading dialog

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to restore:\n\n$e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}
