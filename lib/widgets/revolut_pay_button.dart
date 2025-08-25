import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A Flutter widget that displays the native Revolut Pay button
class RevolutPayButton extends StatefulWidget {
  /// The order token required for payment processing
  final String orderToken;

  /// The payment amount in minor units (e.g., 1000 for £10.00)
  final int amount;

  /// The currency code (e.g., 'GBP', 'EUR', 'USD')
  final String currency;

  /// Customer email address
  final String? email;

  /// Whether to request shipping information
  final bool shouldRequestShipping;

  /// Whether to save payment method for merchant
  final bool savePaymentMethodForMerchant;

  /// Callback when payment is completed
  final Function(Map<String, dynamic> result)? onPaymentResult;

  /// Callback when payment fails
  final Function(String error)? onPaymentError;

  /// Callback when payment is cancelled
  final VoidCallback? onPaymentCancelled;

  const RevolutPayButton({
    super.key,
    required this.orderToken,
    required this.amount,
    required this.currency,
    this.email,
    this.shouldRequestShipping = false,
    this.savePaymentMethodForMerchant = false,
    this.onPaymentResult,
    this.onPaymentError,
    this.onPaymentCancelled,
  });

  @override
  State<RevolutPayButton> createState() => _RevolutPayButtonState();
}

class _RevolutPayButtonState extends State<RevolutPayButton> {
  static const MethodChannel _channel = MethodChannel('revolut_sdk_bridge');
  Map<String, dynamic>? _buttonConfig;
  bool _isLoading = true;
  String? _error;

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.red[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            'Error: $_error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    if (_buttonConfig == null) {
      return Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(child: Text('No button configuration')),
      );
    }

    // Display the native button using platform view
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return _buildIOSButton();
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return _buildAndroidButton();
    } else {
      return _buildFallbackButton();
    }
  }

  @override
  void initState() {
    super.initState();
    _createNativeButton();
  }

  Widget _buildAndroidButton() {
    // Use AndroidView to display the native Revolut Pay button
    // Pass the button ID so the platform view can find the correct button
    final creationParams = {
      ..._buttonConfig!,
      'buttonId':
          _buttonConfig!['viewId'], // Add the button ID for platform view lookup
    };

    return SizedBox(
      height: 50,
      child: AndroidView(
        viewType: 'revolut_pay_button',
        onPlatformViewCreated: _onPlatformViewCreated,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
      ),
    );
  }

  Widget _buildFallbackButton() {
    // Fallback for unsupported platforms
    return ElevatedButton(
      onPressed: _handleButtonPress,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0000FF),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Text('Pay with Revolut'),
    );
  }

  Widget _buildIOSButton() {
    // Use UiKitView to display the native Revolut Pay button
    // Pass the button ID so the platform view can find the correct button
    final creationParams = {
      ..._buttonConfig!,
      'buttonId':
          _buttonConfig!['viewId'], // Add the button ID for platform view lookup
    };

    return SizedBox(
      height: 50,
      child: UiKitView(
        viewType: 'revolut_pay_button',
        onPlatformViewCreated: _onPlatformViewCreated,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
      ),
    );
  }

  Future<void> _createNativeButton() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final result = await _channel.invokeMethod('createRevolutPayButton', {
        'orderToken': widget.orderToken,
        'amount': widget.amount,
        'currency': widget.currency,
        'email': widget.email,
        'shouldRequestShipping': widget.shouldRequestShipping,
        'savePaymentMethodForMerchant': widget.savePaymentMethodForMerchant,
      });

      if (result != null && result is Map) {
        final resultMap = Map<String, dynamic>.from(result);

        if (resultMap['buttonCreated'] == true) {
          setState(() {
            _buttonConfig = resultMap;
            _isLoading = false;
          });
        } else {
          setState(() {
            _error =
                resultMap['error']?.toString() ??
                'Failed to create payment button';
            _isLoading = false;
          });
          widget.onPaymentError?.call(_error!);
        }
      } else {
        setState(() {
          _error = 'Failed to create payment button';
          _isLoading = false;
        });
        widget.onPaymentError?.call(_error!);
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
      widget.onPaymentError?.call(_error!);
    }
  }

  void _handleButtonPress() async {
    // This is only used for fallback platforms
    try {
      final result = await _channel.invokeMethod('createRevolutPayButton', {
        'orderToken': widget.orderToken,
        'amount': widget.amount,
        'currency': widget.currency,
        'email': widget.email,
        'shouldRequestShipping': widget.shouldRequestShipping,
        'savePaymentMethodForMerchant': widget.savePaymentMethodForMerchant,
      });

      if (result != null && result is Map) {
        final resultMap = Map<String, dynamic>.from(result);

        if (resultMap['buttonCreated'] == true) {
          // Button was created successfully, now we need to handle the actual payment flow
          // This is where we'd integrate with the native payment flow
          widget.onPaymentResult?.call(resultMap);
        } else {
          widget.onPaymentError?.call(
            resultMap['error']?.toString() ?? 'Failed to create payment button',
          );
        }
      } else {
        widget.onPaymentError?.call('Failed to create payment button');
      }
    } catch (e) {
      widget.onPaymentError?.call('Error: $e');
    }
  }

  void _onPlatformViewCreated(int id) {
    // Platform view created successfully
    // The native button is now displayed
  }
}
