# Android Revolut SDK Bridge

This directory contains the Flutter implementation for the Android Revolut Pay SDK Bridge plugin. It provides a complete interface for integrating Revolut Pay payments in Flutter apps running on Android.

## Structure

```
lib/android/
├── enums/
│   └── revolut_enums.dart          # Enums for SDK configuration
├── models/
│   └── revolut_pay_models.dart     # Data models for SDK operations
├── services/
│   └── revolut_callbacks.dart      # Callback service for SDK events
├── widgets/
│   └── revolut_pay_button.dart    # Flutter widgets for Revolut Pay UI
├── revolut_sdk_bridge.dart         # Main export file
├── revolut_sdk_bridge_method_channel.dart  # Method channel implementation
├── revolut_sdk_bridge_platform_interface.dart  # Platform interface
├── example_usage.dart              # Example implementation
└── README.md                       # This file
```

## Features

- **SDK Initialization**: Initialize the Revolut Pay SDK with merchant credentials
- **Payment Processing**: Handle payment flows with order tokens
- **Button Integration**: Display native Revolut Pay buttons
- **Controller Management**: Manage payment confirmation flows
- **Event Handling**: Comprehensive callback system for all SDK events
- **Error Handling**: Robust error handling with detailed error information
- **Platform Views**: Native Android UI integration through platform views

## Quick Start

### 1. Initialize the SDK

```dart
import 'package:revolut_sdk_bridge/android/revolut_sdk_bridge_method_channel.dart';
import 'package:revolut_sdk_bridge/android/services/revolut_callbacks.dart';

// Set up callbacks
final callbacks = RevolutCallbacks();
callbacks.setOrderCompletedCallback((result) {
  print('Payment completed: ${result.orderId}');
});

// Initialize SDK bridge
final sdkBridge = RevolutSdkBridgeMethodChannel(callbacks);

// Initialize the SDK
final success = await sdkBridge.init(
  environment: 'SANDBOX', // or 'MAIN'
  returnUri: 'https://your-app.com/payment-return',
  merchantPublicKey: 'your_merchant_public_key',
  requestShipping: false,
);
```

### 2. Create a Payment Button

```dart
import 'package:revolut_sdk_bridge/android/widgets/revolut_pay_button.dart';

RevolutPayButton(
  buttonParams: ButtonParamsData(
    size: ButtonSize.large,
    radius: ButtonRadius.medium,
    boxText: BoxText.none,
  ),
  orderToken: 'your_order_token',
  onPressed: () {
    print('Button pressed!');
  },
  onError: (error) {
    print('Button error: $error');
  },
)
```

### 3. Process Payments

```dart
// Start a payment flow
final success = await sdkBridge.pay(
  orderToken: 'your_order_token',
  savePaymentMethodForMerchant: false,
);

// Or use a controller for more control
final controller = await sdkBridge.createController();
await sdkBridge.setOrderToken(
  orderToken: 'your_order_token',
  controllerId: controller.controllerId,
);
await sdkBridge.continueConfirmationFlow(
  controllerId: controller.controllerId,
);
```

## Callbacks

The plugin provides comprehensive callbacks for all SDK events:

- **Order Events**: `onOrderCompleted`, `onOrderFailed`, `onUserPaymentAbandoned`
- **Payment Status**: `onPaymentStatusUpdate`
- **Button Interactions**: `onButtonClick`
- **Controller State**: `onControllerStateChange`
- **Lifecycle Events**: `onLifecycleEvent`
- **Deep Links**: `onDeepLinkReceived`
- **Network Status**: `onNetworkStatusUpdate`
- **Debug Information**: `onDebugLog`, `onPerformanceMetric`

## Widgets

### RevolutPayButton

A customizable button widget that integrates with the native Revolut Pay SDK:

```dart
RevolutPayButton(
  buttonParams: ButtonParamsData(
    size: ButtonSize.large,
    radius: ButtonRadius.medium,
    boxText: BoxText.getCashbackValue,
    boxTextCurrency: 'GBP',
  ),
  orderToken: 'order_token',
  onPressed: () => print('Button pressed'),
  onError: (error) => print('Error: $error'),
)
```

### SimpleRevolutPayButton

A simplified button with default styling:

```dart
SimpleRevolutPayButton(
  orderToken: 'order_token',
  onPressed: () => print('Button pressed'),
  showCashback: true,
  cashbackCurrency: 'GBP',
)
```

### RevolutPayPromoBanner

A promotional banner widget:

```dart
RevolutPayPromoBanner(
  promoParams: PromoBannerParamsData(
    customParam: 'promo_code',
  ),
  themeId: 'dark_theme',
  onInteraction: (bannerId, interactionType) {
    print('Banner interaction: $interactionType');
  },
)
```

## Data Models

The plugin provides comprehensive data models for all SDK operations:

- **CustomerData**: Customer information for payments
- **ButtonParamsData**: Button customization parameters
- **PaymentFlowData**: Payment flow configuration
- **SdkInitData**: SDK initialization parameters

## Error Handling

All operations include comprehensive error handling:

```dart
try {
  final result = await sdkBridge.pay(orderToken: 'token');
} on RevolutSdkException catch (e) {
  print('SDK Error: ${e.code} - ${e.message}');
} catch (e) {
  print('Unexpected error: $e');
}
```

## Platform Integration

The plugin uses Flutter's platform view system to integrate native Android UI components:

- **Method Channel**: For method calls between Flutter and native Android
- **Event Channel**: For receiving events from the native side
- **Platform Views**: For displaying native Android UI components

## Requirements

- Flutter 3.0.0 or higher
- Android API level 21 or higher
- Revolut Pay SDK for Android
- Proper Android manifest configuration

## Configuration

Ensure your Android manifest includes the necessary permissions and activities for Revolut Pay integration.

## Example

See `example_usage.dart` for a complete working example of the plugin integration.

## Support

For issues and questions, please refer to the main plugin documentation or create an issue in the repository.
