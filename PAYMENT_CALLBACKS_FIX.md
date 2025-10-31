# Payment Callbacks Fix

## Issue

Payment result callbacks (`onPaymentSuccess`, `onPaymentError`, `onPaymentCancelled`) were not being triggered in the Flutter widget when the native Android code sent payment results.

## Root Cause

The issue was a missing communication bridge between the native Android code and the Flutter widget:

1. **Native Side (Kotlin)**: The `RevolutSdkBridgePlugin.kt` was correctly sending payment results via a dedicated method channel (`revolut_pay_button_payment_$viewId`)

2. **Flutter Side (Dart)**: The `RevolutPayButton` widget was **not listening** to this channel, so payment results were lost

## Solution

### 1. Added Payment Callbacks to Flutter Widget

Updated `/lib/android/widgets/revolut_pay_button.dart` to include three new callback parameters:

```dart
/// Callback when payment succeeds
final Function(Map<String, dynamic> result)? onPaymentSuccess;

/// Callback when payment fails
final Function(String error, Map<String, dynamic>? details)? onPaymentError;

/// Callback when payment is cancelled by user
final Function()? onPaymentCancelled;
```

### 2. Set Up Method Channel Handler

Added a method channel handler in the widget state to listen for payment results from native code:

```dart
void _onPlatformViewCreated(int id) {
  // Set up payment channel for this specific button instance
  _paymentChannel = MethodChannel('revolut_pay_button_payment_$id');
  _paymentChannel!.setMethodCallHandler(_handlePaymentChannelCall);
  
  // ... rest of initialization
}
```

### 3. Implemented Payment Result Handler

Created a handler method to process payment results and trigger the appropriate callback:

```dart
Future<void> _handlePaymentChannelCall(MethodCall call) async {
  if (!mounted) return;

  switch (call.method) {
    case 'onPaymentResult':
      final args = call.arguments as Map<dynamic, dynamic>?;
      if (args == null) return;

      final success = args['success'] as bool? ?? false;
      final message = args['message'] as String? ?? '';
      final error = args['error'] as String? ?? '';
      final resultData = Map<String, dynamic>.from(args);

      if (success) {
        widget.onPaymentSuccess?.call(resultData);
      } else {
        // Check if it was cancelled by user
        if (error == 'user_abandoned_payment' || 
            message.toLowerCase().contains('abandoned') ||
            message.toLowerCase().contains('cancelled')) {
          widget.onPaymentCancelled?.call();
        } else {
          widget.onPaymentError?.call(error.isNotEmpty ? error : message, resultData);
        }
      }
      break;

    default:
      break;
  }
}
```

### 4. Updated Cross-Platform Wrapper

Modified `/lib/revolut_sdk_bridge_cross_platform.dart` to pass callbacks through to the Android widget:

```dart
return android.RevolutPayButton(
  // ... other parameters
  onPaymentSuccess: onPaymentResult,
  onPaymentError: (error, details) => onPaymentError?.call(error),
  onPaymentCancelled: onPaymentCancelled,
  // ... rest
);
```

### 5. Added Proper Cleanup

Ensured the method channel handler is properly disposed when the widget is removed:

```dart
@override
void dispose() {
  _paymentChannel?.setMethodCallHandler(null);
  super.dispose();
}
```

## Files Changed

1. `/lib/android/widgets/revolut_pay_button.dart` - Added callbacks and channel handler
2. `/lib/revolut_sdk_bridge_cross_platform.dart` - Updated to pass callbacks through
3. `/android/build.gradle` - Removed incorrect Flutter embedding dependency (unrelated fix)

## How It Works Now

### Payment Success Flow

1. User completes payment in native Revolut Pay UI
2. Native code receives `PaymentResult.Success`
3. Native code calls `sendPaymentResult(true, "Payment completed successfully", null, ...)`
4. This invokes `paymentChannel.invokeMethod("onPaymentResult", resultData)`
5. Flutter widget's `_handlePaymentChannelCall` receives the result
6. `onPaymentSuccess` callback is triggered with result data
7. App can update UI, navigate to success page, etc.

### Payment Error Flow

1. Payment fails in native Revolut Pay UI
2. Native code receives `PaymentResult.Failure`
3. Native code calls `sendPaymentResult(false, "Payment failed", error, ...)`
4. Flutter widget receives the error
5. `onPaymentError` callback is triggered with error message and details

### Payment Cancellation Flow

1. User closes/abandons payment
2. Native code receives `PaymentResult.UserAbandonedPayment`
3. Native code sends result with error `"user_abandoned_payment"`
4. Flutter widget detects cancellation pattern
5. `onPaymentCancelled` callback is triggered

## Testing

To verify the fix works:

```dart
CrossPlatformRevolutPayButton(
  orderToken: 'your_token',
  amount: 1000,
  currency: 'GBP',
  email: 'test@example.com',
  
  onPaymentResult: (result) {
    print('✅ SUCCESS: $result');
  },
  
  onPaymentError: (error) {
    print('❌ ERROR: $error');
  },
  
  onPaymentCancelled: () {
    print('⚠️ CANCELLED');
  },
)
```

## Benefits

1. **Complete Callback Support**: All payment states now properly communicated to Flutter
2. **Type Safety**: Callbacks have proper type signatures
3. **Error Details**: Error callback provides both message and details map
4. **User Cancellation Detection**: Automatically detects when user abandons payment
5. **Clean Architecture**: Each button instance has its own dedicated channel
6. **Memory Safety**: Proper disposal prevents memory leaks

## Migration Guide

If you were using the old widget without callbacks, you can continue using it as-is. The callbacks are optional.

To add callback support:

```dart
// Before
RevolutPayButton(
  orderToken: token,
  amount: amount,
  // ...
)

// After
RevolutPayButton(
  orderToken: token,
  amount: amount,
  onPaymentSuccess: (result) {
    // Handle success
  },
  onPaymentError: (error, details) {
    // Handle error
  },
  onPaymentCancelled: () {
    // Handle cancellation
  },
  // ...
)
```

## See Also

- [Payment Callbacks Example](PAYMENT_CALLBACKS_EXAMPLE.md) - Detailed usage examples
- [Android Implementation Guide](ANDROID_IMPLEMENTATION_FIX.md)
- [Revolut SDK Bridge Plugin](android/src/main/kotlin/com/example/revolut_sdk_bridge/RevolutSdkBridgePlugin.kt)

