import 'dart:async'; // Added for Timer
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:revolut_sdk_bridge/revolut_sdk_bridge.dart';

/// Configuration for the Revolut Pay button
class RevolutPayButtonConfigIos {
  final String orderToken;
  final int amount;
  final String currency;
  final String email;
  final bool shouldRequestShipping;
  final bool savePaymentMethodForMerchant;
  final String? returnURL;
  final String? merchantName;
  final String? merchantLogoURL;
  final Map<String, dynamic>? additionalData;

  const RevolutPayButtonConfigIos({
    required this.orderToken,
    required this.amount,
    required this.currency,
    required this.email,
    this.shouldRequestShipping = false,
    this.savePaymentMethodForMerchant = false,
    this.returnURL,
    this.merchantName,
    this.merchantLogoURL,
    this.additionalData,
  });

  Map<String, dynamic> toMap() {
    return {
      'orderToken': orderToken,
      'amount': amount,
      'currency': currency,
      'email': email,
      'shouldRequestShipping': shouldRequestShipping,
      'savePaymentMethodForMerchant': savePaymentMethodForMerchant,
      'returnURL': returnURL,
      'merchantName': merchantName,
      'merchantLogoURL': merchantLogoURL,
      'additionalData': additionalData,
    };
  }
}

/// The Revolut Pay button widget
class RevolutPayButtonIos extends StatefulWidget {
  final RevolutPayButtonConfigIos config;
  final RevolutPayButtonStyleIos? style;
  final Widget? loadingWidget;
  final Widget? placeholderWidget;
  final Function(RevolutPaymentResultIos)? onPaymentResult;
  final Function(String)? onPaymentError;
  final VoidCallback? onPaymentCancelled;
  final VoidCallback? onButtonCreated;
  final VoidCallback? onButtonError;
  final Function(String)? onError; // Simple error callback

  const RevolutPayButtonIos({
    super.key,
    required this.config,
    this.style,
    this.loadingWidget,
    this.placeholderWidget,
    this.onPaymentResult,
    this.onPaymentError,
    this.onPaymentCancelled,
    this.onButtonCreated,
    this.onButtonError,
    this.onError,
  });

  @override
  State<RevolutPayButtonIos> createState() => _RevolutPayButtonIosState();
}

/// Style configuration for the Revolut Pay button
class RevolutPayButtonStyleIos {
  final double? height;
  final double? width;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final String? fontFamily;

  const RevolutPayButtonStyleIos({
    this.height,
    this.width,
    this.margin,
    this.padding,
    this.borderRadius,
    this.border,
    this.boxShadow,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
    this.fontWeight,
    this.fontFamily,
  });

  Map<String, dynamic> toMap() {
    return {
      'height': height,
      'width': width,
      'margin': margin?.toString(),
      'padding': padding?.toString(),
      'borderRadius': borderRadius?.toString(),
      'border': border?.toString(),
      'boxShadow': boxShadow?.map((shadow) => shadow.toString()).toList(),
      'backgroundColor': backgroundColor?.value,
      'textColor': textColor?.value,
      'fontSize': fontSize,
      'fontWeight': fontWeight?.index,
      'fontFamily': fontFamily,
    };
  }
}

class _RevolutPayButtonIosState extends State<RevolutPayButtonIos> {
  // Method channel for receiving payment results from native code
  static const MethodChannel _paymentChannel = MethodChannel(
    'revolut_pay_button_payment',
  );
  Map<String, dynamic>? _buttonConfig;
  bool _isLoading = true;
  // int? _buttonId;
  Timer? _paymentTimeout;

  bool _isPaymentInProgress = false;

  @override
  Widget build(BuildContext context) {
    // Show loading state while creating button
    if (_isLoading) {
      return widget.loadingWidget ?? _buildDefaultLoading();
    }

    if (_buttonConfig == null) {
      throw Exception('Button config is null');
    }

    // Show the native Revolut Pay button
    return _buildNativeButton();
  }

  @override
  void dispose() {
    _clearPaymentTimeout();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _createButton();
    _setupPaymentChannel();
  }

  Widget _buildDefaultError() {
    return Container(
      height: widget.style?.height ?? 50,
      width: widget.style?.width,
      margin: widget.style?.margin,
      padding: widget.style?.padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: widget.style?.borderRadius ?? BorderRadius.circular(8),
        border: widget.style?.border ?? Border.all(color: Colors.red[300]!),
        boxShadow: widget.style?.boxShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'Error: ${widget.onError?.call('Failed to load button') ?? 'Failed to load button'}',
              style: TextStyle(
                color: Colors.red[700],
                fontSize: widget.style?.fontSize ?? 14,
                fontWeight: widget.style?.fontWeight ?? FontWeight.w500,
                fontFamily: widget.style?.fontFamily,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultLoading() {
    return Container(
      height: widget.style?.height ?? 50,
      width: widget.style?.width,
      margin: widget.style?.margin,
      padding: widget.style?.padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.style?.backgroundColor ?? Colors.grey[300],
        borderRadius: widget.style?.borderRadius ?? BorderRadius.circular(8),
        border: widget.style?.border,
        boxShadow: widget.style?.boxShadow,
      ),
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              widget.style?.textColor ?? Colors.grey[600]!,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIOSButton() {
    final creationParams = {
      ..._buttonConfig!,
      'buttonId': _buttonConfig!['viewId'],
      'style': widget.style?.toMap(),
    };

    return Container(
      height: widget.style?.height ?? 50,
      width: widget.style?.width,
      margin: widget.style?.margin,
      child: UiKitView(
        viewType: 'revolut_pay_button',
        onPlatformViewCreated: _onPlatformViewCreated,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
      ),
    );
  }

  Widget _buildNativeButton() {
    if (Platform.isIOS) {
      return _buildIOSButton();
    }
    throw Exception('Unsupported platform');
  }

  void _clearPaymentTimeout() {
    _paymentTimeout?.cancel();
    _paymentTimeout = null;
  }

  Future<void> _createButton() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final result = await RevolutSdkBridgeIos.createRevolutPayButtonIos(
        orderToken: widget.config.orderToken,
        amount: widget.config.amount,
        currency: widget.config.currency,
        email: widget.config.email,
        shouldRequestShipping: widget.config.shouldRequestShipping,
        savePaymentMethodForMerchant:
            widget.config.savePaymentMethodForMerchant,
        returnURL: widget.config.returnURL,
        merchantName: widget.config.merchantName,
        merchantLogoURL: widget.config.merchantLogoURL,
        additionalData: widget.config.additionalData,
      );

      if (result != null && result['buttonCreated'] == true) {
        setState(() {
          _buttonConfig = result;
          // _buttonId = result['viewId'];
          _isLoading = false;
        });

        widget.onButtonCreated?.call();
      } else {
        throw Exception(
          'Failed to create button: ${result?['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      widget.onError?.call(e.toString());
      widget.onButtonError?.call();
    }
  }

  void _handlePaymentResult(Map<String, dynamic> resultData) {
    // Clear payment timeout
    _clearPaymentTimeout();

    // Reset payment state
    setState(() {
      _isPaymentInProgress = false;
    });

    // Parse the result
    final success = resultData['success'] as bool? ?? false;
    final message = resultData['message'] as String? ?? '';
    final error = resultData['error'] as String? ?? '';

    if (success) {
      // Payment successful
      final paymentResult = RevolutPaymentResultIos(
        success: true,
        message: message,
        error: '',
        timestamp: DateTime.now(),
      );

      // Call the developer's callback
      widget.onPaymentResult?.call(paymentResult);

      // Recreate button for next payment
      _createButton();
    } else {
      // Payment failed
      widget.onError?.call(error.isNotEmpty ? error : 'Payment failed');
      widget.onPaymentError?.call(error.isNotEmpty ? error : 'Payment failed');
    }
  }

  void _handlePaymentTimeout() {
    widget.onError?.call('Payment timeout - please try again');
  }

  void _onPlatformViewCreated(int id) {
    // Platform view created successfully
  }

  void _setupPaymentChannel() {
    _paymentChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onPaymentResult':
          if (call.arguments != null && call.arguments is Map) {
            final resultData = Map<String, dynamic>.from(call.arguments);
            _handlePaymentResult(resultData);
          }
          break;
        default:
          print('Unknown method call: ${call.method}');
      }
    });
  }

  void _startPayment() {
    if (_isPaymentInProgress) return;

    setState(() {
      _isPaymentInProgress = true;
    });

    // Start payment timeout
    _startPaymentTimeout();
  }

  void _startPaymentTimeout() {
    _clearPaymentTimeout();
    _paymentTimeout = Timer(const Duration(seconds: 30), () {
      if (mounted && _isPaymentInProgress) {
        _handlePaymentTimeout();
      }
    });
  }
}
