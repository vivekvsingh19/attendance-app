# Android Release Signing Setup

This guide explains how to set up Android app signing for release builds.

## What is key.properties?

The `key.properties` file contains sensitive information needed to sign your Android app for release. This includes:
- Path to your keystore file
- Keystore password
- Key alias
- Key password

## Setting up for Release Builds

### Step 1: Generate a Keystore

Run this command in your terminal:

```bash
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Follow the prompts to set:
- Keystore password
- Key password  
- Your name and organization details

### Step 2: Move the Keystore

Move the generated `upload-keystore.jks` file to the `android/` directory (same level as `key.properties`).

### Step 3: Update key.properties

Edit the `android/key.properties` file and replace the placeholder values:

```properties
storeFile=upload-keystore.jks
storePassword=your_actual_store_password
keyAlias=upload
keyPassword=your_actual_key_password
```

### Step 4: Build Release APK

```bash
flutter build apk --release
```

## Security Notes

- **Never commit keystore files or key.properties to version control**
- Both files are already in `.gitignore` 
- Keep backups of your keystore in a secure location
- If you lose your keystore, you cannot update your app on Google Play Store

## Development Builds

For development and testing, you can continue using debug builds:

```bash
flutter run
# or
flutter build apk --debug
```

Debug builds don't require the keystore setup.