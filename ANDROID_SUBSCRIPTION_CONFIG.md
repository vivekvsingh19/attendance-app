# Android Configuration for RevenueCat Subscriptions

## Required Android Manifest Permissions

The `purchases_flutter` package automatically adds the necessary permissions, but verify these are in your `android/app/src/main/AndroidManifest.xml`:

```xml
<!-- Billing permission is automatically added by the package -->
<uses-permission android:name="com.android.vending.BILLING" />
```

## Gradle Configuration

### 1. Check `android/app/build.gradle`

The billing library should be automatically added by the package, but if you encounter issues, ensure you have:

```gradle
dependencies {
    // ... other dependencies

    // Billing library (usually auto-added by purchases_flutter)
    implementation 'com.android.billingclient:billing:6.0.1'
}
```

### 2. Minimum SDK Version

Ensure your `android/app/build.gradle` has minimum SDK 21 or higher:

```gradle
android {
    defaultConfig {
        minSdkVersion 21  // Required for RevenueCat
        targetSdkVersion flutter.targetSdkVersion
    }
}
```

## Proguard Rules (For Release Builds)

If you're using ProGuard/R8 (release builds), add these rules to `android/app/proguard-rules.pro`:

```proguard
# RevenueCat
-keep class com.revenuecat.purchases.** { *; }
-keep class com.android.billingclient.** { *; }

# Keep the PurchasesConfiguration
-keepclassmembers class com.revenuecat.purchases.PurchasesConfiguration {
    *;
}
```

If the file doesn't exist, create it and reference it in `android/app/build.gradle`:

```gradle
buildTypes {
    release {
        signingConfig signingConfigs.release
        minifyEnabled true
        proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
    }
}
```

## Build Configuration

### For Debug Builds:
```bash
flutter build apk --debug
# or
flutter run
```

### For Release Builds (Required for Testing on Play Store):
```bash
flutter build appbundle --release
# or
flutter build apk --release
```

**Important:** Test purchases only work with:
- Release builds (not debug)
- App signed with the same certificate uploaded to Google Play
- Test accounts added as license testers in Play Console

## Testing with Internal Testing Track

1. Build release APK/AAB:
   ```bash
   flutter build appbundle --release
   ```

2. Upload to Google Play Console → Internal Testing track

3. Add testers to Internal Testing

4. Testers download app from Play Store

5. Purchases will be in test mode (no actual charges)

## Google Play Console Configuration

### 1. Upload App Bundle
- Go to Google Play Console
- Navigate to **Production** or **Internal Testing**
- Upload your signed app bundle (`.aab` file)
- Complete the store listing

### 2. Create Subscription Product
- Go to **Monetize → Subscriptions**
- Click **Create subscription**
- Product ID: `monthly_pro` (or your choice)
- Set price: ₹12.00
- Billing period: 1 month
- Save and activate

### 3. Add Test Users
- Go to **Internal app sharing** or **Internal testing**
- Add email addresses of testers
- These users can make test purchases without charges

### 4. Link Google Play to RevenueCat
1. Create Google Service Account:
   - Go to Google Cloud Console
   - Create new service account
   - Download JSON key file

2. Upload to RevenueCat:
   - Go to RevenueCat Project Settings
   - Select your Android app
   - Upload the service account JSON
   - Grant necessary permissions

## Troubleshooting

### Issue: "Billing not available"
- Ensure app is signed with release keystore
- Verify billing library is included
- Check that device has Google Play Store
- Ensure subscription product is active in Play Console

### Issue: "Item not available for purchase"
- Product must be published (at least in internal testing)
- Product ID in code must match Play Console
- App version in Play Console must match installed version
- Wait 2-4 hours after publishing for products to propagate

### Issue: "Cannot find subscription offering"
- Check RevenueCat offering is configured correctly
- Verify product is attached to offering
- Ensure entitlement is attached to product
- Check RevenueCat API key is correct

### Issue: Test purchases not working
- Must use release build (not debug)
- Must be signed with correct keystore
- Test account must be added in Play Console
- Subscription must be active in Play Console

## Signing Configuration

Ensure your `android/app/build.gradle` has proper signing:

```gradle
android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile file(keystoreProperties['storeFile'])
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

## Package Name

Your package name must match across:
- ✅ `android/app/build.gradle` → `applicationId`
- ✅ Google Play Console → App
- ✅ RevenueCat Dashboard → Android app

Example:
```gradle
android {
    defaultConfig {
        applicationId "com.viveksingh.upasthit"  // Your actual package name
    }
}
```

## Testing Checklist

Before submitting to Play Store:

- [ ] App builds in release mode without errors
- [ ] App is signed with production keystore
- [ ] Package name matches Play Console
- [ ] Billing permission is in manifest
- [ ] Subscription product is created and active
- [ ] RevenueCat is linked to Google Play
- [ ] RevenueCat offering is configured
- [ ] Test purchase works with test account
- [ ] Restore purchases works
- [ ] Subscription status updates correctly
- [ ] Logout clears subscription state

## Build Commands Reference

```bash
# Clean build
flutter clean
flutter pub get

# Debug build (for development)
flutter run

# Release APK (for testing)
flutter build apk --release

# Release App Bundle (for Play Store)
flutter build appbundle --release

# Check for issues
flutter doctor
flutter pub outdated
```

## Final Notes

1. **Always test with release builds** when testing subscriptions
2. **Use Internal Testing track** for pre-launch testing
3. **Wait 2-4 hours** after publishing products for them to be available
4. **RevenueCat API key** must be the production key (not debug)
5. **Google Play service account** must have proper permissions in Play Console

For more details, see:
- Google Play Billing: https://developer.android.com/google/play/billing/integrate
- RevenueCat Android: https://docs.revenuecat.com/docs/android
