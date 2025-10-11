import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subscription_provider.dart';
import '../screens/paywall_screen.dart';

class PremiumFeatureGuard extends StatelessWidget {
  final Widget child;
  final String featureName;
  final String? featureDescription;
  final Widget? lockedWidget;
  final bool showUpgradeButton;

  const PremiumFeatureGuard({
    super.key,
    required this.child,
    required this.featureName,
    this.featureDescription,
    this.lockedWidget,
    this.showUpgradeButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionProvider>(
      builder: (context, subscription, _) {
        if (subscription.isPremium) {
          return child;
        }

        // Show partial content with modal overlay
        return Stack(
          children: [
            // Show the actual content but slightly dimmed/disabled
            AbsorbPointer(child: Opacity(opacity: 0.5, child: child)),
            // Premium overlay modal
            _buildPremiumOverlay(context, subscription.isLoading),
          ],
        );
      },
    );
  }

  Widget _buildPremiumOverlay(BuildContext context, bool isLoading) {
    return Stack(
      children: [
        // Blur effect
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
          child: Container(color: Colors.black.withOpacity(0.3)),
        ),
        // Minimal premium modal
        Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Simple lock icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(
                      1,
                      125,
                      202,
                      1,
                    ).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_outline,
                    size: 32,
                    color: Color.fromRGBO(1, 125, 202, 1),
                  ),
                ),
                const SizedBox(height: 16),
                // Feature name
                Text(
                  featureName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                  textAlign: TextAlign.center,
                ),
                if (featureDescription != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    featureDescription!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 20),
                // Upgrade button
                if (showUpgradeButton) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          isLoading
                              ? null
                              : () {
                                showPaywallModal(context);
                              },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(1, 125, 202, 1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Upgrade to Pro',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Inline premium badge for smaller UI elements
class PremiumBadge extends StatelessWidget {
  const PremiumBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, size: 10, color: Colors.black87),
          SizedBox(width: 2),
          Text(
            'PRO',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

/// Wrapper for buttons that should be disabled for free users
class PremiumFeatureButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final String featureName;

  const PremiumFeatureButton({
    super.key,
    required this.child,
    required this.onTap,
    required this.featureName,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionProvider>(
      builder: (context, subscription, _) {
        if (subscription.isPremium) {
          return GestureDetector(onTap: onTap, child: child);
        }

        return GestureDetector(
          onTap: () {
            _showPremiumDialog(context, featureName);
          },
          child: Stack(
            children: [
              Opacity(opacity: 0.6, child: child),
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock, size: 10, color: Colors.black87),
                      SizedBox(width: 2),
                      Text(
                        'PRO',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPremiumDialog(BuildContext context, String featureName) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.lock_rounded, color: Colors.purple[700]),
                const SizedBox(width: 8),
                const Text('Premium Feature'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$featureName is a premium feature.',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Upgrade to Upasthit Pro to unlock this and other advanced features.',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Maybe Later'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  showPaywallModal(context);
                },
                icon: const Icon(Icons.star_rounded, size: 18),
                label: const Text('Upgrade Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(1, 125, 202, 1),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
    );
  }
}
