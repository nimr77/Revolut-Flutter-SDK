import 'dart:io';

import 'package:flutter/material.dart';

// Import common models and enums
import 'android/enums/revolut_enums.dart';
import 'android/models/revolut_pay_models.dart';
// Import platform-specific implementations
import 'android/revolut_sdk_bridge.dart' as android;
import 'ios/revolut_sdk_bridge.dart' as ios;

/// Cross-platform Revolut Pay button widget
/// Automatically adapts to the current platform
class CrossPlatformRevolutPayButton extends StatelessWidget {
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

  // Android-specific parameters
  final ButtonParamsData? buttonParams;

  // iOS-specific parameters
  final double? height;
  final double? width;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  // Callbacks
  final VoidCallback? onPressed;
  final Function(String)? onError;
  final Function(Map<String, dynamic>)? onPaymentResult;
  final Function(String)? onPaymentError;
  final VoidCallback? onPaymentCancelled;
  final VoidCallback? onButtonCreated;
  final VoidCallback? onButtonError;

  const CrossPlatformRevolutPayButton({
    super.key,
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
    this.buttonParams,
    this.height,
    this.width,
    this.margin,
    this.padding,
    this.borderRadius,
    this.onPressed,
    this.onError,
    this.onPaymentResult,
    this.onPaymentError,
    this.onPaymentCancelled,
    this.onButtonCreated,
    this.onButtonError,
  });

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      // Use Android implementation
      return android.RevolutPayButton(
        buttonParams: buttonParams,
        orderToken: orderToken,
        onPressed: onPressed,
        onError: onError,
        width: width,
        height: height,
        margin: margin,
        padding: padding,
        decoration: borderRadius != null
            ? BoxDecoration(borderRadius: borderRadius)
            : null,
      );
    } else if (Platform.isIOS) {
      // Use iOS implementation
      return ios.RevolutPayButtonIos(
        config: ios.RevolutPayButtonConfigIos(
          orderToken: orderToken,
          amount: amount,
          currency: currency,
          email: email,
          shouldRequestShipping: shouldRequestShipping,
          savePaymentMethodForMerchant: savePaymentMethodForMerchant,
          returnURL: returnURL,
          merchantName: merchantName,
          merchantLogoURL: merchantLogoURL,
          additionalData: additionalData,
        ),
        style: ios.RevolutPayButtonStyleIos(
          height: height,
          width: width,
          margin: margin,
          padding: padding,
          borderRadius: borderRadius,
        ),
        onPaymentResult: onPaymentResult != null
            ? (result) => onPaymentResult!({
                'success': result.success,
                'message': result.message,
                'error': result.error,
                'timestamp': result.timestamp.toIso8601String(),
              })
            : null,
        onPaymentError: onPaymentError,
        onPaymentCancelled: onPaymentCancelled,
        onButtonCreated: onButtonCreated,
        onButtonError: onButtonError,
        onError: onError,
      );
    } else {
      // Fallback for unsupported platforms
      return Container(
        height: height ?? 50,
        width: width,
        margin: margin,
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            'Revolut Pay Button\n(Platform not supported)',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12),
          ),
        ),
      );
    }
  }
}

/// Cross-platform promotional banner widget (Android only)
class CrossPlatformRevolutPayPromoBanner extends StatelessWidget {
  final PromoBannerParamsData? promoParams;
  final String? themeId;
  final double? width;
  final double? height;
  final Function(String, String)? onInteraction;
  final Function(String)? onError;

  const CrossPlatformRevolutPayPromoBanner({
    super.key,
    this.promoParams,
    this.themeId,
    this.width,
    this.height,
    this.onInteraction,
    this.onError,
  });

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      // Use Android implementation
      return android.RevolutPayPromoBanner(
        promoParams: promoParams,
        themeId: themeId,
        width: width,
        height: height,
        onInteraction: onInteraction != null
            ? (bannerId, interactionType) =>
                  onInteraction!(bannerId, interactionType)
            : null,
        onError: onError,
      );
    } else {
      // iOS doesn't support promotional banners
      return Container(
        width: width,
        height: height ?? 80,
        decoration: BoxDecoration(
          color: Colors.orange[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange),
        ),
        child: const Center(
          child: Text(
            'Promotional Banners\n(Not supported on iOS)',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      );
    }
  }
}

/// Cross-platform simple Revolut Pay button
class CrossPlatformSimpleRevolutPayButton extends StatelessWidget {
  final String orderToken;
  final int amount;
  final String currency;
  final String email;
  final ButtonSize size;
  final ButtonRadius radius;
  final bool showCashback;
  final String? cashbackCurrency;
  final VoidCallback? onPressed;
  final Function(String)? onError;

  const CrossPlatformSimpleRevolutPayButton({
    super.key,
    required this.orderToken,
    required this.amount,
    required this.currency,
    required this.email,
    this.size = ButtonSize.large,
    this.radius = ButtonRadius.medium,
    this.showCashback = false,
    this.cashbackCurrency,
    this.onPressed,
    this.onError,
  });

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      // Use Android implementation
      return android.SimpleRevolutPayButton(
        orderToken: orderToken,
        onPressed: onPressed,
        onError: onError,
        size: size,
        radius: radius,
        showCashback: showCashback,
        cashbackCurrency: cashbackCurrency,
      );
    } else {
      // Use iOS implementation with simplified configuration
      return CrossPlatformRevolutPayButton(
        orderToken: orderToken,
        amount: amount,
        currency: currency,
        email: email,
        onPressed: onPressed,
        onError: onError,
        height: size == ButtonSize.large ? 56.0 : 48.0,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        borderRadius: BorderRadius.circular(
          radius == ButtonRadius.none ? 0 : 8.0,
        ),
      );
    }
  }
}

/// Cross-platform Revolut SDK Bridge
/// Automatically selects the appropriate platform implementation
class RevolutSdkBridge {
  static final RevolutSdkBridge _instance = RevolutSdkBridge._internal();
  factory RevolutSdkBridge() => _instance;
  RevolutSdkBridge._internal();

  /// Check if running on Android
  bool get isAndroid => Platform.isAndroid;

  /// Check if running on iOS
  bool get isIOS => Platform.isIOS;

  /// Clean up all buttons (iOS only)
  Future<bool> cleanupAllButtons() async {
    try {
      if (isAndroid) {
        // Android doesn't have this method
        return true;
      } else if (isIOS) {
        // iOS implementation
        return await ios.RevolutSdkBridgeIos.cleanupAllButtonsIos();
      } else {
        throw UnsupportedError('Platform not supported');
      }
    } catch (e) {
      debugPrint('Failed to cleanup buttons: $e');
      rethrow;
    }
  }

  /// Clean up a specific button (iOS only)
  Future<bool> cleanupButton(int viewId) async {
    try {
      if (isAndroid) {
        // Android doesn't have this method
        return true;
      } else if (isIOS) {
        // iOS implementation
        return await ios.RevolutSdkBridgeIos.cleanupButtonIos(viewId);
      } else {
        throw UnsupportedError('Platform not supported');
      }
    } catch (e) {
      debugPrint('Failed to cleanup button: $e');
      rethrow;
    }
  }

  /// Create a controller for managing confirmation flows (Android only)
  Future<ControllerResultData?> createController() async {
    try {
      if (isAndroid) {
        // Android implementation
        return await android.RevolutSdkBridgeMethodChannel(
          android.RevolutCallbacks(),
        ).createController();
      } else if (isIOS) {
        // iOS doesn't support controllers
        throw UnsupportedError('Controllers not supported on iOS');
      } else {
        throw UnsupportedError('Platform not supported');
      }
    } catch (e) {
      debugPrint('Failed to create controller: $e');
      rethrow;
    }
  }

  /// Create a Revolut Pay button for the current platform
  ///
  /// [orderToken] - Order token for payment processing
  /// [amount] - Payment amount in minor units (e.g., 1000 for £10.00)
  /// [currency] - Payment currency (e.g., 'GBP', 'EUR', 'USD')
  /// [email] - Customer email address
  /// [buttonParams] - Button customization parameters (Android only)
  /// [shouldRequestShipping] - Whether to request shipping information
  /// [savePaymentMethodForMerchant] - Whether to save payment method
  /// [returnURL] - Return URL for payment completion
  /// [merchantName] - Merchant name to display
  /// [merchantLogoURL] - Merchant logo URL
  /// [additionalData] - Additional data for the payment
  Future<Map<String, dynamic>?> createPaymentButton({
    required String orderToken,
    required int amount,
    required String currency,
    required String email,
    ButtonParamsData? buttonParams,
    bool shouldRequestShipping = false,
    bool savePaymentMethodForMerchant = false,
    String? returnURL,
    String? merchantName,
    String? merchantLogoURL,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      if (isAndroid) {
        // Android implementation
        final result = await android.RevolutSdkBridgeMethodChannel(
          android.RevolutCallbacks(),
        ).provideButton(buttonParams: buttonParams?.toMap());

        return {
          'buttonId': result.buttonId,
          'success': result.success,
          'platform': 'android',
        };
      } else if (isIOS) {
        // iOS implementation
        return await ios.RevolutSdkBridgeIos.createRevolutPayButtonIos(
          orderToken: orderToken,
          amount: amount,
          currency: currency,
          email: email,
          shouldRequestShipping: shouldRequestShipping,
          savePaymentMethodForMerchant: savePaymentMethodForMerchant,
          returnURL: returnURL,
          merchantName: merchantName,
          merchantLogoURL: merchantLogoURL,
          additionalData: additionalData,
        );
      } else {
        throw UnsupportedError('Platform not supported');
      }
    } catch (e) {
      debugPrint('Failed to create payment button: $e');
      rethrow;
    }
  }

  /// Create a promotional banner (Android only)
  ///
  /// [promoParams] - Promotional banner parameters
  /// [themeId] - Theme ID for the banner
  Future<BannerResultData?> createPromotionalBanner({
    PromoBannerParamsData? promoParams,
    String? themeId,
  }) async {
    try {
      if (isAndroid) {
        // Android implementation
        return await android.RevolutSdkBridgeMethodChannel(
          android.RevolutCallbacks(),
        ).providePromotionalBannerWidget(
          promoParams: promoParams?.toMap(),
          themeId: themeId,
        );
      } else if (isIOS) {
        // iOS doesn't support promotional banners
        throw UnsupportedError('Promotional banners not supported on iOS');
      } else {
        throw UnsupportedError('Platform not supported');
      }
    } catch (e) {
      debugPrint('Failed to create promotional banner: $e');
      rethrow;
    }
  }

  /// Get the platform version
  Future<String> getPlatformVersion() async {
    try {
      if (isAndroid) {
        // Android implementation
        return await android.RevolutSdkBridgeMethodChannel(
          android.RevolutCallbacks(),
        ).getPlatformVersion();
      } else if (isIOS) {
        // iOS implementation
        final result = await ios.RevolutSdkBridgeIos.getPlatformVersionIos();
        return result ?? 'Unknown';
      } else {
        throw UnsupportedError('Platform not supported');
      }
    } catch (e) {
      debugPrint('Failed to get platform version: $e');
      rethrow;
    }
  }

  /// Get the SDK version (Android only)
  Future<Map<String, dynamic>?> getSdkVersion() async {
    try {
      if (isAndroid) {
        // Android implementation
        return await android.RevolutSdkBridgeMethodChannel(
          android.RevolutCallbacks(),
        ).getSdkVersion();
      } else if (isIOS) {
        // iOS doesn't have SDK version method
        return null;
      } else {
        throw UnsupportedError('Platform not supported');
      }
    } catch (e) {
      debugPrint('Failed to get SDK version: $e');
      rethrow;
    }
  }

  /// Initialize the Revolut SDK for the current platform
  ///
  /// [merchantPublicKey] - Your Revolut merchant public key
  /// [environment] - Environment ('sandbox' or 'main')
  /// [returnUri] - Return URI for payment completion (Android only)
  /// [requestShipping] - Whether to request shipping information (Android only)
  /// [customer] - Customer data (Android only)
  Future<bool> initialize({
    required String merchantPublicKey,
    String? environment,
    String? returnUri,
    bool requestShipping = false,
    CustomerData? customer,
  }) async {
    try {
      if (isAndroid) {
        // Android implementation
        final androidEnv = environment == 'main'
            ? RevolutEnvironment.main
            : RevolutEnvironment.sandbox;

        return await android.RevolutSdkBridgeMethodChannel(
          android.RevolutCallbacks(),
        ).init(
          environment: androidEnv.value,
          returnUri: returnUri ?? 'revolut://payment-return',
          merchantPublicKey: merchantPublicKey,
          requestShipping: requestShipping,
          customer: customer?.toMap(),
        );
      } else if (isIOS) {
        // iOS implementation
        return await ios.RevolutSdkBridgeIos.initializeIos(
          merchantPublicKey: merchantPublicKey,
          environment: environment,
        );
      } else {
        throw UnsupportedError('Platform not supported');
      }
    } catch (e) {
      debugPrint('Failed to initialize Revolut SDK: $e');
      rethrow;
    }
  }

  /// Process a payment with the given order token
  ///
  /// [orderToken] - Order token for payment processing
  /// [savePaymentMethodForMerchant] - Whether to save payment method
  Future<bool> processPayment({
    required String orderToken,
    bool savePaymentMethodForMerchant = false,
  }) async {
    try {
      if (isAndroid) {
        // Android implementation
        return await android.RevolutSdkBridgeMethodChannel(
          android.RevolutCallbacks(),
        ).pay(
          orderToken: orderToken,
          savePaymentMethodForMerchant: savePaymentMethodForMerchant,
        );
      } else if (isIOS) {
        // iOS doesn't have a direct pay method, payment is handled by the button
        throw UnsupportedError(
          'Direct payment processing not supported on iOS. Use the payment button instead.',
        );
      } else {
        throw UnsupportedError('Platform not supported');
      }
    } catch (e) {
      debugPrint('Failed to process payment: $e');
      rethrow;
    }
  }
}
