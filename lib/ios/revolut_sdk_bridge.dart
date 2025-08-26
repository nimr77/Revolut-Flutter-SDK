import 'revolut_sdk_bridge_platform_interface.dart';

export 'revolut_sdk_bridge_method_channel.dart' hide RevolutSdkException;
export 'revolut_sdk_bridge_platform_interface.dart' hide RevolutSdkException;
export 'services/revolut_callbacks.dart';
export 'widgets/revolut_pay_button.dart';

/// Main class for the Revolut SDK Bridge plugin
/// This plugin integrates with the Revolut Pay SDK for iOS
/// and provides a bridge for accepting Revolut Pay payments in Flutter apps
class RevolutSdkBridgeIos {
  /// Clean up all Revolut Pay buttons
  ///
  /// Returns true if cleanup was successful
  static Future<bool> cleanupAllButtonsIos() {
    return RevolutSdkBridgePlatform.instance.cleanupAllButtonsIos();
  }

  /// Clean up a specific Revolut Pay button
  ///
  /// [viewId] - The view ID of the button to clean up
  /// Returns true if cleanup was successful
  static Future<bool> cleanupButtonIos(int viewId) {
    return RevolutSdkBridgePlatform.instance.cleanupButtonIos(viewId);
  }

  /// Create a Revolut Pay button for payment processing
  ///
  /// [orderToken] - The order token obtained from your server after creating an order
  /// [amount] - Payment amount in minor units (e.g., 1000 for £10.00)
  /// [currency] - Payment currency (e.g., 'GBP', 'EUR', 'USD')
  /// [email] - Customer's email address
  /// [shouldRequestShipping] - Whether to request shipping details via Revolut Pay
  /// [savePaymentMethodForMerchant] - Whether to save payment method for merchant (MIT)
  /// [returnURL] - Custom return URL for payment completion
  /// [merchantName] - Name of the merchant (optional)
  /// [merchantLogoURL] - URL to merchant logo (optional)
  /// [additionalData] - Additional data to pass with the payment (optional)
  ///
  /// Returns a Map with button configuration and payment result
  static Future<Map<String, dynamic>?> createRevolutPayButtonIos({
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
    return RevolutSdkBridgePlatform.instance.createRevolutPayButtonIos(
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
  }

  /// Get platform version (for debugging)
  static Future<String?> getPlatformVersionIos() {
    return RevolutSdkBridgePlatform.instance.getPlatformVersionIos();
  }

  /// Initialize the Revolut Pay SDK with configuration
  ///
  /// [merchantPublicKey] - Your merchant public API key from Revolut Developer Dashboard
  /// [environment] - 'sandbox' for testing, 'production' for live payments
  static Future<bool> initializeIos({
    required String merchantPublicKey,
    String? environment,
  }) {
    return RevolutSdkBridgePlatform.instance.initializeIos(
      merchantPublicKey: merchantPublicKey,
      environment: environment,
    );
  }
}
