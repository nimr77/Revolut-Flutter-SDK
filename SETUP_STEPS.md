# Revolut SDK Bridge - Complete Setup Steps

This document provides the exact steps to set up and integrate the Revolut SDK Bridge plugin into your Flutter project.

## 🚀 Quick Start (Automated)

The easiest way to set up the plugin is to use the automated setup script:

```bash
# Make sure you're in the revolut_sdk_bridge directory
chmod +x setup.sh
./setup.sh
```

The script will automatically:
- Add the dependency to your pubspec.yaml
- Configure Android build files
- Configure iOS Podfile
- Install dependencies
- Create configuration examples

## 📋 Manual Setup Steps

If you prefer to set up manually, follow these exact steps:

### Step 1: Add Plugin Dependency

Add to your `pubspec.yaml`:

```yaml
dependencies:
  revolut_sdk_bridge: ^1.0.0
```

Then run:
```bash
flutter pub get
```

### Step 2: Android Configuration

#### 2.1 Add Revolut SDK Repository

In `android/build.gradle`, add to the `allprojects` repositories section:

```gradle
allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url "https://maven.revolut.com/releases" }  // Add this line
    }
}
```

#### 2.2 Add Revolut SDK Dependencies

In `android/app/build.gradle`, add to the dependencies section:

```gradle
dependencies {
    implementation 'com.revolut:revolut-sdk:2.0.0'
    implementation 'com.revolut:revolut-auth:2.0.0'
    // ... other dependencies
}
```

#### 2.3 Update Minimum SDK Version

Ensure your `android/app/build.gradle` has:

```gradle
android {
    defaultConfig {
        minSdkVersion 24  // Must be at least 24
    }
}
```

#### 2.4 Configure URL Scheme

In `android/app/src/main/AndroidManifest.xml`, add inside your main activity:

```xml
<activity>
    <!-- ... existing activity configuration ... -->
    
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="your_app_scheme" />
    </intent-filter>
</activity>
```

Replace `your_app_scheme` with your actual scheme (e.g., `myapp`).

### Step 3: iOS Configuration

#### 3.1 Update Podfile

In `ios/Podfile`, add the Revolut SDK source:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/revolut/ios-sdk.git'  # Add this line

platform :ios, '13.0'  # Must be at least 13.0
```

#### 3.2 Install Pods

```bash
cd ios
pod install
cd ..
```

#### 3.3 Configure URL Scheme

In `ios/Runner/Info.plist`, add:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>com.yourcompany.yourapp</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>your_app_scheme</string>
        </array>
    </dict>
</array>
```

Replace `your_app_scheme` with your actual scheme.

### Step 4: Flutter Code Integration

#### 4.1 Import the Plugin

```dart
import 'package:revolut_sdk_bridge/revolut_sdk_bridge.dart';
```

#### 4.2 Initialize the SDK

```dart
bool initialized = await RevolutSdkBridge.initialize(
  clientId: 'your_client_id',
  clientSecret: 'your_client_secret',
  redirectUri: 'your_app_scheme://oauth/callback',
  environment: 'sandbox', // or 'production'
);
```

#### 4.3 Start OAuth Flow

```dart
String? authUrl = await RevolutSdkBridge.startOAuthFlow(
  scopes: ['read', 'write'],
  state: 'unique_state_string',
);
```

#### 4.4 Handle OAuth Callback

```dart
Map<String, dynamic>? callback = await RevolutSdkBridge.handleOAuthCallback(
  'your_app_scheme://oauth/callback?code=AUTHORIZATION_CODE&state=unique_state_string'
);
```

## 🔑 Required Credentials

You'll need to obtain these from the [Revolut Developer Dashboard](https://developer.revolut.com/):

- **Client ID**: Your app's unique identifier
- **Client Secret**: Your app's secret key
- **Redirect URI**: Your app's OAuth callback URL

## 🌐 URL Scheme Configuration

### What is a URL Scheme?

A URL scheme is a custom protocol that allows other apps to open your app. For example:
- `myapp://` - Opens your app
- `myapp://oauth/callback` - Opens your app with OAuth callback

### Choosing Your Scheme

- Use lowercase letters and numbers only
- Avoid special characters
- Make it unique to your app
- Examples: `myapp`, `revolutapp`, `fintech2024`

### Testing Your Scheme

After setup, test by opening this URL in your device's browser:
```
your_app_scheme://oauth/callback
```

## 🧪 Testing the Integration

### 1. Build and Run

```bash
flutter clean
flutter pub get
flutter run
```

### 2. Test Basic Functions

```dart
// Check if SDK is initialized
bool initialized = await RevolutSdkBridge.isInitialized();
print('SDK initialized: $initialized');

// Get platform version
String? version = await RevolutSdkBridge.getPlatformVersion();
print('Platform version: $version');
```

### 3. Test OAuth Flow

1. Initialize the SDK
2. Start OAuth flow
3. Open the generated URL in a WebView or browser
4. Complete authentication
5. Handle the callback

## 🐛 Common Issues and Solutions

### Build Errors

**Error**: `Could not resolve com.revolut:revolut-sdk:2.0.0`
**Solution**: Ensure the Revolut repository is added to `android/build.gradle`

**Error**: `minSdkVersion must be at least 24`
**Solution**: Update `minSdkVersion` to 24 or higher in `android/app/build.gradle`

**Error**: `platform :ios must be at least 13.0`
**Solution**: Update iOS platform version in `ios/Podfile`

### Runtime Errors

**Error**: `NOT_INITIALIZED`
**Solution**: Call `RevolutSdkBridge.initialize()` before other operations

**Error**: `INVALID_ARGUMENTS`
**Solution**: Check that all required parameters are provided

**Error**: `OAUTH_ERROR`
**Solution**: Verify your credentials and redirect URI

### URL Scheme Issues

**Problem**: App doesn't open when clicking OAuth callback links
**Solution**: 
1. Verify URL scheme is configured in both Android and iOS
2. Check that the scheme matches exactly in your redirect URI
3. Test the scheme manually

## 📱 Platform-Specific Notes

### Android

- Minimum SDK: 24 (Android 7.0)
- Requires internet permission
- OAuth callback handled via intent filters

### iOS

- Minimum iOS version: 13.0
- Requires URL scheme configuration
- OAuth callback handled via URL schemes

## 🔒 Security Considerations

1. **Never expose client secrets** in client-side code
2. **Use HTTPS** for all API communications
3. **Validate OAuth state** parameter to prevent CSRF attacks
4. **Store tokens securely** using Flutter secure storage
5. **Implement proper session management**

## 📚 Additional Resources

- [Revolut API Documentation](https://developer.revolut.com/)
- [Flutter Plugin Development Guide](https://flutter.dev/docs/development/packages-and-plugins/developing-packages)
- [OAuth 2.0 Best Practices](https://oauth.net/2/)
- [Flutter Secure Storage](https://pub.dev/packages/flutter_secure_storage)

## 🆘 Getting Help

If you encounter issues:

1. Check the troubleshooting section in README.md
2. Verify all configuration steps are completed
3. Check that your credentials are correct
4. Ensure URL schemes are properly configured
5. Create an issue on the project's GitHub repository

## ✅ Verification Checklist

Before testing, ensure you have:

- [ ] Added plugin dependency to pubspec.yaml
- [ ] Configured Android build.gradle files
- [ ] Configured iOS Podfile
- [ ] Set up URL schemes for both platforms
- [ ] Obtained Revolut API credentials
- [ ] Updated minimum SDK versions
- [ ] Installed all dependencies
- [ ] Built and run the project successfully

## 🎯 Next Steps

After successful setup:

1. Implement OAuth flow in your app
2. Add error handling and user feedback
3. Implement secure token storage
4. Add user interface for Revolut features
5. Test with real Revolut accounts
6. Deploy to production

---

**Happy coding! 🚀**

For the latest updates and support, check the project's GitHub repository.
