import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'revolut_sdk_bridge_method_channel.dart';

abstract class RevolutSdkBridgePlatform extends PlatformInterface {
  static final Object _token = Object();

  static RevolutSdkBridgePlatform _instance = MethodChannelRevolutSdkBridge();

  /// The default instance of [RevolutSdkBridgePlatform] to use.
  ///
  /// Defaults to [MethodChannelRevolutSdkBridge].
  static RevolutSdkBridgePlatform get instance => _instance;

  /// Platform-specific implementations can set this with their own platform-specific
  /// class that extends [RevolutSdkBridgePlatform] when they register themselves.
  static set instance(RevolutSdkBridgePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Constructs a RevolutSdkBridgePlatform.
  RevolutSdkBridgePlatform() : super(token: _token);

  /// Clean up all Revolut Pay buttons
  Future<bool> cleanupAllButtonsIos() {
    throw UnimplementedError(
      'cleanupAllButtonsIos() has not been implemented.',
    );
  }

  /// Clean up a specific Revolut Pay button
  Future<bool> cleanupButtonIos(int viewId) {
    throw UnimplementedError('cleanupButtonIos() has not been implemented.');
  }

  /// Continue confirmation flow on a controller
  Future<bool> continueConfirmationFlowIos({required String controllerId}) {
    throw UnimplementedError(
      'continueConfirmationFlowIos() has not been implemented.',
    );
  }

  /// Create a payment controller
  Future<Map<String, dynamic>?> createControllerIos() {
    throw UnimplementedError('createControllerIos() has not been implemented.');
  }

  /// Create a Revolut Pay button for payment processing
  Future<Map<String, dynamic>?> createRevolutPayButtonIos({
    required String orderToken,
    required int amount,
    required String currency,
    required String email,
    bool shouldRequestShipping = false,
    bool savePaymentMethodForMerchant = false,
    String? returnURL,
    String? merchantName,
    String? merchantLogoURL,
    Map<String, dynamic>? additionalData,
  }) {
    throw UnimplementedError(
      'createRevolutPayButtonIos() has not been implemented.',
    );
  }

  /// Dispose a controller
  Future<bool> disposeControllerIos({required String controllerId}) {
    throw UnimplementedError(
      'disposeControllerIos() has not been implemented.',
    );
  }

  /// Get platform version (for debugging)
  Future<String?> getPlatformVersionIos() {
    throw UnimplementedError(
      'getPlatformVersionIos() has not been implemented.',
    );
  }

  /// Get SDK version information
  Future<Map<String, dynamic>?> getSdkVersionIos() {
    throw UnimplementedError('getSdkVersionIos() has not been implemented.');
  }

  /// Initialize the Revolut Pay SDK with configuration
  Future<bool> initializeIos({
    required String merchantPublicKey,
    String? environment,
  }) {
    throw UnimplementedError('initializeIos() has not been implemented.');
  }

  /// Process a payment with the given order token
  Future<Map<String, dynamic>?> payIos({
    required String orderToken,
    bool savePaymentMethodForMerchant = false,
  }) {
    throw UnimplementedError('payIos() has not been implemented.');
  }

  /// Provide promotional banner widget
  Future<Map<String, dynamic>?> providePromotionalBannerWidgetIos({
    required Map<String, dynamic> promoParams,
    String? themeId,
  }) {
    throw UnimplementedError(
      'providePromotionalBannerWidgetIos() has not been implemented.',
    );
  }

  /// Set order token on a controller
  Future<bool> setOrderTokenIos({
    required String orderToken,
    required String controllerId,
  }) {
    throw UnimplementedError('setOrderTokenIos() has not been implemented.');
  }

  /// Set save payment method for merchant on a controller
  Future<bool> setSavePaymentMethodForMerchantIos({
    required bool savePaymentMethodForMerchant,
    required String controllerId,
  }) {
    throw UnimplementedError(
      'setSavePaymentMethodForMerchantIos() has not been implemented.',
    );
  }
}
