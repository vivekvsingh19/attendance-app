# Forced App Update Implementation

## Overview
This app now implements forced updates using the `upgrader` package. When you publish a new version to the app stores, users will be forced to update before they can continue using the app.

## How it works

### 1. Upgrader Package
- Already included in `pubspec.yaml`
- Automatically checks app stores for newer versions
- Shows update dialog when newer version is available

### 2. ForcedUpdateWrapper Widget
- Located in `lib/widgets/forced_update_wrapper.dart`
- Wraps the entire MaterialApp
- Prevents users from dismissing the update dialog
- Uses `PopScope` to block back navigation during updates

### 3. Configuration
- **Update Check Frequency**: Every 10 seconds (configurable)
- **Dialog Style**: Material Design
- **Region**: India (IN)
- **Language**: English (en)

## Testing the Forced Update

### For Development Testing:
1. In `lib/widgets/forced_update_wrapper.dart`, change:
   ```dart
   debugDisplayAlways: true, // Shows dialog even if no update available
   ```

2. Run the app - you'll see the update dialog

### For Production:
1. Keep `debugDisplayAlways: false`
2. Publish new version to Play Store/App Store
3. Users with older versions will see the update dialog

## Release Process for Forced Updates

### 1. Update Version Number
In `pubspec.yaml`:
```yaml
version: 1.2.5+10  # Increment version and build number
```

### 2. Build and Publish
- Build APK/AAB for Android
- Build IPA for iOS
- Upload to respective app stores

### 3. Automatic Enforcement
- Users with older versions will automatically see update prompt
- They cannot use the app until they update
- Back button is disabled during update dialog

## Key Features

✅ **Non-dismissible Dialog**: Users cannot close the update dialog
✅ **Back Button Blocked**: Prevents navigation away from update screen
✅ **Frequent Checks**: Checks for updates every 10 seconds
✅ **User Feedback**: Shows snackbar if user tries to go back
✅ **Store Integration**: Works with Google Play Store and Apple App Store

## Customization

### Change Update Check Frequency
```dart
durationUntilAlertAgain: const Duration(minutes: 5), // Check every 5 minutes
```

### Customize Messages
```dart
messages: UpgraderMessages(
  code: 'en',
  // Add custom message overrides here
),
```

### Change Dialog Style
```dart
dialogStyle: UpgradeDialogStyle.cupertino, // iOS style
// or
dialogStyle: UpgradeDialogStyle.material,  // Android style
```

## Important Notes

1. **Store Approval**: Updates only trigger after new version is live on stores
2. **Version Format**: Use semantic versioning (major.minor.patch+build)
3. **Testing**: Always test with `debugDisplayAlways: true` before release
4. **Rollback**: If needed, can temporarily disable by commenting out ForcedUpdateWrapper

## Production Checklist

- [ ] Set `debugDisplayAlways: false`
- [ ] Update version number in `pubspec.yaml`
- [ ] Test app functionality
- [ ] Build release version
- [ ] Upload to app stores
- [ ] Monitor user adoption