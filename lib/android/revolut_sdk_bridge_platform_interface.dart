import 'package:flutter/services.dart';

import 'enums/revolut_enums.dart';
import 'models/revolut_pay_models.dart';

/// Android implementation of the Revolut SDK Bridge platform interface
class AndroidRevolutSdkBridge implements RevolutSdkBridgePlatformInterface {
  static const MethodChannel _channel = MethodChannel('revolut_sdk_bridge');

  @override
  Future<bool> continueConfirmationFlow({required String controllerId}) async {
    try {
      final result = await _channel.invokeMethod('continueConfirmationFlow', {
        'controllerId': controllerId,
      });

      if (result is bool) {
        return result;
      } else if (result is Map<String, dynamic>) {
        return result['success'] as bool? ?? false;
      }
      return false;
    } on PlatformException catch (e) {
      throw RevolutSdkException(
        code: e.code,
        message: e.message ?? 'Unknown error continuing confirmation flow',
        details: e.details,
      );
    } catch (e) {
      throw RevolutSdkException(
        code: 'UNKNOWN_ERROR',
        message: 'Unknown error continuing confirmation flow: ${e.toString()}',
      );
    }
  }

  @override
  Future<ControllerResultData> createController() async {
    try {
      final result = await _channel.invokeMethod('createController');

      if (result is Map<String, dynamic>) {
        return ControllerResultData.fromMap(result);
      }
      throw RevolutSdkException(
        code: 'INVALID_RESPONSE',
        message: 'Invalid response from native side',
      );
    } on PlatformException catch (e) {
      throw RevolutSdkException(
        code: e.code,
        message: e.message ?? 'Unknown error creating controller',
        details: e.details,
      );
    } catch (e) {
      throw RevolutSdkException(
        code: 'UNKNOWN_ERROR',
        message: 'Unknown error creating controller: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> disposeController({required String controllerId}) async {
    try {
      final result = await _channel.invokeMethod('disposeController', {
        'controllerId': controllerId,
      });

      if (result is bool) {
        return result;
      } else if (result is Map<String, dynamic>) {
        return result['success'] as bool? ?? false;
      }
      return false;
    } on PlatformException catch (e) {
      throw RevolutSdkException(
        code: e.code,
        message: e.message ?? 'Unknown error disposing controller',
        details: e.details,
      );
    } catch (e) {
      throw RevolutSdkException(
        code: 'UNKNOWN_ERROR',
        message: 'Unknown error disposing controller: ${e.toString()}',
      );
    }
  }

  @override
  Future<String> getPlatformVersion() async {
    try {
      final result = await _channel.invokeMethod('getPlatformVersion');

      if (result is String) {
        return result;
      }
      throw RevolutSdkException(
        code: 'INVALID_RESPONSE',
        message: 'Invalid response from native side',
      );
    } on PlatformException catch (e) {
      throw RevolutSdkException(
        code: e.code,
        message: e.message ?? 'Unknown error getting platform version',
        details: e.details,
      );
    } catch (e) {
      throw RevolutSdkException(
        code: 'UNKNOWN_ERROR',
        message: 'Unknown error getting platform version: ${e.toString()}',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getSdkVersion() async {
    try {
      final result = await _channel.invokeMethod('getSdkVersion');

      if (result is Map<String, dynamic>) {
        return result;
      }
      throw RevolutSdkException(
        code: 'INVALID_RESPONSE',
        message: 'Invalid response from native side',
      );
    } on PlatformException catch (e) {
      throw RevolutSdkException(
        code: e.code,
        message: e.message ?? 'Unknown error getting SDK version',
        details: e.details,
      );
    } catch (e) {
      throw RevolutSdkException(
        code: 'UNKNOWN_ERROR',
        message: 'Unknown error getting SDK version: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> init({
    required RevolutEnvironment environment,
    required String returnUri,
    required String merchantPublicKey,
    bool requestShipping = false,
    CustomerData? customer,
  }) async {
    try {
      final result = await _channel.invokeMethod('init', {
        'environment': environment.value,
        'returnUri': returnUri,
        'merchantPublicKey': merchantPublicKey,
        'requestShipping': requestShipping,
        'customer': customer?.toMap(),
      });

      if (result is bool) {
        return result;
      } else if (result is Map<String, dynamic>) {
        return result['success'] as bool? ?? false;
      }
      return false;
    } on PlatformException catch (e) {
      throw RevolutSdkException(
        code: e.code,
        message: e.message ?? 'Unknown error during initialization',
        details: e.details,
      );
    } catch (e) {
      throw RevolutSdkException(
        code: 'UNKNOWN_ERROR',
        message: 'Unknown error during initialization: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> pay({
    required String orderToken,
    bool savePaymentMethodForMerchant = false,
  }) async {
    try {
      final result = await _channel.invokeMethod('pay', {
        'orderToken': orderToken,
        'savePaymentMethodForMerchant': savePaymentMethodForMerchant,
      });

      if (result is bool) {
        return result;
      } else if (result is Map<String, dynamic>) {
        return result['success'] as bool? ?? false;
      }
      return false;
    } on PlatformException catch (e) {
      throw RevolutSdkException(
        code: e.code,
        message: e.message ?? 'Unknown error during payment',
        details: e.details,
      );
    } catch (e) {
      throw RevolutSdkException(
        code: 'UNKNOWN_ERROR',
        message: 'Unknown error during payment: ${e.toString()}',
      );
    }
  }

  @override
  Future<ButtonResultData> provideButton({
    ButtonParamsData? buttonParams,
  }) async {
    try {
      final result = await _channel.invokeMethod('provideButton', {
        'buttonParams': buttonParams?.toMap(),
      });

      if (result is Map<String, dynamic>) {
        return ButtonResultData.fromMap(result);
      }
      throw RevolutSdkException(
        code: 'INVALID_RESPONSE',
        message: 'Invalid response from native side',
      );
    } on PlatformException catch (e) {
      throw RevolutSdkException(
        code: e.code,
        message: e.message ?? 'Unknown error creating button',
        details: e.details,
      );
    } catch (e) {
      throw RevolutSdkException(
        code: 'UNKNOWN_ERROR',
        message: 'Unknown error creating button: ${e.toString()}',
      );
    }
  }

  @override
  Future<BannerResultData> providePromotionalBannerWidget({
    PromoBannerParamsData? promoParams,
    String? themeId,
  }) async {
    try {
      final result = await _channel.invokeMethod(
        'providePromotionalBannerWidget',
        {'promoParams': promoParams?.toMap(), 'themeId': themeId},
      );

      if (result is Map<String, dynamic>) {
        return BannerResultData.fromMap(result);
      }
      throw RevolutSdkException(
        code: 'INVALID_RESPONSE',
        message: 'Invalid response from native side',
      );
    } on PlatformException catch (e) {
      throw RevolutSdkException(
        code: e.code,
        message: e.message ?? 'Unknown error creating banner',
        details: e.details,
      );
    } catch (e) {
      throw RevolutSdkException(
        code: 'UNKNOWN_ERROR',
        message: 'Unknown error creating banner: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> setOrderToken({
    required String orderToken,
    required String controllerId,
  }) async {
    try {
      final result = await _channel.invokeMethod('setOrderToken', {
        'orderToken': orderToken,
        'controllerId': controllerId,
      });

      if (result is bool) {
        return result;
      } else if (result is Map<String, dynamic>) {
        return result['success'] as bool? ?? false;
      }
      return false;
    } on PlatformException catch (e) {
      throw RevolutSdkException(
        code: e.code,
        message: e.message ?? 'Unknown error setting order token',
        details: e.details,
      );
    } catch (e) {
      throw RevolutSdkException(
        code: 'UNKNOWN_ERROR',
        message: 'Unknown error setting order token: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> setSavePaymentMethodForMerchant({
    required bool savePaymentMethodForMerchant,
    required String controllerId,
  }) async {
    try {
      final result = await _channel
          .invokeMethod('setSavePaymentMethodForMerchant', {
            'savePaymentMethodForMerchant': savePaymentMethodForMerchant,
            'controllerId': controllerId,
          });

      if (result is bool) {
        return result;
      } else if (result is Map<String, dynamic>) {
        return result['success'] as bool? ?? false;
      }
      return false;
    } on PlatformException catch (e) {
      throw RevolutSdkException(
        code: e.code,
        message: e.message ?? 'Unknown error setting save payment method',
        details: e.details,
      );
    } catch (e) {
      throw RevolutSdkException(
        code: 'UNKNOWN_ERROR',
        message: 'Unknown error setting save payment method: ${e.toString()}',
      );
    }
  }
}

/// Platform interface for Revolut SDK Bridge
/// This interface defines the contract that Android implementations must follow
abstract class RevolutSdkBridgePlatformInterface {
  /// Creates a new instance of the platform interface
  static RevolutSdkBridgePlatformInterface get instance {
    return RevolutSdkBridgePlatformInterface.instance;
  }

  /// Sets the platform interface instance
  static set instance(RevolutSdkBridgePlatformInterface instance) {
    RevolutSdkBridgePlatformInterface.instance = instance;
  }

  /// Continues the confirmation flow
  Future<bool> continueConfirmationFlow({required String controllerId});

  /// Creates a controller for managing confirmation flows
  Future<ControllerResultData> createController();

  /// Disposes a controller
  Future<bool> disposeController({required String controllerId});

  /// Gets the platform version
  Future<String> getPlatformVersion();

  /// Gets the SDK version
  Future<Map<String, dynamic>> getSdkVersion();

  /// Initializes the Revolut Pay SDK
  Future<bool> init({
    required RevolutEnvironment environment,
    required String returnUri,
    required String merchantPublicKey,
    bool requestShipping = false,
    CustomerData? customer,
  });

  /// Initiates a payment flow
  Future<bool> pay({
    required String orderToken,
    bool savePaymentMethodForMerchant = false,
  });

  /// Creates a Revolut Pay button
  Future<ButtonResultData> provideButton({ButtonParamsData? buttonParams});

  /// Creates a promotional banner widget
  Future<BannerResultData> providePromotionalBannerWidget({
    PromoBannerParamsData? promoParams,
    String? themeId,
  });

  /// Sets the order token for a controller
  Future<bool> setOrderToken({
    required String orderToken,
    required String controllerId,
  });

  /// Sets whether to save payment method for merchant
  Future<bool> setSavePaymentMethodForMerchant({
    required bool savePaymentMethodForMerchant,
    required String controllerId,
  });
}

/// Exception class for Revolut SDK errors
class RevolutSdkException implements Exception {
  final String code;
  final String message;
  final dynamic details;

  const RevolutSdkException({
    required this.code,
    required this.message,
    this.details,
  });

  @override
  String toString() {
    return 'RevolutSdkException($code: $message${details != null ? ', details: $details' : ''})';
  }
}
