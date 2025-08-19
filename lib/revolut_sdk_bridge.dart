import 'revolut_sdk_bridge_platform_interface.dart';

/// Main class for the Revolut SDK Bridge plugin
/// This plugin integrates with the Revolut Pay SDK for iOS
/// and provides a bridge for accepting Revolut Pay payments in Flutter apps
class RevolutSdkBridge {
  /// Create a payment (legacy - not applicable for Revolut Pay SDK)
  static Future<Map<String, dynamic>?> createPayment({
    required String accountId,
    required String recipientAccountId,
    required double amount,
    required String currency,
    String? reference,
  }) {
    return RevolutSdkBridgePlatform.instance.createPayment(
      accountId: accountId,
      recipientAccountId: recipientAccountId,
      amount: amount,
      currency: currency,
      reference: reference,
    );
  }

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

  /// Get account details (legacy - not applicable for Revolut Pay SDK)
  static Future<Map<String, dynamic>?> getAccountDetails(String accountId) {
    return RevolutSdkBridgePlatform.instance.getAccountDetails(accountId);
  }

  /// Get account transactions (legacy - not applicable for Revolut Pay SDK)
  static Future<List<Map<String, dynamic>>?> getAccountTransactions(
    String accountId, {
    DateTime? from,
    DateTime? to,
    int? limit,
  }) {
    return RevolutSdkBridgePlatform.instance.getAccountTransactions(
      accountId,
      from: from,
      to: to,
      limit: limit,
    );
  }

  // Legacy methods - kept for backward compatibility but not fully implemented
  // These would need to be implemented differently for Revolut Pay use cases

  /// Get exchange rates (legacy - not applicable for Revolut Pay SDK)
  static Future<Map<String, dynamic>?> getExchangeRates({
    String? fromCurrency,
    String? toCurrency,
  }) {
    return RevolutSdkBridgePlatform.instance.getExchangeRates(
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
    );
  }

  /// Get payment status (legacy - not applicable for Revolut Pay SDK)
  static Future<Map<String, dynamic>?> getPaymentStatus(String paymentId) {
    return RevolutSdkBridgePlatform.instance.getPaymentStatus(paymentId);
  }

  /// Get platform version (for debugging)
  static Future<String?> getPlatformVersion() {
    return RevolutSdkBridgePlatform.instance.getPlatformVersion();
  }

  /// Get user accounts (legacy - not applicable for Revolut Pay SDK)
  static Future<List<Map<String, dynamic>>?> getUserAccounts() {
    return RevolutSdkBridgePlatform.instance.getUserAccounts();
  }

  /// Get user profile information (legacy - not applicable for Revolut Pay SDK)
  static Future<Map<String, dynamic>?> getUserProfile() {
    return RevolutSdkBridgePlatform.instance.getUserProfile();
  }

  /// Handle OAuth callback (legacy - not applicable for Revolut Pay SDK)
  static Future<Map<String, dynamic>?> handleOAuthCallback(String url) {
    return RevolutSdkBridgePlatform.instance.handleOAuthCallback(url);
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
      clientId:
          merchantPublicKey, // Using clientId parameter for backward compatibility
      clientSecret: '', // Not needed for Revolut Pay SDK
      redirectUri: '', // Not needed for Revolut Pay SDK
      environment: environment,
    );
  }

  /// Check if the Revolut Pay SDK is initialized
  static Future<bool> isInitialized() {
    return RevolutSdkBridgePlatform.instance.isInitialized();
  }

  /// Logout and clear session (legacy - not applicable for Revolut Pay SDK)
  static Future<bool> logout() {
    return RevolutSdkBridgePlatform.instance.logout();
  }

  /// Perform currency exchange (legacy - not applicable for Revolut Pay SDK)
  static Future<Map<String, dynamic>?> performExchange({
    required String fromAccountId,
    required String toAccountId,
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) {
    return RevolutSdkBridgePlatform.instance.performExchange(
      fromAccountId: fromAccountId,
      toAccountId: toAccountId,
      amount: amount,
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
    );
  }

  /// Start the OAuth flow (legacy - not applicable for Revolut Pay SDK)
  static Future<String?> startOAuthFlow({List<String>? scopes, String? state}) {
    return RevolutSdkBridgePlatform.instance.startOAuthFlow(
      scopes: scopes,
      state: state,
    );
  }
}
