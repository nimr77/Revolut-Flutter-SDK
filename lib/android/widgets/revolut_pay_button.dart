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
  static const MethodChannel _channel = MethodChannel('revolut_sdk_bridge');
  static const String _viewType = 'revolut_pay_button';

  String? _buttonId;
  bool _isButtonCreated = false;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (!_isButtonCreated) {
      return _buildErrorState();
    }

    return _buildButton();
  }

  @override
  void didUpdateWidget(RevolutPayButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If critical parameters changed, rebuild the widget
    // The AndroidView will be recreated automatically
    if (oldWidget.orderToken != widget.orderToken ||
        oldWidget.amount != widget.amount ||
        oldWidget.currency != widget.currency ||
        oldWidget.email != widget.email) {
      // Widget will rebuild and create new platform view
      setState(() {});
    }
  }

  @override
  void dispose() {
    // Clean up any resources if needed
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _isButtonCreated = true;
    _isLoading = false;
  }

  /// Builds the actual button widget
  Widget _buildButton() {
    final buttonParamsMap = (widget.buttonParams ?? const ButtonParamsData()).toMap();

    return Container(
      width: widget.width ?? double.infinity,
      margin: widget.margin,
      padding: widget.padding,
      decoration: widget.decoration,
      child: SizedBox(
        height: widget.height,
        child: AndroidView(
          key: ValueKey('revolut_button_${widget.orderToken}_${widget.amount}_${widget.currency}'),
          viewType: _viewType,
          onPlatformViewCreated: _onPlatformViewCreated,
          creationParams: {
            'buttonParams': buttonParamsMap,
            'orderToken': widget.orderToken,
            'buttonId': _buttonId,
            'amount': widget.amount,
            'currency': widget.currency,
            'email': widget.email,
            'shouldRequestShipping': widget.shouldRequestShipping,
            'savePaymentMethodForMerchant': widget.savePaymentMethodForMerchant,
            'returnURL': widget.returnURL ?? 'myapp://payment-return',
            'merchantName': widget.merchantName,
            'merchantLogoURL': widget.merchantLogoURL,
            'additionalData': widget.additionalData,
          },
          creationParamsCodec: const StandardMessageCodec(),
        ),
      ),
    );
  }

  /// Builds the error state widget
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
        child: Text(
          _errorMessage ?? 'Button creation failed',
          style: TextStyle(color: Colors.red[800], fontSize: 12.0),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  /// Builds the loading state widget
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

  /// Callback when the platform view is created
  void _onPlatformViewCreated(int id) {
    // Platform view is ready, button has been created natively
    if (mounted) {
      setState(() {
        _isButtonCreated = true;
        _isLoading = false;
        _errorMessage = null;
      });
    }
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
