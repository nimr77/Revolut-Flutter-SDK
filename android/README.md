# Revolut Pay SDK Bridge - Android Implementation

This directory contains the Android implementation of the Revolut Pay SDK bridge for Flutter. The implementation provides a complete integration with the Revolut Pay Android SDK, following the official documentation and best practices.

## Overview

The Android implementation consists of several key components:

- **RevolutSdkBridgePlugin.kt** - Main plugin class that handles method calls from Flutter
- **RevolutPayModels.kt** - Data models and enums for SDK integration
- **RevolutPayCallbackHandler.kt** - Manages all SDK callbacks and Flutter communication
- **RevolutPayErrorHandler.kt** - Comprehensive error handling and logging
- **Platform Views** - Custom views for Revolut Pay buttons and promotional banners

## Features

### ✅ Complete SDK Integration
- Full implementation of all Revolut Pay SDK methods
- Support for both MAIN and SANDBOX environments
- Proper lifecycle management
- Activity-aware implementation

### ✅ Method Channel Communication
- `init` - Initialize the SDK with environment and credentials
- `pay` - Programmatically initiate payment flow
- `provideButton` - Create Revolut Pay buttons
- `providePromotionalBannerWidget` - Create promotional banners
- `createController` - Manage payment confirmation flows
- `setOrderToken` - Set order token for payment
- `setSavePaymentMethodForMerchant` - Configure payment method saving
- `continueConfirmationFlow` - Continue payment confirmation
- `disposeController` - Clean up controllers
- `getSdkVersion` - Get SDK version information

### ✅ Data Models
- Customer information (name, email, phone, date of birth, country)
- Button parameters (radius, size, box text, variants)
- Promotional banner parameters
- Comprehensive validation utilities

### ✅ Error Handling
- Standardized error codes and messages
- Detailed error reporting to Flutter
- Comprehensive logging system
- Debug mode support

### ✅ Callback Management
- Order completion callbacks
- Payment failure handling
- User abandonment detection
- Controller state management
- Lifecycle event tracking

## Architecture

```
Flutter App
    ↓
Method Channel
    ↓
RevolutSdkBridgePlugin
    ↓
├── RevolutPay SDK
├── Callback Handler
├── Error Handler
└── Platform Views
```

## Dependencies

The implementation requires the following dependencies in `build.gradle`:

```gradle
dependencies {
    // Revolut Pay SDK dependencies
    implementation 'com.revolut:revolut-pay-sdk:2.0.0'
    implementation 'com.revolut:revolut-pay-ui:2.0.0'
    
    // Android lifecycle dependencies
    implementation 'androidx.lifecycle:lifecycle-runtime-ktx:2.7.0'
    implementation 'androidx.lifecycle:lifecycle-common-java8:2.7.0'
}
```

## Setup Requirements

### 1. Repository Configuration
Add the Revolut SDK repository to your `build.gradle`:

```gradle
repositories {
    google()
    mavenCentral()
    maven { url "https://maven.revolut.com/releases" }
}
```

### 2. Permissions
Ensure your app has the necessary permissions in `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

### 3. Activity Configuration
The plugin requires an Activity context for proper operation. Ensure your Flutter app has a proper Activity setup.

## Usage Examples

### Initialization
```kotlin
// Initialize the SDK
RevolutPay.init(
    environment = RevolutPayEnvironment.SANDBOX,
    returnUri = "myapp://payment-return",
    merchantPublicKey = "your_merchant_public_key",
    requestShipping = false,
    customer = customerData
)
```

### Payment Flow
```kotlin
// Create a controller for payment flow
val controller = RevolutPay.createController(
    clickHandler = { confirmationFlow ->
        // Handle confirmation flow creation
    },
    callback = orderResultCallback
)

// Set order token and continue
confirmationFlow.setOrderToken("order_token_123")
confirmationFlow.setSavePaymentMethodForMerchant(true)
confirmationFlow.continueConfirmationFlow()
```

### Button Creation
```kotlin
// Create button with custom parameters
val buttonParams = ButtonParams.Builder()
    .radius(ButtonParams.Radius.MEDIUM)
    .size(ButtonParams.Size.LARGE)
    .boxText(ButtonParams.BoxText.GET_CASHBACK_VALUE)
    .build()

val button = RevolutPay.provideButton(context, buttonParams)
```

## Error Handling

The implementation provides comprehensive error handling:

```kotlin
// Error codes
ERROR_INITIALIZATION
ERROR_PAYMENT
ERROR_BUTTON_CREATION
ERROR_BANNER_CREATION
ERROR_CONTROLLER
ERROR_VALIDATION
ERROR_NETWORK
ERROR_PERMISSION
ERROR_UNEXPECTED
ERROR_SDK_NOT_READY
ERROR_ACTIVITY_NOT_AVAILABLE
ERROR_INVALID_ARGUMENTS
ERROR_CONTROLLER_NOT_FOUND
ERROR_ORDER_TOKEN
ERROR_SAVE_PAYMENT_METHOD
ERROR_CONFIRMATION_FLOW
```

## Callback Events

The plugin sends various events to Flutter:

- `onOrderCompleted` - Payment completed successfully
- `onOrderFailed` - Payment failed with error details
- `onUserPaymentAbandoned` - User abandoned the payment
- `onConfirmationFlowCreated` - New confirmation flow created
- `onControllerStateChange` - Controller state changes
- `onPaymentStatusUpdate` - Payment status updates
- `onButtonClick` - Button click events
- `onBannerInteraction` - Banner interaction events
- `onLifecycleEvent` - Activity lifecycle events
- `onError` - Error events with detailed information

## Data Validation

The implementation includes comprehensive data validation:

- Customer data validation (email format, phone format, date ranges)
- Button parameters validation
- SDK initialization data validation
- Currency code validation
- Country code validation

## Platform Views

### Revolut Pay Button
- Customizable appearance (radius, size, variants)
- Support for cashback text display
- Theme-aware rendering
- Click event handling

### Promotional Banner
- Customizable promotional content
- Theme support
- Interaction tracking

## Testing

The implementation includes comprehensive test coverage:

- Unit tests for all methods
- Error handling tests
- Data validation tests
- Mock SDK integration tests

## Debug Mode

Enable debug logging by setting `enableDebugLogging = true` in the error handler:

```kotlin
val errorHandler = RevolutPayErrorHandler(channel, enableDebugLogging = true)
```

## Performance Considerations

- Controllers are managed in a map for efficient lookup
- Proper lifecycle management prevents memory leaks
- Error handling is optimized for minimal overhead
- Callback events are batched when possible

## Security

- Merchant public keys are validated
- Customer data is sanitized before use
- Error messages don't expose sensitive information
- Proper permission handling

## Troubleshooting

### Common Issues

1. **SDK Not Initialized**
   - Ensure `init` is called before other methods
   - Check that all required parameters are provided

2. **Activity Not Available**
   - Ensure the plugin is attached to an Activity
   - Check Activity lifecycle state

3. **Controller Not Found**
   - Verify controller ID is correct
   - Check if controller was properly created

4. **Network Errors**
   - Verify internet connectivity
   - Check API endpoint accessibility

### Debug Information

Enable debug logging to get detailed information about:
- Method calls and parameters
- SDK responses
- Error details
- Lifecycle events

## Contributing

When contributing to the Android implementation:

1. Follow Kotlin coding standards
2. Add comprehensive error handling
3. Include proper logging
4. Add unit tests for new functionality
5. Update documentation
6. Follow the existing architecture patterns

## License

This implementation follows the same license as the main project.

## Support

For issues related to:
- **Revolut Pay SDK**: Refer to [official documentation](https://developer.revolut.com/docs/sdks/merchant-android-sdk/revolut-pay-android-sdk/introduction)
- **Flutter Plugin**: Check the main project documentation
- **Android Implementation**: Review this README and source code
