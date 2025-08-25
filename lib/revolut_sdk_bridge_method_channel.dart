import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'revolut_sdk_bridge_platform_interface.dart';

/// An implementation of [RevolutSdkBridgePlatform] that uses method channels.
class MethodChannelRevolutSdkBridge extends RevolutSdkBridgePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('revolut_sdk_bridge');

  @override
  Future<Map<String, dynamic>?> createRevolutPayButton({
    required String orderToken,
    required int amount,
    required String currency,
    String? email,
    bool? shouldRequestShipping,
    bool? savePaymentMethodForMerchant,
  }) async {
    try {
      final dynamic result = await methodChannel
          .invokeMethod('createRevolutPayButton', {
            'orderToken': orderToken,
            'amount': amount,
            'currency': currency,
            'email': email,
            'shouldRequestShipping': shouldRequestShipping,
            'savePaymentMethodForMerchant': savePaymentMethodForMerchant,
          });

      // Convert the result to the expected type
      if (result is Map) {
        return Map<String, dynamic>.from(result);
      }
      return null;
    } on PlatformException catch (e) {
      throw RevolutSdkException(
        code: e.code,
        message: e.message ?? 'Unknown error occurred',
        details: e.details,
      );
    }
  }

  @override
  Future<String?> getPlatformVersion() async {
    try {
      final dynamic version = await methodChannel.invokeMethod(
        'getPlatformVersion',
      );

      // Convert the result to the expected type
      if (version is String) {
        return version;
      }
      return null;
    } on PlatformException catch (e) {
      throw RevolutSdkException(
        code: e.code,
        message: e.message ?? 'Unknown error occurred',
        details: e.details,
      );
    }
  }

  @override
  Future<bool> initialize({
    required String merchantPublicKey,
    String? environment,
  }) async {
    try {
      final dynamic result = await methodChannel.invokeMethod('initialize', {
        'merchantPublicKey': merchantPublicKey,
        'environment': environment,
      });

      // Convert the result to the expected type
      if (result is bool) {
        return result;
      }
      return false;
    } on PlatformException catch (e) {
      throw RevolutSdkException(
        code: e.code,
        message: e.message ?? 'Unknown error occurred',
        details: e.details,
      );
    }
  }
}

/// Exception class for Revolut SDK errors
class RevolutSdkException implements Exception {
  final String code;
  final String message;
  final dynamic details;

  RevolutSdkException({
    required this.code,
    required this.message,
    this.details,
  });

  @override
  String toString() => 'RevolutSdkException($code, $message, $details)';
}
