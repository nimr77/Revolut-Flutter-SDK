import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'revolut_sdk_bridge_method_channel.dart';

abstract class RevolutSdkBridgePlatform extends PlatformInterface {
  static final Object _token = Object();

  static RevolutSdkBridgePlatform _instance = MethodChannelRevolutSdkBridge();

  /// The default instance of [RevolutSdkBridgePlatform] to use.
  ///
  /// Defaults to [MethodChannelRevolutSdkBridge].
  static RevolutSdkBridgePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [RevolutSdkBridgePlatform] when
  /// they register themselves.
  static set instance(RevolutSdkBridgePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Constructs a RevolutSdkBridgePlatform.
  RevolutSdkBridgePlatform() : super(token: _token);

  /// Create a payment
  Future<Map<String, dynamic>?> createPayment({
    required String accountId,
    required String recipientAccountId,
    required double amount,
    required String currency,
    String? reference,
  }) {
    throw UnimplementedError('createPayment() has not been implemented.');
  }

  /// Create a Revolut Pay button for payment processing
  Future<Map<String, dynamic>?> createRevolutPayButton({
    required String orderToken,
    required int amount,
    required String currency,
    String? email,
    bool? shouldRequestShipping,
    bool? savePaymentMethodForMerchant,
  }) {
    throw UnimplementedError(
      'createRevolutPayButton() has not been implemented.',
    );
  }

  /// Get account details by ID
  Future<Map<String, dynamic>?> getAccountDetails(String accountId) {
    throw UnimplementedError('getAccountDetails() has not been implemented.');
  }

  /// Get account transactions
  Future<List<Map<String, dynamic>>?> getAccountTransactions(
    String accountId, {
    DateTime? from,
    DateTime? to,
    int? limit,
  }) {
    throw UnimplementedError(
      'getAccountTransactions() has not been implemented.',
    );
  }

  /// Get exchange rates
  Future<Map<String, dynamic>?> getExchangeRates({
    String? fromCurrency,
    String? toCurrency,
  }) {
    throw UnimplementedError('getExchangeRates() has not been implemented.');
  }

  /// Get payment status
  Future<Map<String, dynamic>?> getPaymentStatus(String paymentId) {
    throw UnimplementedError('getPaymentStatus() has not been implemented.');
  }

  /// Get platform version (for debugging)
  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  /// Get user accounts
  Future<List<Map<String, dynamic>>?> getUserAccounts() {
    throw UnimplementedError('getUserAccounts() has not been implemented.');
  }

  /// Get user profile information
  Future<Map<String, dynamic>?> getUserProfile() {
    throw UnimplementedError('getUserProfile() has not been implemented.');
  }

  /// Handle OAuth callback
  Future<Map<String, dynamic>?> handleOAuthCallback(String url) {
    throw UnimplementedError('handleOAuthCallback() has not been implemented.');
  }

  /// Initialize the Revolut SDK with configuration
  Future<bool> initialize({
    required String clientId,
    required String clientSecret,
    required String redirectUri,
    String? environment,
  }) {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  /// Check if the Revolut SDK is initialized
  Future<bool> isInitialized() {
    throw UnimplementedError('isInitialized() has not been implemented.');
  }

  /// Logout and clear session
  Future<bool> logout() {
    throw UnimplementedError('logout() has not been implemented.');
  }

  /// Perform currency exchange
  Future<Map<String, dynamic>?> performExchange({
    required String fromAccountId,
    required String toAccountId,
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) {
    throw UnimplementedError('performExchange() has not been implemented.');
  }

  /// Start the OAuth flow for user authentication
  Future<String?> startOAuthFlow({List<String>? scopes, String? state}) {
    throw UnimplementedError('startOAuthFlow() has not been implemented.');
  }
}
