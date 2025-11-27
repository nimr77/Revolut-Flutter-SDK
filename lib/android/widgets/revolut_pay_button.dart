import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/revolut_pay_models.dart';

/// A Flutter widget that displays a Revolut Pay button using the native Android SDK
/// This widget creates a platform view that renders the native Revolut Pay button
class RevolutPayButton extends StatefulWidget {
  /// Button parameters for customization
  final ButtonParamsData? buttonParams;

  /// Order token for payment processing
  final String? orderToken;

  /// Payment amount in minor units (e.g., 1000 for £10.00)
  final int? amount;

  /// Payment currency (e.g., 'GBP', 'EUR', 'USD')
  final String? currency;

  /// Customer email address
  final String? email;

  /// Whether to request shipping information
  final bool shouldRequestShipping;

  /// Whether to save payment method for merchant
  final bool savePaymentMethodForMerchant;

  /// Return URL for payment completion
  final String? returnURL;

  /// Merchant name to display
  final String? merchantName;

  /// Merchant logo URL
  final String? merchantLogoURL;

  /// Additional data for the payment
  final Map<String, dynamic>? additionalData;

  /// Callback when button is clicked
  /// Note: The native button handles clicks directly and triggers the payment flow.
  /// To listen for button clicks and payment events, use the RevolutCallbacks system
  /// via RevolutSdkBridge to set up event listeners for onButtonClick, onOrderCompleted, etc.
  final VoidCallback? onPressed;

  /// Callback when payment succeeds
  final Function(Map<String, dynamic> result)? onPaymentSuccess;

  /// Callback when payment fails
  final Function(String error, Map<String, dynamic>? details)? onPaymentError;

  /// Callback when payment is cancelled by user
  final Function()? onPaymentCancelled;

  /// Callback when button creation fails
  final Function(String error)? onError;

  /// Width of the button (optional)
  final double? width;

  /// Height of the button (optional)
  final double? height;

  /// Whether the button is enabled
  final bool enabled;

  /// Custom styling for the button container
  final BoxDecoration? decoration;

  /// Margin around the button
  final EdgeInsetsGeometry? margin;

  /// Padding inside the button
  final EdgeInsetsGeometry? padding;

  const RevolutPayButton({
    super.key,
    this.buttonParams,
    this.orderToken,
    this.amount,
    this.currency,
    this.email,
    this.shouldRequestShipping = false,
    this.savePaymentMethodForMerchant = false,
    this.returnURL,
    this.merchantName,
    this.merchantLogoURL,
    this.additionalData,
    this.onPressed,
    this.onPaymentSuccess,
    this.onPaymentError,
    this.onPaymentCancelled,
    this.onError,
    this.width,
    this.height,
    this.enabled = true,
    this.decoration,
    this.margin,
    this.padding,
  });

  @override
  State<RevolutPayButton> createState() => _RevolutPayButtonState();
}

/// A promotional banner widget for Revolut Pay
class RevolutPayPromoBanner extends StatefulWidget {
  /// Promotional banner parameters
  final PromoBannerParamsData? promoParams;

  /// Theme ID for the banner
  final String? themeId;

  /// Callback when banner is interacted with
  final Function(String bannerId, String interactionType)? onInteraction;

  /// Callback when banner creation fails
  final Function(String error)? onError;

  /// Width of the banner
  final double? width;

  /// Height of the banner
  final double? height;

  const RevolutPayPromoBanner({
    super.key,
    this.promoParams,
    this.themeId,
    this.onInteraction,
    this.onError,
    this.width,
    this.height,
  });

  @override
  State<RevolutPayPromoBanner> createState() => _RevolutPayPromoBannerState();
}

class _RevolutPayButtonState extends State<RevolutPayButton> {
  static const String _viewType = 'revolut_pay_button';
  static const MethodChannel _bridgeChannel = MethodChannel('revolut_sdk_bridge');

  String? _buttonId;
  Map<String, dynamic>? _buttonConfig;
  bool _isButtonCreated = false;
  bool _isLoading = true;
  String? _errorMessage;
  MethodChannel? _paymentChannel;

  @override
  void initState() {
    super.initState();
    _createButton();
  }

  @override
  void didUpdateWidget(RevolutPayButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.orderToken != widget.orderToken ||
        oldWidget.amount != widget.amount ||
        oldWidget.currency != widget.currency ||
        oldWidget.email != widget.email ||
        oldWidget.shouldRequestShipping != widget.shouldRequestShipping ||
        oldWidget.savePaymentMethodForMerchant != widget.savePaymentMethodForMerchant ||
        oldWidget.returnURL != widget.returnURL) {
      _createButton();
    }
  }

  @override
  void dispose() {
    _paymentChannel?.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState();
    }
    if (_errorMessage != null || !_isButtonCreated || _buttonConfig == null) {
      return _buildErrorState();
    }
    return _buildButton();
  }

  Future<void> _createButton() async {
    final orderToken = widget.orderToken;
    final amount = widget.amount;
    final currency = widget.currency;
    final email = widget.email;

    if (orderToken == null || amount == null || currency == null || email == null) {
      const message = 'Missing required button parameters';
      setState(() {
        _isLoading = false;
        _isButtonCreated = false;
        _buttonConfig = null;
        _buttonId = null;
        _errorMessage = message;
      });
      widget.onError?.call(message);
      return;
    }

    _paymentChannel?.setMethodCallHandler(null);
    _paymentChannel = null;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _isButtonCreated = false;
      _buttonConfig = null;
      _buttonId = null;
    });

    try {
      final args = <String, dynamic>{
        'orderToken': orderToken,
        'amount': amount,
        'currency': currency,
        'email': email,
        'shouldRequestShipping': widget.shouldRequestShipping,
        'savePaymentMethodForMerchant': widget.savePaymentMethodForMerchant,
        'returnURL': widget.returnURL ?? 'revolut-sdk-bridge://revolut-pay',
        'merchantName': widget.merchantName,
        'merchantLogoURL': widget.merchantLogoURL,
        'additionalData': widget.additionalData,
      };

      final dynamic result = await _bridgeChannel.invokeMethod('createRevolutPayButton', args);

      if (!mounted) {
        return;
      }

      if (result == null) {
        throw PlatformException(code: 'NULL_RESULT', message: 'Native response was null');
      }

      if (result is! Map) {
        throw PlatformException(
          code: 'INVALID_RESULT',
          message: 'Unexpected native result type: ${result.runtimeType}',
        );
      }

      final config = _normalizeNativeMap(Map<dynamic, dynamic>.from(result));

      if (config['buttonCreated'] != true) {
        final message = config['message'] as String? ?? 'Failed to create Revolut Pay button';
        throw PlatformException(code: 'BUTTON_CREATION_FAILED', message: message);
      }

      setState(() {
        _buttonConfig = config;
        _buttonId = config['viewId']?.toString();
        _isButtonCreated = true;
        _isLoading = false;
        _errorMessage = null;
      });
    } on PlatformException catch (e) {
      final message = e.message ?? e.code;
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = message;
        _isLoading = false;
        _isButtonCreated = false;
        _buttonConfig = null;
        _buttonId = null;
      });
      widget.onError?.call(message);
    } catch (e) {
      final message = e.toString();
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = message;
        _isLoading = false;
        _isButtonCreated = false;
        _buttonConfig = null;
        _buttonId = null;
      });
      widget.onError?.call(message);
    }
  }

  Widget _buildButton() {
    final buttonParamsMap = (widget.buttonParams ?? const ButtonParamsData()).toMap();

    final creationParams = <String, dynamic>{
      ...?_buttonConfig,
      'buttonParams': buttonParamsMap,
      'buttonId': _buttonConfig?['viewId'] ?? _buttonId,
    };

    return Container(
      width: widget.width ?? double.infinity,
      margin: widget.margin,
      padding: widget.padding,
      decoration: widget.decoration,
      child: SizedBox(
        height: widget.height,
        child: AndroidView(
          key: ValueKey('revolut_button_${_buttonId ?? widget.orderToken}_${widget.amount}_${widget.currency}'),
          viewType: _viewType,
          onPlatformViewCreated: _onPlatformViewCreated,
          creationParams: creationParams,
          creationParamsCodec: const StandardMessageCodec(),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      width: widget.width,
      height: widget.height ?? 48.0,
      margin: widget.margin,
      decoration:
          widget.decoration ??
          BoxDecoration(
            color: Colors.red[100],
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: Colors.red),
          ),
      child: Center(
        child: SelectableText.rich(
          TextSpan(
            text: _errorMessage ?? 'Button creation failed',
            style: TextStyle(color: Colors.red[800], fontSize: 12.0),
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      width: widget.width,
      height: widget.height ?? 48.0,
      margin: widget.margin,
      decoration: widget.decoration ?? BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(8.0)),
      child: const Center(
        child: SizedBox(width: 20.0, height: 20.0, child: CircularProgressIndicator(strokeWidth: 2.0)),
      ),
    );
  }

  void _onPlatformViewCreated(int id) {
    _paymentChannel = MethodChannel('revolut_pay_button_payment_$id');
    _paymentChannel!.setMethodCallHandler(_handlePaymentChannelCall);

    if (mounted) {
      setState(() {
        _isButtonCreated = true;
        _isLoading = false;
        _errorMessage = null;
      });
    }
  }

  Future<void> _handlePaymentChannelCall(MethodCall call) async {
    if (!mounted) {
      return;
    }

    switch (call.method) {
      case 'onPaymentResult':
        final args = call.arguments as Map<dynamic, dynamic>?;
        if (args == null) {
          return;
        }

        final resultData = _normalizeNativeMap(args);
        final success = resultData['success'] as bool? ?? false;
        final message = resultData['message'] as String? ?? '';
        final error = resultData['error'] as String? ?? '';

        if (success) {
          widget.onPaymentSuccess?.call(resultData);
          _createButton();
          return;
        }

        final failureMessage = error.isNotEmpty ? error : message;

        if (error == 'user_abandoned_payment' ||
            message.toLowerCase().contains('abandoned') ||
            message.toLowerCase().contains('cancelled')) {
          widget.onPaymentCancelled?.call();
        }

        widget.onError?.call(failureMessage);
        widget.onPaymentError?.call(failureMessage, resultData);

        break;
      default:
        break;
    }
  }

  Map<String, dynamic> _normalizeNativeMap(Map<dynamic, dynamic> source) {
    return source.map((key, value) => MapEntry(key.toString(), value));
  }
}

class _RevolutPayPromoBannerState extends State<RevolutPayPromoBanner> {
  static const MethodChannel _channel = MethodChannel('revolut_sdk_bridge');

  // ignore: unused_field
  String? _bannerId;
  bool _isBannerCreated = false;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null || !_isBannerCreated) {
      return _buildErrorState();
    }

    return _buildBanner();
  }

  @override
  void initState() {
    super.initState();
    _createBanner();
  }

  /// Builds the actual banner widget
  Widget _buildBanner() {
    // For now, return a placeholder since promotional banners
    // would need additional native implementation
    return Container(
      width: widget.width,
      height: widget.height ?? 80.0,
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.blue),
      ),
      child: const Center(
        child: Text(
          'Revolut Pay Promotional Banner',
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  /// Builds the error state widget
  Widget _buildErrorState() {
    return Container(
      width: widget.width,
      height: widget.height ?? 80.0,
      decoration: BoxDecoration(
        color: Colors.orange[100],
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.orange),
      ),
      child: Center(
        child: Text(
          _errorMessage ?? 'Banner creation failed',
          style: TextStyle(color: Colors.orange[800], fontSize: 12.0),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  /// Builds the loading state widget
  Widget _buildLoadingState() {
    return Container(
      width: widget.width,
      height: widget.height ?? 80.0,
      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8.0)),
      child: const Center(
        child: SizedBox(width: 20.0, height: 20.0, child: CircularProgressIndicator(strokeWidth: 2.0)),
      ),
    );
  }

  /// Creates the promotional banner through the native platform
  Future<void> _createBanner() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _channel.invokeMethod('providePromotionalBannerWidget', {
        'promoParams': widget.promoParams?.toMap(),
        'themeId': widget.themeId,
      });

      if (result is Map<String, dynamic>) {
        final bannerCreated = result['bannerCreated'] as bool? ?? false;
        if (bannerCreated) {
          _bannerId = result['bannerId'] as String?;
          _isBannerCreated = true;
        } else {
          throw Exception('Failed to create promotional banner');
        }
      } else {
        throw Exception('Invalid response from native side');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isBannerCreated = false;
        });
        widget.onError?.call(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
