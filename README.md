# Revolut SDK Bridge

A Flutter plugin that provides a bridge to the native Revolut Pay SDK for both Android and iOS, allowing you to accept Revolut Pay payments in your Flutter apps.

## 🚀 Features

- **Cross-platform support**: Works on both Android and iOS
- **Full Revolut SDK integration**: Implements all major Revolut Pay SDK features
- **Payment processing**: Handle payments with order tokens
- **Button creation**: Create Revolut Pay buttons with customization
- **Promotional banners**: Display promotional content to boost conversions
- **Payment controllers**: Manage payment flows and confirmation processes
- **Event handling**: Receive real-time updates on payment status
- **Deep link support**: Handle payment returns seamlessly

## 📱 Supported Platforms

- **Android**: API level 21+ (Android 5.0+)
- **iOS**: iOS 13.0+

## 🔧 Installation

### 1. Add the dependency

```yaml
dependencies:
  revolut_sdk_bridge: ^1.0.0
```

### 2. Platform-specific setup

#### Android Setup

1. **Add permissions** to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

<!-- Declare Revolut app query -->
<queries>
    <package android:name="com.revolut.revolut" />
</queries>

<application>
    <!-- Deep link configuration for payment return -->
    <activity
        android:name=".RevolutSdkBridgeActivity"
        android:launchMode="singleTop"
        android:exported="true">
        <intent-filter>
            <action android:name="android.intent.action.VIEW" />
            <category android:name="android.intent.category.DEFAULT" />
            <category android:name="android.intent.category.BROWSABLE" />
            <data
                android:host="payment-return"
                android:scheme="revolutbridge" />
        </intent-filter>
    </activity>
</application>
```

2. **Update build.gradle** to include Revolut SDK dependencies:

```gradle
dependencies {
    implementation 'com.revolut:revolutpayments:1.0.0'
    implementation 'com.revolut:revolutpay:2.8'
}
```

#### iOS Setup

1. **Update Podfile** to include Revolut SDK source:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/revolut/ios-sdk.git'

platform :ios, '13.0'
```

2. **Install pods**:

```bash
cd ios
pod install
cd ..
```

3. **Configure URL scheme** in `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>com.yourcompany.yourapp</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>revolutbridge</string>
        </array>
    </dict>
</array>
```

## 🚀 Quick Start

### 1. Initialize the SDK

```dart
import 'package:revolut_sdk_bridge/revolut_sdk_bridge.dart';

// Initialize the Revolut SDK
final sdkBridge = RevolutSdkBridge();

try {
  final initialized = await sdkBridge.initialize(
    merchantPublicKey: 'your_merchant_public_key',
    environment: 'sandbox', // or 'main' for production
    returnUri: 'revolutbridge://payment-return',
  );
  
  if (initialized) {
    print('Revolut SDK initialized successfully');
  }
} catch (e) {
  print('Failed to initialize Revolut SDK: $e');
}
```

### 2. Create a Payment Button

```dart
// Create a Revolut Pay button
final buttonResult = await sdkBridge.createPaymentButton(
  orderToken: 'your_order_token',
  amount: 1000, // Amount in minor units (e.g., 1000 for £10.00)
  currency: 'GBP',
  email: 'customer@example.com',
  shouldRequestShipping: false,
  savePaymentMethodForMerchant: false,
);

if (buttonResult != null) {
  print('Button created: ${buttonResult['buttonId']}');
}
```

### 3. Process a Payment

```dart
// Process a payment with an order token
try {
  final success = await sdkBridge.processPayment(
    orderToken: 'your_order_token',
    savePaymentMethodForMerchant: false,
  );
  
  if (success) {
    print('Payment initiated successfully');
  }
} catch (e) {
  print('Payment failed: $e');
}
```

### 4. Handle Payment Controllers

```dart
// Create a payment controller
final controllerResult = await sdkBridge.createController();
if (controllerResult != null) {
  final controllerId = controllerResult['controllerId'];
  
  // Set order token on the controller
  await sdkBridge.setOrderToken(
    orderToken: 'your_order_token',
    controllerId: controllerId,
  );
  
  // Continue confirmation flow if needed
  await sdkBridge.continueConfirmationFlow(controllerId: controllerId);
  
  // Dispose the controller when done
  await sdkBridge.disposeController(controllerId: controllerId);
}
```

### 5. Create Promotional Banners

```dart
// Create a promotional banner
final bannerResult = await sdkBridge.providePromotionalBannerWidget(
  promoParams: {
    'transactionId': 'transaction_123',
    'paymentAmount': 1000,
    'currency': 'GBP',
    'customer': {
      'name': 'John Doe',
      'email': 'john@example.com',
      'phone': '+44123456789',
      'country': 'GB',
      'dateOfBirth': {
        'day': 15,
        'month': 6,
        'year': 1990,
      },
    },
  },
  themeId: 'default',
);

if (bannerResult != null) {
  print('Banner created: ${bannerResult['bannerId']}');
}
```

## 📋 API Reference

### Core Methods

#### `initialize()`
Initializes the Revolut SDK with your merchant configuration.

**Parameters:**
- `merchantPublicKey` (required): Your merchant public API key
- `environment`: 'sandbox' or 'main' (default: 'sandbox')
- `returnUri`: Deep link URI for payment returns
- `requestShipping`: Whether to request shipping details
- `customer`: Customer information for the payment

#### `processPayment()`
Initiates a payment flow with the given order token.

**Parameters:**
- `orderToken` (required): Order token from your server
- `savePaymentMethodForMerchant`: Whether to save payment method

#### `createPaymentButton()`
Creates a Revolut Pay button for payment processing.

**Parameters:**
- `orderToken` (required): Order token for the payment
- `amount` (required): Payment amount in minor units
- `currency` (required): Payment currency (e.g., 'GBP', 'EUR', 'USD')
- `email` (required): Customer email address
- `shouldRequestShipping`: Whether to request shipping details
- `savePaymentMethodForMerchant`: Whether to save payment method
- `returnURL`: Custom return URL
- `merchantName`: Merchant name to display
- `merchantLogoURL`: URL to merchant logo
- `additionalData`: Additional payment data

### Controller Methods

#### `createController()`
Creates a payment controller for managing payment flows.

#### `setOrderToken()`
Sets the order token on a controller.

#### `setSavePaymentMethodForMerchant()`
Configures whether to save payment method for merchant.

#### `continueConfirmationFlow()`
Continues the confirmation flow on a controller.

#### `disposeController()`
Disposes a controller and cleans up resources.

### Banner Methods

#### `providePromotionalBannerWidget()`
Creates a promotional banner widget to boost conversions.

**Parameters:**
- `promoParams`: Banner parameters including transaction details and customer info
- `themeId`: Optional theme ID for styling

### Utility Methods

#### `getSdkVersion()`
Returns SDK version information.

#### `getPlatformVersion()`
Returns the current platform version.

## 🔗 Deep Link Configuration

The plugin automatically handles deep link returns from Revolut Pay. Configure your deep link scheme in the platform-specific files:

- **Android**: `revolutbridge://payment-return`
- **iOS**: `revolutbridge://payment-return`

## 📊 Event Handling

The plugin provides real-time event updates through callbacks:

```dart
// Set up event callbacks
sdkBridge.onOrderCompleted = (orderId) {
  print('Payment completed: $orderId');
};

sdkBridge.onOrderFailed = (orderId, error) {
  print('Payment failed: $orderId - $error');
};

sdkBridge.onUserPaymentAbandoned = () {
  print('User abandoned payment');
};
```

## 🧪 Testing

### Sandbox Environment
- Use `environment: 'sandbox'` for testing
- Test with sandbox order tokens
- No real money is processed

### Production Environment
- Use `environment: 'main'` for live payments
- Ensure you have valid production credentials
- Test thoroughly before going live

## 📝 Example Usage

See the `example/` directory for a complete working example that demonstrates:

- SDK initialization
- Payment button creation
- Payment processing
- Event handling
- Error handling

## 🚨 Important Notes

1. **Never expose your secret API key** in client-side code
2. **Always create orders on your server** using the Merchant API
3. **Handle payment results securely** through webhooks
4. **Test thoroughly** in sandbox before going live
5. **Follow Revolut's design guidelines** for buttons and branding

## 🔒 Security

- Merchant public keys are safe to include in client apps
- Secret keys must remain on your server
- Use HTTPS for all API communications
- Validate all payment results on your server

## 📚 Additional Resources

- [Revolut Developer Documentation](https://developer.revolut.com/)
- [Revolut Pay Button Guidelines](https://developer.revolut.com/docs/guides/accept-payments/payment-methods/revolut-pay/button-guidelines)
- [Merchant API Reference](https://developer.revolut.com/docs/merchant-api)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

If you encounter any issues or have questions:

1. Check the [example app](example/) for usage patterns
2. Review the [Revolut documentation](https://developer.revolut.com/)
3. Open an issue on GitHub
4. Contact Revolut support for API-related questions

---

**Note**: This plugin is not officially affiliated with Revolut. It's a community-maintained bridge to the official Revolut Pay SDK.

