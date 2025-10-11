import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subscription_provider.dart';
import '../screens/paywall_screen.dart';

/// Widget to display subscription status and manage subscription
class SubscriptionStatusWidget extends StatelessWidget {
  const SubscriptionStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionProvider>(
      builder: (context, subscriptionProvider, child) {
        if (subscriptionProvider.isCheckingSubscription) {
          return const Card(
            child: ListTile(
              leading: CircularProgressIndicator(),
              title: Text('Checking subscription status...'),
            ),
          );
        }

        final hasSubscription = subscriptionProvider.hasActiveSubscription;

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Column(
            children: [
              ListTile(
                leading: Icon(
                  hasSubscription ? Icons.check_circle : Icons.info_outline,
                  color: hasSubscription ? Colors.green : Colors.orange,
                  size: 32,
                ),
                title: Text(
                  hasSubscription ? 'Premium Active' : 'Free Account',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                subtitle: Text(
                  hasSubscription
                      ? 'You have unlimited access to all features'
                      : 'Subscribe to unlock all features',
                  style: const TextStyle(fontSize: 14),
                ),
                trailing:
                    !hasSubscription
                        ? ElevatedButton(
                          onPressed: () {
                            Navigator.of(context)
                                .push(
                                  MaterialPageRoute(
                                    builder:
                                        (context) => const PaywallScreen(
                                          isFromLogin: false,
                                        ),
                                  ),
                                )
                                .then((_) {
                                  // Refresh subscription status after returning from paywall
                                  subscriptionProvider
                                      .refreshSubscriptionStatus();
                                });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF667eea),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Subscribe'),
                        )
                        : null,
              ),
              if (hasSubscription)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            subscriptionProvider.refreshSubscriptionStatus();
                          },
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('Refresh'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF667eea),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            _showSubscriptionDetails(
                              context,
                              subscriptionProvider,
                            );
                          },
                          icon: const Icon(Icons.info_outline, size: 18),
                          label: const Text('Details'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF667eea),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showSubscriptionDetails(
    BuildContext context,
    SubscriptionProvider provider,
  ) async {
    final expiryDate = await provider.getExpiryDate();

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.workspace_premium, color: Color(0xFF667eea)),
                SizedBox(width: 12),
                Text('Subscription Details'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Status: Active',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 12),
                if (expiryDate != null) ...[
                  const Text(
                    'Renewal Date:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(expiryDate),
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                ],
                const Text(
                  'Your subscription will automatically renew unless cancelled.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                const Text(
                  'To manage or cancel your subscription, visit Google Play Store > Subscriptions.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
