import 'revolut_sdk_bridge_platform_interface.dart';

export 'revolut_sdk_bridge_method_channel.dart';
export 'revolut_sdk_bridge_platform_interface.dart';
export 'services/revolut_logger.dart';
export 'widgets/revolut_pay_button.dart';

/// Main class for the Revolut SDK Bridge plugin
/// This plugin integrates with the Revolut Pay SDK for iOS
/// and provides a bridge for accepting Revolut Pay payments in Flutter apps
class RevolutSdkBridge {
  /// Create a Revolut Pay button for payment processing
  ///
  /// [orderToken] - The order token obtained from your server after creating an order
  /// [amount] - Payment amount in minor units (e.g., 1000 for £10.00)
  /// [currency] - Payment currency (e.g., 'GBP', 'EUR', 'USD')
  /// [email] - Customer's email address (optional)
  /// [shouldRequestShipping] - Whether to request shipping details via Revolut Pay
  /// [savePaymentMethodForMerchant] - Whether to save payment method for merchant (MIT)
  ///
  /// Returns a Map with button configuration and payment result
  static Future<Map<String, dynamic>?> createRevolutPayButton({
    required String orderToken,
    required int amount,
    required String currency,
    String? email,
    bool? shouldRequestShipping,
    bool? savePaymentMethodForMerchant,
  }) {
    return RevolutSdkBridgePlatform.instance.createRevolutPayButton(
      orderToken: orderToken,
      amount: amount,
      currency: currency,
      email: email,
      shouldRequestShipping: shouldRequestShipping,
      savePaymentMethodForMerchant: savePaymentMethodForMerchant,
    );
  }

  /// Get platform version (for debugging)
  static Future<String?> getPlatformVersion() {
    return RevolutSdkBridgePlatform.instance.getPlatformVersion();
  }

  /// Initialize the Revolut Pay SDK with configuration
  ///
  /// [merchantPublicKey] - Your merchant public API key from Revolut Developer Dashboard
  /// [environment] - 'sandbox' for testing, 'production' for live payments
  static Future<bool> initialize({
    required String merchantPublicKey,
    String? environment,
  }) {
    return RevolutSdkBridgePlatform.instance.initialize(
      merchantPublicKey: merchantPublicKey,
      environment: environment,
    );
  }
}
