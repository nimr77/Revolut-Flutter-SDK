import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'revolut_sdk_bridge_platform_interface.dart';

/// An implementation of [RevolutSdkBridgePlatform] that uses method channels.
class MethodChannelRevolutSdkBridge extends RevolutSdkBridgePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('revolut_sdk_bridge');

  /// Clean up all Revolut Pay buttons
  @override
  Future<bool> cleanupAllButtonsIos() async {
    final dynamic result = await methodChannel.invokeMethod(
      'cleanupAllButtons',
      {},
    );
    return result is bool ? result : false;
  }

  /// Clean up a specific Revolut Pay button
  @override
  Future<bool> cleanupButtonIos(int viewId) async {
    final dynamic result = await methodChannel.invokeMethod('cleanupButton', {
      'viewId': viewId,
    });
    return result is bool ? result : false;
  }

  /// Continue confirmation flow on a controller
  @override
  Future<bool> continueConfirmationFlowIos({
    required String controllerId,
  }) async {
    try {
      final dynamic result = await methodChannel.invokeMethod(
        'continueConfirmationFlow',
        {'controllerId': controllerId},
      );
      return result is bool ? result : false;
    } on PlatformException catch (e) {
      throw RevolutSdkException(
        code: e.code,
        message: e.message ?? 'Unknown error occurred',
        details: e.details,
      );
    }
  }

  /// Create a payment controller
  @override
  Future<Map<String, dynamic>?> createControllerIos() async {
    try {
      final dynamic result = await methodChannel.invokeMethod(
        'createController',
        {},
      );
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
  }) async {
    final dynamic result = await methodChannel
        .invokeMethod('createRevolutPayButton', {
          'orderToken': orderToken,
          'amount': amount,
          'currency': currency,
          'email': email,
          'shouldRequestShipping': shouldRequestShipping,
          'savePaymentMethodForMerchant': savePaymentMethodForMerchant,
          'returnURL': returnURL,
          'merchantName': merchantName,
          'merchantLogoURL': merchantLogoURL,
          'additionalData': additionalData,
        });
    if (result is Map) {
      return Map<String, dynamic>.from(result);
    }
    return null;
  }

  /// Dispose a controller
  @override
  Future<bool> disposeControllerIos({required String controllerId}) async {
    try {
      final dynamic result = await methodChannel.invokeMethod(
        'disposeController',
        {'controllerId': controllerId},
      );
      return result is bool ? result : false;
    } on PlatformException catch (e) {
      throw RevolutSdkException(
        code: e.code,
        message: e.message ?? 'Unknown error occurred',
        details: e.details,
      );
    }
  }

  @override
  Future<String?> getPlatformVersionIos() async {
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

  /// Get SDK version information
  @override
  Future<Map<String, dynamic>?> getSdkVersionIos() async {
    try {
      final dynamic result = await methodChannel.invokeMethod(
        'getSdkVersion',
        {},
      );
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
  Future<bool> initializeIos({
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

  /// Process a payment with the given order token
  @override
  Future<Map<String, dynamic>?> payIos({
    required String orderToken,
    bool savePaymentMethodForMerchant = false,
  }) async {
    try {
      final dynamic result = await methodChannel.invokeMethod('pay', {
        'orderToken': orderToken,
        'savePaymentMethodForMerchant': savePaymentMethodForMerchant,
      });
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

  /// Provide promotional banner widget
  @override
  Future<Map<String, dynamic>?> providePromotionalBannerWidgetIos({
    required Map<String, dynamic> promoParams,
    String? themeId,
  }) async {
    try {
      final dynamic result = await methodChannel.invokeMethod(
        'providePromotionalBannerWidget',
        {'promoParams': promoParams, 'themeId': themeId},
      );
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

  /// Set order token on a controller
  @override
  Future<bool> setOrderTokenIos({
    required String orderToken,
    required String controllerId,
  }) async {
    try {
      final dynamic result = await methodChannel.invokeMethod('setOrderToken', {
        'orderToken': orderToken,
        'controllerId': controllerId,
      });
      return result is bool ? result : false;
    } on PlatformException catch (e) {
      throw RevolutSdkException(
        code: e.code,
        message: e.message ?? 'Unknown error occurred',
        details: e.details,
      );
    }
  }

  /// Set save payment method for merchant on a controller
  @override
  Future<bool> setSavePaymentMethodForMerchantIos({
    required bool savePaymentMethodForMerchant,
    required String controllerId,
  }) async {
    try {
      final dynamic result = await methodChannel
          .invokeMethod('setSavePaymentMethodForMerchant', {
            'savePaymentMethodForMerchant': savePaymentMethodForMerchant,
            'controllerId': controllerId,
          });
      return result is bool ? result : false;
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
