# Revolut Pay SDK Bridge

A Flutter plugin that provides a bridge to the native Revolut Pay SDK for iOS, allowing you to accept Revolut Pay payments in your Flutter applications.

## 🎯 **What This Plugin Does**

This plugin integrates with the [official Revolut Pay iOS SDK](https://developer.revolut.com/docs/guides/accept-payments/payment-methods/revolut-pay/mobile/ios) to provide a seamless Revolut Pay experience in your Flutter apps. It handles the creation of Revolut Pay buttons and processes payments through the native iOS interface.

## ✨ **Features**

- 🎯 **Revolut Pay Integration** - Uses Revolut's official Pay SDK for iOS
- 🔐 **Secure Payment Processing** - Handles authentication and payment flows
- 📱 **Native iOS Experience** - Provides the most seamless user experience
- 🏪 **Merchant-Focused** - Designed for businesses accepting Revolut Pay
- 🔄 **Webhook Support** - Track payment lifecycle through server notifications
- 🧪 **Sandbox Testing** - Test with Revolut's test environment
- 💳 **Fast Checkout** - Optional shipping details collection
- 🔄 **Payment Method Saving** - Support for merchant-initiated transactions (MIT)

## 🚀 **Quick Start**

### 1. **Add the dependency**

```yaml
dependencies:
  revolut_sdk_bridge: ^1.0.0
```

### 2. **Install dependencies**

```bash
flutter pub get
```

### 3. **Platform-specific setup**

#### iOS Setup

1. **Add Revolut SDK source** to your `ios/Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/revolut/revolut-payments-ios.git'
```

2. **Install pods**:

```bash
cd ios
pod install
```

3. **Ensure minimum iOS version** is 13.0 or higher

4. **Add URL scheme** to your `ios/Runner/Info.plist`:

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>revolut</string>
</array>
```

### 4. **Use in your Flutter code**

```dart
import 'package:revolut_sdk_bridge/revolut_sdk_bridge.dart';

// Initialize the SDK
await RevolutSdkBridge.initialize(
  merchantPublicKey: 'your_merchant_public_key',
  environment: 'sandbox', // or 'production'
);

// Create a Revolut Pay button
final result = await RevolutSdkBridge.createRevolutPayButton(
  orderToken: 'order_token_from_server',
  amount: 1000, // Amount in minor units (e.g., 1000 for £10.00)
  currency: 'GBP',
  email: 'customer@example.com',
);

if (result['success'] == true) {
  print('Revolut Pay button created successfully!');
} else {
  print('Failed to create button: ${result['error']}');
}
```

## 📋 **Prerequisites**

Before using this plugin, you need:

1. **Revolut Merchant Account** - Apply at [developer.revolut.com](https://developer.revolut.com/)
2. **Merchant Public Key** - Generate from your Developer Dashboard
3. **Backend Server** - To create orders using the Merchant API
4. **iOS 13.0+** - Minimum supported iOS version

## 🔧 **Complete Implementation**

### **Step 1: Server-Side Order Creation**

First, create an order on your server using the Revolut Merchant API:

```bash
POST https://sandbox-merchant.revolut.com/api/1.0/orders
Authorization: Bearer YOUR_API_KEY
Content-Type: application/json

{
  "amount": 1000,
  "currency": "GBP",
  "merchant_order_ext_ref": "order_123"
}
```

### **Step 2: Client-Side Revolut Pay Button**

Use the order token to create a Revolut Pay button in your Flutter app:

```dart
final result = await RevolutSdkBridge.createRevolutPayButton(
  orderToken: 'order_token_from_server',
  amount: 1000, // Amount in minor units
  currency: 'GBP',
  email: 'customer@example.com',
  shouldRequestShipping: true, // Optional: collect shipping details
  savePaymentMethodForMerchant: false, // Optional: save for subscriptions
);
```

### **Step 3: Handle Results**

```dart
if (result['success'] == true) {
  // Button created successfully
  print('Revolut Pay button ready for display');
  
  // In a real app, you would display the actual button here
  // The button configuration is returned in the result
} else {
  // Handle error
  print('Failed to create button: ${result['error']}');
}
```

## 📱 **Platform Support**

| Platform | Support | Notes |
|----------|---------|-------|
| **iOS** | ✅ Full Support | Native Revolut Pay SDK integration |
| **Android** | ⚠️ Limited | Basic structure, needs Android SDK integration |

## 🔑 **Configuration Options**

### **Environment**
- `sandbox` - Development and testing environment
- `production` - Live production environment

### **Payment Features**
- `shouldRequestShipping` - Collect shipping details via Revolut Pay
- `savePaymentMethodForMerchant` - Save payment method for subscriptions/MIT

### **Amount Format**
Amounts should be provided in **minor units**:
- £10.00 = `1000`
- €25.50 = `2550`
- $99.99 = `9999`

## 🧪 **Testing**

### **Test Cards**
Use these test cards in sandbox environment:

- **Success**: `4000 0000 0000 0002`
- **Failure**: `4000 0000 0000 0009`
- **3D Secure**: `4000 0000 0000 0002`

### **Sandbox Environment**
```dart
await RevolutSdkBridge.initialize(
  merchantPublicKey: 'your_sandbox_key',
  environment: 'sandbox',
);
```

## 🔄 **Webhook Integration**

Set up webhooks in your Revolut Developer Dashboard to receive real-time payment notifications:

- Payment completed
- Payment failed
- Order status changes
- 3D Secure authentication results

## 📚 **API Reference**

### **Methods**

#### `initialize(merchantPublicKey, environment)`
Initializes the Revolut Pay SDK.

#### `createRevolutPayButton(orderToken, amount, currency, email?, shouldRequestShipping?, savePaymentMethodForMerchant?)`
Creates a Revolut Pay button for payment processing.

#### `isInitialized()`
Checks if the SDK is properly initialized.

#### `getPlatformVersion()`
Returns the current platform version.

### **Response Format**

```dart
{
  'success': true,
  'status': 'completed',
  'message': 'Revolut Pay button created successfully',
  'orderToken': 'order_token',
  'amount': 1000,
  'currency': 'GBP',
  'email': 'customer@example.com',
  'shouldRequestShipping': false,
  'savePaymentMethodForMerchant': false
}
```

## 🐛 **Troubleshooting**

### **Common Issues**

1. **SDK not initialized**
   - Ensure `initialize()` is called before `createRevolutPayButton()`
   - Check that your merchant public key is valid

2. **Pod install fails**
   - Ensure iOS platform version is 13.0+
   - Check that the Revolut source is added to Podfile

3. **Button not showing**
   - Verify the order token is valid
   - Check that the order was created in the same environment

4. **Build errors**
   - Run `flutter clean` and rebuild
   - Ensure all dependencies are properly installed

### **Error Codes**

- `NOT_INITIALIZED` - SDK not initialized
- `INVALID_ARGUMENTS` - Missing or invalid parameters
- `INITIALIZATION_ERROR` - SDK initialization failed

## 🔒 **Security Considerations**

1. **Never expose API keys** in client-side code
2. **Use HTTPS** for all API communications
3. **Validate order tokens** on your server
4. **Implement webhook verification** for payment confirmations
5. **Use sandbox environment** for development and testing

## 📖 **Additional Resources**

- [Revolut Developer Documentation](https://developer.revolut.com/)
- [Merchant API Reference](https://developer.revolut.com/docs/merchant-api)
- [Revolut Pay iOS SDK Documentation](https://developer.revolut.com/docs/guides/accept-payments/payment-methods/revolut-pay/mobile/ios)
- [Webhook Setup Guide](https://developer.revolut.com/docs/merchant-api/webhooks)
- [Test Cards and Testing Guide](https://developer.revolut.com/docs/merchant-api/testing)

## 🤝 **Contributing**

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 **License**

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 **Support**

For support and questions:

- Create an issue on GitHub
- Check the [Revolut Developer Documentation](https://developer.revolut.com/)
- Review the example app code
- Check the troubleshooting section above

## 🔄 **Changelog**

### **1.0.0**
- Initial release
- Revolut Pay SDK integration (v3.0.0+)
- iOS native payment button support
- Merchant-focused payment processing
- Sandbox and production environment support
- Webhook integration support
- Fast checkout and MIT support

---

**Happy coding! 🚀**

For the latest updates and support, check the project's GitHub repository and the [official Revolut documentation](https://developer.revolut.com/).

