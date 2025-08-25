# Revolut SDK Bridge for Flutter

A Flutter plugin that provides a bridge to the Revolut Pay iOS SDK, allowing you to integrate Revolut Pay payments into your Flutter applications with full customization capabilities.

## 🚀 Features

- **Native Integration**: Uses the official Revolut Pay iOS SDK
- **Full Customization**: Complete control over button appearance and behavior
- **Cross-Platform**: iOS support with Android placeholder (ready for implementation)
- **Real-Time Logging**: Comprehensive logging from native to Flutter
- **Error Handling**: Robust error handling with custom error states
- **Payment Lifecycle**: Full control over payment creation, completion, and cancellation

## 📱 Supported Platforms

- ✅ **iOS**: Full native integration with Revolut Pay SDK
- 🔄 **Android**: Placeholder implementation (ready for Revolut Android SDK integration)

## 🎨 Revolut Pay Button Customization

The `RevolutPayButton` widget provides full customization options:

### Button Configuration
```dart
RevolutPayButton(
  config: RevolutPayButtonConfig(
    orderToken: 'your_order_token',
    amount: 1000, // Amount in smallest currency unit (e.g., pence for GBP)
    currency: 'GBP',
    email: 'customer@example.com',
    shouldRequestShipping: false,
    savePaymentMethodForMerchant: false,
    returnURL: 'your-app://revolut-pay',
    merchantName: 'Your Merchant Name',
    merchantLogoURL: 'https://your-logo.com/logo.png',
    additionalData: {'custom_field': 'value'},
  ),
  style: RevolutPayButtonStyle(
    height: 56,
    width: double.infinity,
    backgroundColor: Colors.blue,
    textColor: Colors.white,
    borderRadius: BorderRadius.circular(8),
    fontSize: 16,
    fontWeight: FontWeight.w600,
  ),
  loadingWidget: CustomLoadingWidget(),
  errorWidget: CustomErrorWidget(),
  placeholderWidget: CustomPlaceholderWidget(),
  onPaymentResult: (result) {
    print('Payment Result: ${result.success ? "Success" : "Failed"}');
  },
  onPaymentError: (error) {
    print('Payment Error: $error');
  },
  onPaymentCancelled: () {
    print('Payment Cancelled');
  },
  onButtonCreated: () {
    print('Button Created');
  },
  onButtonError: () {
    print('Button Error');
  },
)
```

### Visual Styling

```dart
RevolutPayButtonStyle(
  height: 56,                               // Button height
  width: double.infinity,                   // Button width
  margin: EdgeInsets.symmetric(vertical: 8), // Button margins
  padding: EdgeInsets.all(16),              // Button padding
  borderRadius: BorderRadius.circular(12),   // Corner radius
  border: Border.all(color: Colors.blue),   // Border styling
  backgroundColor: Color(0xFF0000FF),       // Background color
  textColor: Colors.white,                  // Text color
  fontSize: 16,                             // Text size
  fontWeight: FontWeight.w600,              // Text weight
  fontFamily: 'Roboto',                     // Font family
  boxShadow: [                              // Custom shadows
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ],
)
```

### Custom State Widgets

```dart
RevolutPayButton(
  loadingWidget: YourCustomLoadingWidget(),      // Custom loading state
  errorWidget: YourCustomErrorWidget(),          // Custom error state
  placeholderWidget: YourCustomPlaceholderWidget(), // Custom placeholder
  // ... other configuration
)
```

### Complete Example

```dart
RevolutPayButton(
  config: RevolutPayButtonConfig(
    orderToken: 'your_order_token',
    amount: 1000,
    currency: 'GBP',
    email: 'customer@example.com',
  ),
  style: RevolutPayButtonStyle(
    height: 56,
    backgroundColor: Colors.blue,
    borderRadius: BorderRadius.circular(12),
  ),
  loadingWidget: Container(
    height: 56,
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.grey[200],
      borderRadius: BorderRadius.circular(12),
    ),
    child: Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Text('Loading Revolut Pay...'),
        ],
      ),
    ),
  ),
  errorWidget: Container(
    height: 56,
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.red[50],
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.red[300]!),
    ),
    child: Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 20),
          SizedBox(width: 8),
          Text(
            'Failed to load button',
            style: TextStyle(color: Colors.red),
          ),
        ],
      ),
    ),
  ),
  onPaymentResult: (result) {
    print('Payment Result: ${result.success ? "Success" : "Failed"}');
    // Handle payment result
  },
  onPaymentError: (error) {
    print('Payment Error: $error');
    // Handle payment error
  },
  onPaymentCancelled: () {
    print('Payment Cancelled');
    // Handle payment cancellation
  },
  onButtonCreated: () {
    print('Revolut Pay button created successfully!');
    // Handle button creation success
  },
  onButtonError: () {
    print('Failed to create Revolut Pay button');
    // Handle button creation error
  },
)

// Control buttons for error recovery
if (_buttonController.hasError || _buttonController.isLoading) ...[
  Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      ElevatedButton(
        onPressed: _buttonController.retry,
        child: Text('Retry'),
      ),
      ElevatedButton(
        onPressed: _buttonController.reset,
        child: Text('Reset'),
      ),
      ElevatedButton(
        onPressed: _buttonController.refresh,
        child: Text('Refresh'),
      ),
    ],
  ),
]
```

## 🔧 SDK Initialization

Before using the Revolut Pay button, you must initialize the SDK:

```dart
// Initialize the SDK
final bool result = await RevolutSdkBridge.initialize(
  merchantPublicKey: 'your_merchant_public_key',
  environment: 'sandbox', // or 'production'
);

if (result) {
  print('SDK initialized successfully');
} else {
  print('SDK initialization failed');
}
```

## 📊 Logging and Monitoring

The plugin provides comprehensive logging from the native platform plugins to Flutter:

```dart
// Initialize the callback service
RevolutCallbacks.initialize();

// Listen to SDK logs
RevolutCallbacks.onLog = (logEntry) {
  print('SDK Log: $logEntry');
  // logEntry.level: info, success, warning, error
  // logEntry.message: log message
  // logEntry.timestamp: when the log occurred
  // logEntry.source: where the log came from
};

// Listen to payment results
RevolutCallbacks.onPaymentResult = (paymentResult) {
  print('Payment Result: $paymentResult');
  // paymentResult.success: whether payment succeeded
  // paymentResult.message: success/error message
  // paymentResult.error: error details if failed
  // paymentResult.timestamp: when the result occurred
};
```

## 🏗️ Architecture

### Flutter Layer
- **`RevolutPayButton`**: Main widget with full customization
- **`RevolutPayButtonConfig`**: Button configuration parameters
- **`RevolutPayButtonStyle`**: Visual styling options
- **`RevolutCallbacks`**: Callback service for platform communication

### Platform Interface
- **`RevolutSdkBridgePlatform`**: Abstract platform interface
- **`MethodChannelRevolutSdkBridge`**: Platform implementations (iOS/Android)
- **`RevolutSdkBridge`**: Main Flutter API

### Native Platform Layer
- **iOS**: `RevolutSdkBridgePlugin.swift` - Full native integration
- **Android**: `RevolutSdkBridgePlugin.kt` - Placeholder for future implementation

## 📁 Project Structure

```
revolut_sdk_bridge/
├── lib/
│   ├── widgets/
│   │   └── revolut_pay_button.dart          # Main button widget
│   ├── services/
│   │   └── revolut_callbacks.dart           # Callback service for platform communication
│   ├── revolut_sdk_bridge.dart              # Main API
│   ├── revolut_sdk_bridge_method_channel.dart # Platform implementations
│   └── revolut_sdk_bridge_platform_interface.dart # Platform interface
├── ios/
│   └── Classes/
│       └── RevolutSdkBridgePlugin.swift     # iOS native plugin
├── android/
│   └── src/main/kotlin/
│       └── RevolutSdkBridgePlugin.kt        # Android native plugin (placeholder)
└── example/
    └── lib/
        └── main.dart                        # Example usage
```

## 🚀 Getting Started

### 1. Add Dependency

```yaml
dependencies:
  revolut_sdk_bridge:
    path: ../revolut_sdk_bridge
```

### 2. Initialize SDK

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Revolut SDK
  await RevolutSdkBridge.initialize(
    merchantPublicKey: 'your_merchant_key',
    environment: 'sandbox',
  );
  
  runApp(MyApp());
}
```

### 3. Add Button to UI

```dart
RevolutPayButton(
  config: RevolutPayButtonConfig(
    orderToken: 'your_order_token',
    amount: 1000,
    currency: 'GBP',
    email: 'customer@example.com',
  ),
  style: RevolutPayButtonStyle(
    height: 56,
    backgroundColor: Colors.blue,
    borderRadius: BorderRadius.circular(12),
  ),
  onPaymentResult: (result) {
    // Handle payment result
  },
)
```

## 🔍 Troubleshooting

### Common Issues

1. **Button not appearing**: Check if SDK is initialized and merchant key is valid
2. **Payment not working**: Verify order token is valid and from your server
3. **Styling not applied**: Ensure style parameters are correctly set
4. **Build errors**: Make sure iOS deployment target is set correctly

### Debug Logs

Enable logging to see what's happening:

```dart
RevolutCallbacks.initialize();
RevolutCallbacks.onLog = (logEntry) {
  print('Revolut SDK Log: $logEntry');
};
```

## 📚 API Reference

### RevolutSdkBridge

Main class for the Revolut SDK Bridge plugin.

**Methods:**
- `initialize(merchantPublicKey, environment)`: Initialize the SDK
- `createRevolutPayButton(config)`: Create a Revolut Pay button
- `cleanupButton(viewId)`: Clean up a specific button
- `cleanupAllButtons()`: Clean up all buttons
- `getPlatformVersion()`: Get platform version

**Example:**
```dart
// Initialize SDK
await RevolutSdkBridge.initialize(
  merchantPublicKey: 'your_key',
  environment: 'sandbox',
);

// Create button
final result = await RevolutSdkBridge.createRevolutPayButton(/* config */);

// Clean up specific button
await RevolutSdkBridge.cleanupButton(result['viewId']);

// Clean up all buttons
await RevolutSdkBridge.cleanupAllButtons();
```

### RevolutPayButton

The main widget for displaying Revolut Pay buttons.

**Properties:**
- `config`: Button configuration parameters
- `style`: Visual styling options
- `loadingWidget`: Custom loading widget
- `errorWidget`: Custom error widget
- `placeholderWidget`: Custom placeholder widget
- `onPaymentResult`: Payment result callback
- `onPaymentError`: Payment error callback
- `onPaymentCancelled`: Payment cancellation callback
- `onButtonCreated`: Button creation callback
- `onButtonError`: Button error callback

**Example:**
```dart
RevolutPayButton(
  config: RevolutPayButtonConfig(/* ... */),
  style: RevolutPayButtonStyle(/* ... */),
  onPaymentResult: (result) {
    print('Payment: ${result.success}');
  },
)
```

### RevolutPayButtonConfig

Configuration for the Revolut Pay button.

**Required Properties:**
- `orderToken`: Order token from your server
- `amount`: Payment amount in minor units
- `currency`: Payment currency code
- `email`: Customer email address

**Optional Properties:**
- `shouldRequestShipping`: Request shipping details
- `savePaymentMethodForMerchant`: Save payment method
- `returnURL`: Custom return URL
- `merchantName`: Merchant name
- `merchantLogoURL`: Merchant logo URL
- `additionalData`: Custom data

### RevolutPayButtonStyle

Visual styling for the button.

**Properties:**
- `height`: Button height
- `width`: Button width
- `margin`: Button margins
- `padding`: Button padding
- `borderRadius`: Corner radius
- `border`: Border styling
- `backgroundColor`: Background color
- `textColor`: Text color
- `fontSize`: Text size
- `fontWeight`: Text weight
- `fontFamily`: Font family
- `boxShadow`: Custom shadows

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For issues and questions:
1. Check the troubleshooting section
2. Review the example app
3. Open an issue on GitHub
4. Check Revolut Pay documentation

## 🔗 Links

- [Revolut Pay Developer Documentation](https://developer.revolut.com/docs/guides/accept-payments/payment-methods/revolut-pay)
- [Flutter Documentation](https://flutter.dev/docs)
- [iOS Platform Views](https://flutter.dev/docs/development/platform-integration/platform-views)

---

**Note**: This plugin requires the Revolut Pay iOS SDK to be properly configured in your iOS project. Make sure you have the necessary dependencies and configurations set up according to the Revolut Pay documentation.

