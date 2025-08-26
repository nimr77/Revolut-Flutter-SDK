# Revolut SDK Bridge - Cross-Platform Wrapper

This document explains how to use the new cross-platform wrapper for the Revolut SDK Bridge, which automatically handles platform differences between iOS and Android.

## Overview

The cross-platform wrapper provides a unified API that automatically selects the appropriate platform implementation (iOS or Android) at runtime. This means you can write code once and have it work on both platforms without platform-specific code.

## Key Benefits

- **Write Once, Run Everywhere**: Single codebase for both iOS and Android
- **Automatic Platform Detection**: No need to check platform manually
- **Unified API**: Consistent interface across platforms
- **Platform-Specific Features**: Access to platform-specific capabilities when needed
- **Fallback Handling**: Graceful degradation for unsupported features

## Quick Start

### 1. Import the Package

```dart
import 'package:revolut_sdk_bridge/revolut_sdk_bridge.dart';
```

### 2. Initialize the SDK

```dart
final revolutBridge = RevolutSdkBridge();

final success = await revolutBridge.initialize(
  merchantPublicKey: 'your_merchant_public_key',
  environment: 'sandbox', // or 'main' for production
);
```

### 3. Use Cross-Platform Widgets

```dart
CrossPlatformRevolutPayButton(
  orderToken: 'your_order_token',
  amount: 1000, // Amount in minor units (e.g., 1000 = £10.00)
  currency: 'GBP',
  email: 'customer@example.com',
  onPaymentResult: (result) {
    print('Payment result: ${result['success']}');
  },
  onError: (error) {
    print('Error: $error');
  },
)
```

## Available Classes

### RevolutSdkBridge

The main class for SDK initialization and management.

```dart
class RevolutSdkBridge {
  // Singleton instance
  static final RevolutSdkBridge _instance = RevolutSdkBridge._internal();
  factory RevolutSdkBridge() => _instance;
  
  // Platform detection
  bool get isAndroid => Platform.isAndroid;
  bool get isIOS => Platform.isIOS;
  
  // Core methods
  Future<bool> initialize({...});
  Future<Map<String, dynamic>?> createPaymentButton({...});
  Future<bool> processPayment({...});
  Future<String> getPlatformVersion();
}
```

### CrossPlatformRevolutPayButton

The main payment button widget that works on both platforms.

```dart
CrossPlatformRevolutPayButton({
  required String orderToken,
  required int amount,
  required String currency,
  required String email,
  bool shouldRequestShipping = false,
  bool savePaymentMethodForMerchant = false,
  String? returnURL,
  String? merchantName,
  String? merchantLogoURL,
  Map<String, dynamic>? additionalData,
  ButtonParamsData? buttonParams, // Android only
  double? height,
  double? width,
  EdgeInsetsGeometry? margin,
  EdgeInsetsGeometry? padding,
  BorderRadius? borderRadius,
  // Callbacks
  VoidCallback? onPressed,
  Function(String)? onError,
  Function(Map<String, dynamic>)? onPaymentResult,
  Function(String)? onPaymentError,
  VoidCallback? onPaymentCancelled,
  VoidCallback? onButtonCreated,
  VoidCallback? onButtonError,
})
```

### CrossPlatformSimpleRevolutPayButton

A simplified payment button with preset styling options.

```dart
CrossPlatformSimpleRevolutPayButton({
  required String orderToken,
  required int amount,
  required String currency,
  required String email,
  ButtonSize size = ButtonSize.large,
  ButtonRadius radius = ButtonRadius.medium,
  bool showCashback = false,
  String? cashbackCurrency,
  VoidCallback? onPressed,
  Function(String)? onError,
})
```

### CrossPlatformRevolutPayPromoBanner

Promotional banner widget (Android only, shows placeholder on iOS).

```dart
CrossPlatformRevolutPayPromoBanner({
  PromoBannerParamsData? promoParams,
  String? themeId,
  double? width,
  double? height,
  Function(String, String)? onInteraction,
  Function(String)? onError,
})
```

## Platform-Specific Features

### Android Features

- Controllers for managing confirmation flows
- Promotional banners
- Detailed button customization
- Direct payment processing

### iOS Features

- Button cleanup methods
- Simplified button creation
- Payment handling through buttons

### Cross-Platform Compatibility

| Feature | Android | iOS | Notes |
|---------|---------|-----|-------|
| SDK Initialization | ✅ | ✅ | Full support |
| Payment Buttons | ✅ | ✅ | Full support |
| Direct Payment | ✅ | ❌ | iOS uses button-based flow |
| Controllers | ✅ | ❌ | Android only |
| Promotional Banners | ✅ | ❌ | Shows placeholder on iOS |
| Button Cleanup | ❌ | ✅ | iOS only |

## Usage Examples

### Basic Payment Button

```dart
CrossPlatformRevolutPayButton(
  orderToken: 'order_123',
  amount: 2500, // £25.00
  currency: 'GBP',
  email: 'user@example.com',
  onPaymentResult: (result) {
    if (result['success'] == true) {
      print('Payment successful!');
    } else {
      print('Payment failed: ${result['error']}');
    }
  },
  onError: (error) {
    print('Button error: $error');
  },
)
```

### Advanced Payment Button with Customization

```dart
CrossPlatformRevolutPayButton(
  orderToken: 'order_456',
  amount: 5000, // £50.00
  currency: 'GBP',
  email: 'customer@example.com',
  shouldRequestShipping: true,
  savePaymentMethodForMerchant: true,
  returnURL: 'myapp://payment-return',
  merchantName: 'My Store',
  merchantLogoURL: 'https://example.com/logo.png',
  additionalData: {
    'order_id': '456',
    'customer_id': '789',
  },
  height: 70,
  width: double.infinity,
  margin: const EdgeInsets.all(16),
  borderRadius: BorderRadius.circular(12),
  onPaymentResult: (result) {
    // Handle payment result
  },
  onPaymentError: (error) {
    // Handle payment error
  },
  onPaymentCancelled: () {
    // Handle payment cancellation
  },
)
```

### Simple Payment Button

```dart
CrossPlatformSimpleRevolutPayButton(
  orderToken: 'order_789',
  amount: 1000, // £10.00
  currency: 'GBP',
  email: 'user@example.com',
  size: ButtonSize.medium,
  radius: ButtonRadius.small,
  showCashback: true,
  cashbackCurrency: 'GBP',
  onPressed: () {
    print('Button pressed!');
  },
  onError: (error) {
    print('Error: $error');
  },
)
```

## Error Handling

The cross-platform wrapper provides consistent error handling across platforms:

```dart
try {
  final success = await revolutBridge.initialize(
    merchantPublicKey: 'your_key',
    environment: 'sandbox',
  );
  
  if (success) {
    print('SDK initialized successfully');
  } else {
    print('SDK initialization failed');
  }
} catch (e) {
  print('Initialization error: $e');
}
```

## Platform Detection

You can detect the current platform and provide platform-specific logic when needed:

```dart
final bridge = RevolutSdkBridge();

if (bridge.isAndroid) {
  // Android-specific code
  final controller = await bridge.createController();
} else if (bridge.isIOS) {
  // iOS-specific code
  await bridge.cleanupAllButtons();
}
```

## Migration from Platform-Specific Code

### Before (Platform-Specific)

```dart
// Old way - platform-specific code
if (Platform.isAndroid) {
  final button = RevolutPayButton(
    buttonParams: buttonParams,
    orderToken: orderToken,
    onPressed: onPressed,
  );
} else if (Platform.isIOS) {
  final button = RevolutPayButtonIos(
    config: RevolutPayButtonConfigIos(
      orderToken: orderToken,
      amount: amount,
      currency: currency,
      email: email,
    ),
    onPaymentResult: onPaymentResult,
  );
}
```

### After (Cross-Platform)

```dart
// New way - cross-platform code
final button = CrossPlatformRevolutPayButton(
  orderToken: orderToken,
  amount: amount,
  currency: currency,
  email: email,
  onPaymentResult: onPaymentResult,
  onPressed: onPressed,
);
```

## Testing

The example app includes a cross-platform test page that demonstrates all the features. Access it by tapping the device hub icon in the app bar.

## Best Practices

1. **Use Cross-Platform Classes**: Prefer `CrossPlatformRevolutPayButton` over platform-specific widgets
2. **Handle Platform Differences**: Use platform detection only when necessary
3. **Test on Both Platforms**: Always test your implementation on both iOS and Android
4. **Error Handling**: Implement proper error handling for all async operations
5. **Fallbacks**: Provide fallback behavior for unsupported features

## Troubleshooting

### Common Issues

1. **Button Not Displaying**: Check if the SDK is properly initialized
2. **Platform Detection Failing**: Ensure you're using the latest version
3. **Callback Not Firing**: Verify callback function signatures match expected types

### Debug Information

```dart
final bridge = RevolutSdkBridge();
print('Platform: ${bridge.isAndroid ? "Android" : "iOS"}');
print('Platform Version: ${await bridge.getPlatformVersion()}');
```

## Support

For issues or questions about the cross-platform wrapper:

1. Check the example app for usage patterns
2. Review platform-specific documentation for advanced features
3. Test on both platforms to identify platform-specific issues

## Version Compatibility

The cross-platform wrapper is compatible with:
- Flutter: ^3.9.0
- Dart: ^3.9.0
- iOS: 12.0+
- Android: API 21+
