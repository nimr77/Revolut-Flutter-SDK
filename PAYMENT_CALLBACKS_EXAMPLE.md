# Payment Callbacks Example

This document shows how to use the payment result callbacks in the Revolut Pay Button widget.

## Overview

The `RevolutPayButton` and `CrossPlatformRevolutPayButton` now support three payment result callbacks:

- `onPaymentSuccess` - Called when payment completes successfully
- `onPaymentError` - Called when payment fails
- `onPaymentCancelled` - Called when user abandons/cancels the payment

## Basic Example

```dart
import 'package:flutter/material.dart';
import 'package:revolut_sdk_bridge/revolut_sdk_bridge.dart';

class PaymentExample extends StatefulWidget {
  const PaymentExample({super.key});

  @override
  State<PaymentExample> createState() => _PaymentExampleState();
}

class _PaymentExampleState extends State<PaymentExample> {
  String _paymentStatus = 'Waiting for payment...';
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Example')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Payment status display
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Status',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(_paymentStatus),
                    if (_isProcessing)
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: LinearProgressIndicator(),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Revolut Pay Button with callbacks
            CrossPlatformRevolutPayButton(
              orderToken: 'your_order_token_here',
              amount: 1000, // £10.00
              currency: 'GBP',
              email: 'customer@example.com',
              returnURL: 'myapp://payment-return',
              
              // Success callback
              onPaymentResult: (result) {
                setState(() {
                  _isProcessing = false;
                  _paymentStatus = '✅ Payment Successful!';
                });
                
                // Show success dialog
                _showPaymentResultDialog(
                  context,
                  'Payment Successful',
                  'Your payment has been processed successfully.',
                  Colors.green,
                );
                
                // Log the full result
                debugPrint('Payment success: $result');
              },
              
              // Error callback
              onPaymentError: (error) {
                setState(() {
                  _isProcessing = false;
                  _paymentStatus = '❌ Payment Failed: $error';
                });
                
                // Show error dialog
                _showPaymentResultDialog(
                  context,
                  'Payment Failed',
                  'Error: $error',
                  Colors.red,
                );
                
                // Log the error
                debugPrint('Payment error: $error');
              },
              
              // Cancellation callback
              onPaymentCancelled: () {
                setState(() {
                  _isProcessing = false;
                  _paymentStatus = '⚠️ Payment Cancelled';
                });
                
                // Show cancellation message
                _showPaymentResultDialog(
                  context,
                  'Payment Cancelled',
                  'You have cancelled the payment.',
                  Colors.orange,
                );
                
                debugPrint('Payment cancelled by user');
              },
              
              // Button creation error callback
              onError: (error) {
                debugPrint('Button error: $error');
                setState(() {
                  _paymentStatus = 'Button creation failed: $error';
                });
              },
              
              height: 50,
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentResultDialog(
    BuildContext context,
    String title,
    String message,
    Color color,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              title.contains('Success') ? Icons.check_circle : 
              title.contains('Failed') ? Icons.error : 
              Icons.warning,
              color: color,
            ),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
```

## Android-Specific Example

If you want to use the Android-specific widget directly:

```dart
import 'package:flutter/material.dart';
import 'package:revolut_sdk_bridge/android/widgets/revolut_pay_button.dart';
import 'package:revolut_sdk_bridge/android/models/revolut_pay_models.dart';

class AndroidPaymentExample extends StatelessWidget {
  const AndroidPaymentExample({super.key});

  @override
  Widget build(BuildContext context) {
    return RevolutPayButton(
      buttonParams: const ButtonParamsData(
        size: 'LARGE',
        radius: 'MEDIUM',
        boxText: 'NONE',
      ),
      orderToken: 'your_order_token_here',
      amount: 1000,
      currency: 'GBP',
      email: 'customer@example.com',
      
      onPaymentSuccess: (result) {
        // Handle successful payment
        final orderToken = result['orderToken'];
        final timestamp = result['timestamp'];
        print('Payment succeeded: $orderToken at $timestamp');
      },
      
      onPaymentError: (error, details) {
        // Handle payment error
        print('Payment failed: $error');
        if (details != null) {
          print('Error details: $details');
        }
      },
      
      onPaymentCancelled: () {
        // Handle payment cancellation
        print('User cancelled the payment');
      },
      
      height: 50,
    );
  }
}
```

## Handling Different Payment States

```dart
class AdvancedPaymentExample extends StatefulWidget {
  const AdvancedPaymentExample({super.key});

  @override
  State<AdvancedPaymentExample> createState() => _AdvancedPaymentExampleState();
}

class _AdvancedPaymentExampleState extends State<AdvancedPaymentExample> {
  PaymentState _state = PaymentState.idle;
  String? _errorMessage;
  Map<String, dynamic>? _paymentResult;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Payment state indicator
        _buildStateIndicator(),
        
        const SizedBox(height: 16),
        
        // Payment button
        CrossPlatformRevolutPayButton(
          orderToken: 'your_order_token',
          amount: 1000,
          currency: 'GBP',
          email: 'customer@example.com',
          
          onPaymentResult: (result) {
            setState(() {
              _state = PaymentState.success;
              _paymentResult = result;
              _errorMessage = null;
            });
            
            // Navigate to success page or update order
            _handleSuccessfulPayment(result);
          },
          
          onPaymentError: (error, details) {
            setState(() {
              _state = PaymentState.error;
              _errorMessage = error;
            });
            
            // Log error for analytics
            _logPaymentError(error, details);
          },
          
          onPaymentCancelled: () {
            setState(() {
              _state = PaymentState.cancelled;
            });
            
            // Analytics: track abandonment
            _trackPaymentAbandonment();
          },
          
          height: 50,
        ),
        
        // Error display
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SelectableText.rich(
              TextSpan(
                text: 'Error: $_errorMessage',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStateIndicator() {
    IconData icon;
    Color color;
    String text;

    switch (_state) {
      case PaymentState.idle:
        icon = Icons.payment;
        color = Colors.blue;
        text = 'Ready to pay';
        break;
      case PaymentState.processing:
        icon = Icons.hourglass_empty;
        color = Colors.orange;
        text = 'Processing...';
        break;
      case PaymentState.success:
        icon = Icons.check_circle;
        color = Colors.green;
        text = 'Payment successful';
        break;
      case PaymentState.error:
        icon = Icons.error;
        color = Colors.red;
        text = 'Payment failed';
        break;
      case PaymentState.cancelled:
        icon = Icons.cancel;
        color = Colors.grey;
        text = 'Payment cancelled';
        break;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(color: color)),
      ],
    );
  }

  void _handleSuccessfulPayment(Map<String, dynamic> result) {
    // Update your backend
    // Navigate to confirmation page
    // Send analytics event
  }

  void _logPaymentError(String error, Map<String, dynamic>? details) {
    // Send to your error tracking service
    debugPrint('Payment error: $error');
    if (details != null) {
      debugPrint('Error details: $details');
    }
  }

  void _trackPaymentAbandonment() {
    // Send analytics event
    debugPrint('Payment abandoned by user');
  }
}

enum PaymentState {
  idle,
  processing,
  success,
  error,
  cancelled,
}
```

## Important Notes

1. **Callback Execution**: All callbacks are executed on the UI thread, so you can safely call `setState()` within them.

2. **Error Handling**: The `onPaymentError` callback receives both an error message and optional error details. Always check the details for additional context.

3. **User Cancellation**: The `onPaymentCancelled` callback is triggered when:
   - User explicitly cancels the payment flow
   - User closes the payment sheet
   - Payment is abandoned (error code: `user_abandoned_payment`)

4. **Success Result**: The `onPaymentSuccess` callback receives a map with:
   - `success`: true
   - `orderToken`: The order token used
   - `timestamp`: Unix timestamp of the payment
   - Other platform-specific data

5. **Thread Safety**: All callbacks are already wrapped in mounted checks, but if you're navigating or showing dialogs, ensure the widget is still mounted.

## Testing

To test different payment outcomes:

1. **Success**: Complete the payment flow normally
2. **Error**: Use an invalid order token or simulate network failure
3. **Cancellation**: Close the payment sheet or press back during payment

## See Also

- [Android Implementation Guide](ANDROID_IMPLEMENTATION_FIX.md)
- [Setup Guide](ANDROID_SETUP_GUIDE.md)
- [Official Revolut Pay Documentation](https://developer.revolut.com/docs/accept-payments/get-started/revolut-pay)

