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

  /// Callback when button is clicked
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

    // Recreate button if parameters changed
    if (oldWidget.buttonParams != widget.buttonParams) {
      _createButton();
    }

    // Update order token if changed
    if (oldWidget.orderToken != widget.orderToken &&
        widget.orderToken != null) {
      _setOrderToken(widget.orderToken!);
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
    _createButton();
  }

  /// Builds the actual button widget
  Widget _buildButton() {
    return Container(
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      padding: widget.padding,
      decoration: widget.decoration,
      child: GestureDetector(
        onTap: widget.enabled ? _handleButtonPress : null,
        child: AndroidView(
          viewType: _viewType,
          onPlatformViewCreated: _onPlatformViewCreated,
          creationParams: {
            'buttonParams': widget.buttonParams?.toMap(),
            'orderToken': widget.orderToken,
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
      decoration:
          widget.decoration ??
          BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8.0),
          ),
      child: const Center(
        child: SizedBox(
          width: 20.0,
          height: 20.0,
          child: CircularProgressIndicator(strokeWidth: 2.0),
        ),
      ),
    );
  }

  /// Creates the Revolut Pay button through the native platform
  Future<void> _createButton() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _channel.invokeMethod('provideButton', {
        'buttonParams': widget.buttonParams?.toMap(),
      });

      if (result is Map) {
        final buttonCreated = result['success'] as bool? ?? false;
        if (buttonCreated) {
          _buttonId = result['buttonId'] as String?;
          _isButtonCreated = true;

          // Set order token if available
          // if (widget.orderToken != null) {
          //   await _setOrderToken(widget.orderToken!);
          // }
        } else {
          throw Exception('Failed to create button');
        }
      } else {
        throw Exception('Invalid response from native side');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isButtonCreated = false;
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

  /// Handles button press events
  void _handleButtonPress() {
    if (!_isButtonCreated || !widget.enabled) return;

    widget.onPressed?.call();
  }

  /// Callback when the platform view is created
  void _onPlatformViewCreated(int id) {
    // Platform view is ready
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Sets the order token for the button
  Future<void> _setOrderToken(String orderToken) async {
    if (_buttonId == null) return;

    try {
      await _channel.invokeMethod('setOrderToken', {
        'buttonId': _buttonId,
        'orderToken': orderToken,
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to set order token: ${e.toString()}';
        });
        widget.onError?.call(_errorMessage!);
      }
    }
  }
}

class _RevolutPayPromoBannerState extends State<RevolutPayPromoBanner> {
  static const MethodChannel _channel = MethodChannel('revolut_sdk_bridge');

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
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: const Center(
        child: SizedBox(
          width: 20.0,
          height: 20.0,
          child: CircularProgressIndicator(strokeWidth: 2.0),
        ),
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
      final result = await _channel.invokeMethod(
        'providePromotionalBannerWidget',
        {'promoParams': widget.promoParams?.toMap(), 'themeId': widget.themeId},
      );

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
