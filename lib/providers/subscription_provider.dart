import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../services/subscription_service.dart';

class SubscriptionProvider with ChangeNotifier {
  bool _hasActiveSubscription = false;
  bool _isCheckingSubscription = false;
  bool _isInTrialPeriod = false;
  String? _error;

  bool get hasActiveSubscription => _hasActiveSubscription;
  bool get isPremium => _hasActiveSubscription; // Alias for clearer code
  bool get isCheckingSubscription => _isCheckingSubscription;
  bool get isLoading => _isCheckingSubscription; // Alias for clearer code
  bool get isInTrialPeriod => _isInTrialPeriod;
  String? get error => _error;
  String? get errorMessage => _error; // Alias for clearer code

  /// Initialize RevenueCat with the user's college username
  Future<void> initialize(String collegeUsername) async {
    try {
      await SubscriptionService.initialize(collegeUsername);
      await checkSubscriptionStatus();
    } catch (e) {
      _error = 'Failed to initialize subscription service: $e';
      debugPrint(_error);
      notifyListeners();
    }
  }

  /// Check if the user has an active subscription
  Future<void> checkSubscriptionStatus() async {
    _isCheckingSubscription = true;
    _error = null;
    notifyListeners();

    try {
      final hasSubscription = await SubscriptionService.hasActiveSubscription();
      final trialStatus = await SubscriptionService.isInTrialPeriod();

      _hasActiveSubscription = hasSubscription;
      _isInTrialPeriod = trialStatus;

      debugPrint(
        'Subscription check: ${hasSubscription ? "Active" : "Inactive"}, Trial: ${trialStatus ? "Yes" : "No"}',
      );
    } catch (e) {
      _error = 'Error checking subscription: $e';
      debugPrint(_error);
      _hasActiveSubscription = false;
      _isInTrialPeriod = false;
    } finally {
      _isCheckingSubscription = false;
      notifyListeners();
    }
  }

  /// Refresh subscription status (useful after purchase or restore)
  Future<void> refreshSubscriptionStatus() async {
    await checkSubscriptionStatus();
  }

  /// Purchase a subscription package
  Future<bool> purchaseSubscription() async {
    _isCheckingSubscription = true;
    _error = null;
    notifyListeners();

    try {
      final offerings = await Purchases.getOfferings();
      if (offerings.current == null ||
          offerings.current!.availablePackages.isEmpty) {
        _error = 'No subscription packages available';
        _isCheckingSubscription = false;
        notifyListeners();
        return false;
      }

      final package = offerings.current!.availablePackages.first;
      await SubscriptionService.purchasePackage(package);

      _hasActiveSubscription = true;
      _error = null;
      _isCheckingSubscription = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Purchase error: $e';
      debugPrint(_error);
      _isCheckingSubscription = false;
      notifyListeners();
      return false;
    }
  }

  /// Restore previous purchases
  Future<bool> restorePurchases() async {
    _isCheckingSubscription = true;
    _error = null;
    notifyListeners();

    try {
      await SubscriptionService.restorePurchases();
      final hasSubscription = await SubscriptionService.hasActiveSubscription();

      _hasActiveSubscription = hasSubscription;
      _error = null;
      _isCheckingSubscription = false;
      notifyListeners();

      return hasSubscription;
    } catch (e) {
      _error = 'Restore error: $e';
      debugPrint(_error);
      _isCheckingSubscription = false;
      notifyListeners();
      return false;
    }
  }

  /// Get subscription expiry date
  Future<DateTime?> getExpiryDate() async {
    try {
      return await SubscriptionService.getSubscriptionExpiryDate();
    } catch (e) {
      debugPrint('Error getting expiry date: $e');
      return null;
    }
  }

  /// Logout and clear subscription state
  Future<void> logout() async {
    try {
      await SubscriptionService.logout();
      _hasActiveSubscription = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Error logging out from subscription service: $e');
    }
  }

  /// Switch to a different user
  Future<void> switchUser(String newCollegeUsername) async {
    try {
      await SubscriptionService.switchUser(newCollegeUsername);
      await checkSubscriptionStatus();
    } catch (e) {
      _error = 'Error switching user: $e';
      debugPrint(_error);
      notifyListeners();
    }
  }
}
