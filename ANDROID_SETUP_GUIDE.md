# Android Revolut SDK Setup Guide

This guide provides step-by-step instructions for setting up and configuring the Revolut SDK Bridge for Android in your Flutter project.

## Prerequisites

- Flutter 3.3.0 or higher
- Android Studio or VS Code with Flutter extensions
- Android SDK (API level 24+)
- Physical Android device for testing (recommended)
- Revolut Business account with API access

## Quick Start

### 1. Run the Setup Script

The easiest way to get started is to run the provided setup script:

```bash
./setup_android.sh
```

This script will:
- Verify your project structure
- Check Flutter and Android SDK installation
- Update dependencies
- Verify build configuration
- Provide setup instructions

### 2. Manual Setup

If you prefer to set up manually or need to customize the configuration, follow the steps below.

## Manual Setup Steps

### Step 1: Update Dependencies

#### Plugin Level (`android/build.gradle`)

```gradle
dependencies {
    // Revolut Pay SDK dependencies
    implementation 'com.revolut:revolut-pay-sdk:2.0.0'
    implementation 'com.revolut:revolut-pay-ui:2.0.0'
    
    // Android lifecycle dependencies
    implementation 'androidx.lifecycle:lifecycle-runtime-ktx:2.7.0'
    implementation 'androidx.lifecycle:lifecycle-common-java8:2.7.0'
    
    // Android core dependencies
    implementation 'androidx.core:core-ktx:1.12.0'
    implementation 'androidx.appcompat:appcompat:1.6.1'
}
```

#### Repository Configuration

Add the Revolut repository to your `android/build.gradle`:

```gradle
repositories {
    google()
    mavenCentral()
    maven { url "https://maven.revolut.com/releases" }
}
```

### Step 2: Example App Configuration

#### Example App Dependencies (`example/android/app/build.gradle.kts`)

```kotlin
dependencies {
    // Revolut Pay SDK dependencies
    implementation("com.revolut:revolut-pay-sdk:2.0.0")
    implementation("com.revolut:revolut-pay-ui:2.0.0")
    
    // Android lifecycle dependencies
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.7.0")
    implementation("androidx.lifecycle:lifecycle-common-java8:2.7.0")
}
```

#### Example App Repository (`example/android/app/build.gradle.kts`)

```kotlin
repositories {
    google()
    mavenCentral()
    maven { url = uri("https://maven.revolut.com/releases") }
}
```

#### Example App Settings (`example/android/settings.gradle.kts`)

```kotlin
repositories {
    google()
    mavenCentral()
    gradlePluginPortal()
    maven { url = uri("https://maven.revolut.com/releases") }
}
```

### Step 3: Android Manifest Configuration

#### Plugin Manifest (`android/src/main/AndroidManifest.xml`)

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
  package="com.example.revolut_sdk_bridge">

  <!-- Internet permission for Revolut SDK -->
  <uses-permission android:name="android.permission.INTERNET" />
  
  <!-- Network state permission for Revolut SDK -->
  <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
  
  <!-- Query all packages permission for deep linking -->
  <uses-permission android:name="android.permission.QUERY_ALL_PACKAGES" />

  <application>
    <!-- Revolut SDK deep link handling -->
    <activity android:name=".RevolutDeepLinkActivity"
              android:exported="true"
              android:launchMode="singleTask">
      <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="revolut" />
      </intent-filter>
    </activity>
  </application>
</manifest>
```

#### Example App Manifest (`example/android/app/src/main/AndroidManifest.xml`)

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    
    <!-- Internet permission for Revolut SDK -->
    <uses-permission android:name="android.permission.INTERNET" />
    
    <!-- Network state permission for Revolut SDK -->
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    
    <!-- Query all packages permission for deep linking -->
    <uses-permission android:name="android.permission.QUERY_ALL_PACKAGES" />
    
    <application
        android:label="revolut_sdk_bridge_example"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:taskAffinity=""
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            
            <meta-data
              android:name="io.flutter.embedding.android.NormalTheme"
              android:resource="@style/NormalTheme"
              />
              
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
            
            <!-- Deep link handling for Revolut SDK -->
            <intent-filter>
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <data android:scheme="revolut" />
            </intent-filter>
        </activity>
        
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
    
    <queries>
        <intent>
            <action android:name="android.intent.action.PROCESS_TEXT"/>
            <data android:mimeType="text/plain"/>
        </intent>
        
        <!-- Query for Revolut app for deep linking -->
        <package android:name="com.revolut.android" />
    </queries>
</manifest>
```

### Step 4: Configure Your Credentials

#### Update Example App

Edit `lib/android/example_usage.dart` and update the configuration:

```dart
// Configuration
final String _merchantPublicKey = 'your_actual_merchant_public_key_here';
final String _returnUri = 'revolut://your-app-payment-callback';
final RevolutEnvironment _environment = RevolutEnvironment.sandbox; // or RevolutEnvironment.main
```

#### Get Your Credentials

1. **Merchant Public Key**: 
   - Log into your [Revolut Business dashboard](https://business.revolut.com/)
   - Go to Settings → APIs → Merchant API
   - Copy your Public key

2. **Return URI**: 
   - Choose a custom scheme for your app (e.g., `revolut://payment-callback`)
   - Update the manifest files with this scheme
   - Ensure it matches what you configure in the SDK

### Step 5: Test the Integration

#### Run the Example App

```bash
cd example
flutter run
```

#### Test on Device

1. **Physical Device**: 
   - Connect your Android device
   - Enable USB debugging
   - Install the Revolut app on your device
   - Run the example app

2. **Emulator**: 
   - Note: Some features may not work properly on emulators
   - Use a physical device for full testing

## Configuration Options

### Environment

- **SANDBOX**: For testing and development
- **MAIN**: For production use

### Button Customization

```dart
final buttonParams = ButtonParamsData(
  radius: ButtonRadius.medium,        // NONE, SMALL, MEDIUM, LARGE
  size: ButtonSize.large,            // EXTRA_SMALL, SMALL, MEDIUM, LARGE
  boxText: BoxText.getCashbackValue, // NONE, GET_CASHBACK_VALUE, GET_CASHBACK_PERCENTAGE
  boxTextCurrency: 'GBP',            // GBP, EUR, USD
  variantModes: VariantModesData(
    darkTheme: ButtonVariant.dark,   // LIGHT, DARK
    lightTheme: ButtonVariant.light,
  ),
);
```

### Customer Pre-fill

```dart
final customer = CustomerData(
  name: 'John Doe',
  email: 'john@example.com',
  phone: '+44123456789',
  country: CountryData(value: 'GB'),
  dateOfBirth: DateOfBirthData(
    day: 15,
    month: 6,
    year: 1990,
  ),
);
```

## Testing

### Test Payment Flow

1. **Initialize SDK**: Ensure successful initialization
2. **Create Controller**: Verify controller creation
3. **Set Order Token**: Use a test order token from your backend
4. **Continue Flow**: Test the payment confirmation flow
5. **Handle Callbacks**: Verify order completion/failure handling

### Test Deep Links

1. **Configure Return URI**: Ensure your app can handle the return URI
2. **Test Deep Link**: Use ADB to test deep link handling:

```bash
adb shell am start -W -a android.intent.action.VIEW -d "revolut://payment-callback" com.example.revolut_sdk_bridge_example
```

## Troubleshooting

### Common Issues

#### Build Errors

1. **Repository Not Found**:
   - Ensure Revolut repository is added to all build.gradle files
   - Check network connectivity to maven.revolut.com

2. **Dependency Resolution**:
   - Clean and rebuild: `flutter clean && flutter pub get`
   - Check Android SDK version compatibility

3. **Permission Issues**:
   - Verify all required permissions are declared in manifests
   - Check target SDK version compatibility

#### Runtime Errors

1. **SDK Not Initialized**:
   - Ensure `init()` is called before other methods
   - Check that all required parameters are provided

2. **Deep Link Not Working**:
   - Verify intent filter configuration
   - Check scheme matches between manifest and code
   - Test with ADB commands

3. **Payment Flow Issues**:
   - Verify order token is valid
   - Check network connectivity
   - Ensure Revolut app is installed on device

### Debug Information

Enable debug logging:

```dart
callbacks.setDebugLogCallback((level, message, data) {
  print('Revolut SDK Debug: $level - $message');
  if (data != null) print('Data: $data');
});
```

### Logs

Check Android logs for detailed error information:

```bash
adb logcat | grep -i revolut
```

## Production Deployment

### Security Considerations

1. **API Keys**: Never commit API keys to version control
2. **Environment**: Use production environment for live apps
3. **Deep Links**: Use secure, app-specific schemes
4. **Permissions**: Only request necessary permissions

### App Store Requirements

1. **Privacy Policy**: Include Revolut SDK usage in your privacy policy
2. **Terms of Service**: Update terms to include payment processing
3. **App Review**: Ensure compliance with store guidelines

### Testing Checklist

- [ ] SDK initializes successfully
- [ ] Payment flow works end-to-end
- [ ] Deep links handle returns properly
- [ ] Error handling works correctly
- [ ] UI components display properly
- [ ] Callbacks fire as expected
- [ ] App handles background/foreground transitions

## Support and Resources

### Documentation

- [Revolut SDK Documentation](https://developer.revolut.com/docs/sdks/merchant-android-sdk)
- [Android Implementation Guide](lib/android/README.md)
- [Example Usage](lib/android/example_usage.dart)

### Community

- [Revolut Developer Portal](https://developer.revolut.com/)
- [Flutter Community](https://flutter.dev/community)
- [GitHub Issues](https://github.com/your-repo/issues)

### Getting Help

1. Check the troubleshooting section above
2. Review the example implementation
3. Consult Revolut SDK documentation
4. Search existing issues
5. Create a new issue with detailed information

## Version History

- **v1.0.0**: Initial release with full Revolut SDK integration
- Supports all major SDK features
- Comprehensive error handling
- Full lifecycle management
- Deep link support

---

**Note**: This guide is based on Revolut SDK version 2.0.0. For the latest information, always refer to the [official Revolut documentation](https://developer.revolut.com/docs/sdks/merchant-android-sdk).
