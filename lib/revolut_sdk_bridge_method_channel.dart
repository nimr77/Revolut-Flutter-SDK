import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'revolut_sdk_bridge_platform_interface.dart';

/// An implementation of [RevolutSdkBridgePlatform] that uses method channels.
class MethodChannelRevolutSdkBridge extends RevolutSdkBridgePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('revolut_sdk_bridge');

  @override
  Future<Map<String, dynamic>?> createPayment({
    required String accountId,
    required String recipientAccountId,
    required double amount,
    required String currency,
    String? reference,
  }) async {
    final result = await methodChannel
        .invokeMethod<Map<String, dynamic>>('createPayment', {
          'accountId': accountId,
          'recipientAccountId': recipientAccountId,
          'amount': amount,
          'currency': currency,
          'reference': reference,
        });
    return result;
  }

  @override
  Future<Map<String, dynamic>?> createRevolutPayButton({
    required String orderToken,
    required int amount,
    required String currency,
    String? email,
    bool? shouldRequestShipping,
    bool? savePaymentMethodForMerchant,
  }) async {
    final result = await methodChannel
        .invokeMethod<Map<String, dynamic>>('createRevolutPayButton', {
          'orderToken': orderToken,
          'amount': amount,
          'currency': currency,
          'email': email,
          'shouldRequestShipping': shouldRequestShipping,
          'savePaymentMethodForMerchant': savePaymentMethodForMerchant,
        });
    return result;
  }

  @override
  Future<Map<String, dynamic>?> getAccountDetails(String accountId) async {
    final result = await methodChannel.invokeMethod<Map<String, dynamic>>(
      'getAccountDetails',
      {'accountId': accountId},
    );
    return result;
  }

  @override
  Future<List<Map<String, dynamic>>?> getAccountTransactions(
    String accountId, {
    DateTime? from,
    DateTime? to,
    int? limit,
  }) async {
    final result = await methodChannel
        .invokeMethod<List<dynamic>>('getAccountTransactions', {
          'accountId': accountId,
          'from': from?.toIso8601String(),
          'to': to?.toIso8601String(),
          'limit': limit,
        });
    return result?.cast<Map<String, dynamic>>();
  }

  @override
  Future<Map<String, dynamic>?> getExchangeRates({
    String? fromCurrency,
    String? toCurrency,
  }) async {
    final result = await methodChannel.invokeMethod<Map<String, dynamic>>(
      'getExchangeRates',
      {'fromCurrency': fromCurrency, 'toCurrency': toCurrency},
    );
    return result;
  }

  @override
  Future<Map<String, dynamic>?> getPaymentStatus(String paymentId) async {
    final result = await methodChannel.invokeMethod<Map<String, dynamic>>(
      'getPaymentStatus',
      {'paymentId': paymentId},
    );
    return result;
  }

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }

  @override
  Future<List<Map<String, dynamic>>?> getUserAccounts() async {
    final result = await methodChannel.invokeMethod<List<dynamic>>(
      'getUserAccounts',
    );
    return result?.cast<Map<String, dynamic>>();
  }

  @override
  Future<Map<String, dynamic>?> getUserProfile() async {
    final result = await methodChannel.invokeMethod<Map<String, dynamic>>(
      'getUserProfile',
    );
    return result;
  }

  @override
  Future<Map<String, dynamic>?> handleOAuthCallback(String url) async {
    final result = await methodChannel.invokeMethod<Map<String, dynamic>>(
      'handleOAuthCallback',
      {'url': url},
    );
    return result;
  }

  @override
  Future<bool> initialize({
    required String clientId,
    required String clientSecret,
    required String redirectUri,
    String? environment,
  }) async {
    final result = await methodChannel.invokeMethod<bool>('initialize', {
      'clientId': clientId,
      'clientSecret': clientSecret,
      'redirectUri': redirectUri,
      'environment': environment,
    });
    return result ?? false;
  }

  @override
  Future<bool> isInitialized() async {
    final result = await methodChannel.invokeMethod<bool>('isInitialized');
    return result ?? false;
  }

  @override
  Future<bool> logout() async {
    final result = await methodChannel.invokeMethod<bool>('logout');
    return result ?? false;
  }

  @override
  Future<Map<String, dynamic>?> performExchange({
    required String fromAccountId,
    required String toAccountId,
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) async {
    final result = await methodChannel
        .invokeMethod<Map<String, dynamic>>('performExchange', {
          'fromAccountId': fromAccountId,
          'toAccountId': toAccountId,
          'amount': amount,
          'fromCurrency': fromCurrency,
          'toCurrency': toCurrency,
        });
    return result;
  }

  @override
  Future<String?> startOAuthFlow({List<String>? scopes, String? state}) async {
    final result = await methodChannel.invokeMethod<String>('startOAuthFlow', {
      'scopes': scopes,
      'state': state,
    });
    return result;
  }
}
