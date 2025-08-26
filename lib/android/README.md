# Revolut SDK Bridge - Android Implementation

This directory contains the Android-specific implementation of the Revolut SDK Bridge plugin for Flutter.

## Overview

The Android implementation provides a bridge between Flutter and the native Revolut Pay Android SDK, allowing you to integrate Revolut payment functionality into your Flutter applications.

## Features

- **SDK Initialization**: Initialize the Revolut Pay SDK with environment and merchant configuration
- **Payment Flow Management**: Create controllers to manage payment confirmation flows
- **UI Components**: Generate Revolut Pay buttons and promotional banners
- **Direct Payment**: Initiate payments programmatically without UI components
- **Deep Link Handling**: Process return URIs and handle payment callbacks
- **Lifecycle Management**: Proper Android lifecycle integration for SDK state management

## Setup

### 1. Dependencies

The Android implementation requires the following dependencies in your `android/build.gradle`:

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

### 2. Repository Configuration

Add the Revolut repository to your `android/build.gradle`:

```gradle
repositories {
    google()
    mavenCentral()
    maven { url "https://maven.revolut.com/releases" }
}
```

### 3. Permissions

Add the following permissions to your `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.QUERY_ALL_PACKAGES" />
```

### 4. Deep Link Configuration

Configure deep link handling in your `AndroidManifest.xml`:

```xml
<activity android:name=".MainActivity">
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="revolut" />
    </intent-filter>
</activity>
```

## Usage

### 1. Initialize the SDK

```dart
final sdkBridge = RevolutSdkBridgeMethodChannel(RevolutCallbacks());

final success = await sdkBridge.init(
  environment: RevolutEnvironment.sandbox.value,
  returnUri: 'revolut://payment-callback',
  merchantPublicKey: 'your_merchant_public_key',
  requestShipping: false,
  customer: CustomerData(
    name: 'John Doe',
    email: 'john@example.com',
    phone: '+44123456789',
    country: CountryData(value: 'GB'),
  ).toMap(),
);
```

### 2. Create a Controller

```dart
final result = await sdkBridge.createController();
if (result.success) {
  final controllerId = result.controllerId;
  // Store controllerId for later use
}
```

### 3. Set Order Token

```dart
final success = await sdkBridge.setOrderToken(
  orderToken: 'order_token_from_backend',
  controllerId: controllerId,
);
```

### 4. Continue Confirmation Flow

```dart
final success = await sdkBridge.continueConfirmationFlow(
  controllerId: controllerId,
);
```

### 5. Create a Button

```dart
final buttonParams = ButtonParamsData(
  radius: ButtonRadius.medium,
  size: ButtonSize.large,
  boxText: BoxText.getCashbackValue,
  boxTextCurrency: 'GBP',
  variantModes: VariantModesData(
    darkTheme: ButtonVariant.dark,
    lightTheme: ButtonVariant.light,
  ),
);

final result = await sdkBridge.provideButton(
  buttonParams: buttonParams.toMap(),
);
```

### 6. Initiate Direct Payment

```dart
final success = await sdkBridge.pay(
  orderToken: 'order_token_from_backend',
  savePaymentMethodForMerchant: false,
);
```

### 7. Create Promotional Banner

```dart
final promoParams = PromoBannerParamsData(
  customParam: 'promo_code',
);

final result = await sdkBridge.providePromotionalBannerWidget(
  promoParams: promoParams.toMap(),
  themeId: 'default',
);
```

### 8. Handle Callbacks

```dart
final callbacks = RevolutCallbacks();

callbacks.setOrderCompletedCallback((result) {
  print('Payment completed: ${result.orderId}');
});

callbacks.setOrderFailedCallback((result) {
  print('Payment failed: ${result.error}');
});

callbacks.setUserPaymentAbandonedCallback((result) {
  print('Payment abandoned by user');
});
```

## Architecture

### Core Components

1. **RevolutSdkBridgePlugin**: Main plugin class that handles method calls and manages SDK state
2. **RevolutSdkBridgeMethodChannel**: Flutter method channel implementation for communication
3. **RevolutCallbacks**: Service class for managing SDK event callbacks
4. **Data Models**: Dart classes representing SDK data structures

### Method Channel

The plugin uses a method channel named `revolut_sdk_bridge` for communication between Flutter and native Android code.

### Event Handling

Events from the native SDK are forwarded to Flutter through the method channel and processed by the `RevolutCallbacks` service.

## Error Handling

The plugin provides comprehensive error handling with detailed error codes and messages:

- `INIT_ERROR`: SDK initialization failures
- `PAY_ERROR`: Payment flow errors
- `CONTROLLER_ERROR`: Controller management errors
- `BUTTON_ERROR`: Button creation errors
- `BANNER_ERROR`: Banner creation errors

## Lifecycle Management

The plugin properly integrates with Android lifecycle events:

- **onAttachedToActivity**: Sets up activity binding and lifecycle
- **onDetachedFromActivity**: Cleans up resources
- **onReattachedToActivityForConfigChanges**: Handles configuration changes

## Deep Link Processing

Deep links are processed through:

1. **RevolutDeepLinkActivity**: Dedicated activity for handling deep links
2. **MainActivity**: Main activity with deep link support
3. **Method Channel**: Forwarding deep link data to Flutter

## Testing

The plugin includes comprehensive testing:

- **Unit Tests**: Testing individual methods and error handling
- **Integration Tests**: Testing method channel communication
- **Example App**: Complete working example with all features

## Troubleshooting

### Common Issues

1. **SDK Not Initialized**: Ensure `init()` is called before other methods
2. **Missing Permissions**: Check that all required permissions are declared
3. **Repository Issues**: Verify Revolut repository is properly configured
4. **Deep Link Problems**: Ensure deep link scheme matches your configuration

### Debug Information

Enable debug logging to troubleshoot issues:

```dart
callbacks.setDebugLogCallback((level, message, data) {
  print('Revolut SDK Debug: $level - $message');
});
```

## Example Implementation

See `example_usage.dart` for a complete working example that demonstrates all SDK features.

## Support

For issues and questions:

1. Check the troubleshooting section above
2. Review the example implementation
3. Consult the Revolut SDK documentation
4. Check the plugin's issue tracker

## Version Compatibility

- **Flutter**: >=3.3.0
- **Android**: API level 24+
- **Revolut SDK**: 2.0.0
- **Kotlin**: 2.1.0
