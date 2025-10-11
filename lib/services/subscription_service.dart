import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../config/app_config.dart';

class SubscriptionService {
  static final String _entitlementId = AppConfig.subscriptionEntitlementId;

  /// Link the user's college username to RevenueCat
  /// This should be called after login to track the user properly
  static Future<void> initialize(String collegeUsername) async {
    try {
      // Check if SDK is configured
      bool isConfigured = await Purchases.isConfigured;
      if (!isConfigured) {
        debugPrint(
          '❌ RevenueCat not configured! Should be initialized in main()',
        );
        return;
      }

      debugPrint('👤 Linking user to RevenueCat: $collegeUsername');

      // Use logIn to link this user to RevenueCat
      // This allows tracking subscriptions across devices
      final result = await Purchases.logIn(collegeUsername);

      debugPrint('✅ User logged in to RevenueCat');
      debugPrint('📊 Created: ${result.created}');
    } catch (e) {
      debugPrint('⚠️  Error linking user to RevenueCat: $e');
      // Don't block - user can still use app without subscription
    }
  }

  /// Check if the user has an active subscription
  static Future<bool> hasActiveSubscription() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();

      // 🆕 ENHANCED LOGGING - Check ALL possible entitlement names
      debugPrint('🔍 === CHECKING SUBSCRIPTION ===');
      debugPrint('Customer ID: ${customerInfo.originalAppUserId}');
      debugPrint(
        'All Entitlements: ${customerInfo.entitlements.all.keys.toList()}',
      );
      debugPrint(
        'Active Entitlements: ${customerInfo.entitlements.active.keys.toList()}',
      );
      debugPrint('Looking for: $_entitlementId');

      // Try exact match first
      bool hasEntitlement = customerInfo.entitlements.active.containsKey(
        _entitlementId,
      );

      if (!hasEntitlement) {
        // Try case-insensitive match
        debugPrint('⚠️  Exact match failed, trying case-insensitive...');
        final lowerEntitlementId = _entitlementId.toLowerCase();
        for (var key in customerInfo.entitlements.active.keys) {
          if (key.toLowerCase() == lowerEntitlementId) {
            debugPrint('✅ Found case-insensitive match: $key');
            hasEntitlement = true;
            break;
          }
        }
      }

      if (hasEntitlement) {
        debugPrint('✅ SUBSCRIPTION ACTIVE');
      } else {
        debugPrint('❌ SUBSCRIPTION INACTIVE');
        debugPrint(
          '⚠️  Available entitlements: ${customerInfo.entitlements.active.keys.join(", ")}',
        );
      }
      debugPrint('=============================');

      // Check if user has the pro_access entitlement
      final hasEntitlementFinal = customerInfo.entitlements.active.containsKey(
        _entitlementId,
      );

      debugPrint(
        'Subscription status: ${hasEntitlementFinal ? "Active" : "Inactive"}',
      );
      return hasEntitlementFinal;
    } catch (e) {
      debugPrint('Error checking subscription status: $e');
      return false; // Fail safe: assume no subscription on error
    }
  }

  /// Check if the user is in a free trial period
  static Future<bool> isInTrialPeriod() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();

      // Check if user has the pro_access entitlement and if it's in trial
      if (customerInfo.entitlements.active.containsKey(_entitlementId)) {
        final entitlement = customerInfo.entitlements.active[_entitlementId];
        final periodType = entitlement?.periodType;

        // PeriodType.trial indicates the user is in a free trial
        final isTrialActive = periodType == PeriodType.trial;

        debugPrint(
          'Trial period status: ${isTrialActive ? "Active" : "Not Active"}',
        );
        return isTrialActive;
      }

      return false;
    } catch (e) {
      debugPrint('Error checking trial status: $e');
      return false;
    }
  }

  /// Get available subscription packages (offerings)
  static Future<List<Package>> getAvailablePackages() async {
    try {
      final offerings = await Purchases.getOfferings();

      if (offerings.current == null) {
        debugPrint('No offerings available');
        return [];
      }

      final packages = offerings.current!.availablePackages;
      debugPrint('Available packages: ${packages.length}');
      return packages;
    } catch (e) {
      debugPrint('Error fetching packages: $e');
      return [];
    }
  }

  /// Purchase a subscription package
  static Future<bool> purchasePackage(Package package) async {
    try {
      final purchaserInfo = await Purchases.purchasePackage(package);

      // Check if the purchase was successful and entitlement is active
      final hasEntitlement = purchaserInfo.entitlements.active.containsKey(
        _entitlementId,
      );

      debugPrint('Purchase completed. Entitlement active: $hasEntitlement');
      return hasEntitlement;
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);

      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        debugPrint('Purchase cancelled by user');
      } else if (errorCode == PurchasesErrorCode.purchaseNotAllowedError) {
        debugPrint('Purchase not allowed');
      } else {
        debugPrint('Purchase error: ${e.message}');
      }
      return false;
    } catch (e) {
      debugPrint('Unexpected error during purchase: $e');
      return false;
    }
  }

  /// Restore previous purchases (useful if user reinstalls app)
  static Future<bool> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();

      final hasEntitlement = customerInfo.entitlements.active.containsKey(
        _entitlementId,
      );
      debugPrint('Restore completed. Active entitlement: $hasEntitlement');

      return hasEntitlement;
    } catch (e) {
      debugPrint('Error restoring purchases: $e');
      return false;
    }
  }

  /// Get customer info (subscription details, expiry date, etc.)
  static Future<CustomerInfo?> getCustomerInfo() async {
    try {
      return await Purchases.getCustomerInfo();
    } catch (e) {
      debugPrint('Error fetching customer info: $e');
      return null;
    }
  }

  /// Get subscription expiry date (if active)
  static Future<DateTime?> getSubscriptionExpiryDate() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();

      if (customerInfo.entitlements.active.containsKey(_entitlementId)) {
        final entitlement = customerInfo.entitlements.active[_entitlementId];
        final expiryDateString = entitlement?.expirationDate;

        if (expiryDateString != null) {
          return DateTime.parse(expiryDateString);
        }
      }

      return null;
    } catch (e) {
      debugPrint('Error getting expiry date: $e');
      return null;
    }
  }

  /// Log out (clear user identity from RevenueCat)
  static Future<void> logout() async {
    try {
      await Purchases.logOut();
      debugPrint('User logged out from RevenueCat');
    } catch (e) {
      debugPrint('Error logging out: $e');
    }
  }

  /// Switch user (useful when a different user logs in)
  static Future<void> switchUser(String newCollegeUsername) async {
    try {
      await Purchases.logIn(newCollegeUsername);
      debugPrint('Switched to user: $newCollegeUsername');
    } catch (e) {
      debugPrint('Error switching user: $e');
      rethrow;
    }
  }
}
