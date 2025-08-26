import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'models/revolut_pay_models.dart';
import 'services/revolut_callbacks.dart';

/// Method channel implementation for Android Revolut SDK Bridge
/// This class handles all method calls and event streams between Flutter and native Android
class RevolutSdkBridgeMethodChannel {
  static const MethodChannel _channel = MethodChannel('revolut_sdk_bridge');
  static const EventChannel _eventChannel = EventChannel(
    'revolut_sdk_bridge_events',
  );

  final RevolutCallbacks _callbacks;
  StreamSubscription<dynamic>? _eventSubscription;
  bool _isInitialized = false;

  /// Creates a new method channel instance
  RevolutSdkBridgeMethodChannel(this._callbacks) {
    _setupEventChannel();
  }

  /// Sets up the event channel to listen for native events
  void _setupEventChannel() {
    _eventSubscription = _eventChannel.receiveBroadcastStream().listen(
      (event) {
        _handleNativeEvent(event);
      },
      onError: (error) {
        debugPrint('Revolut SDK Bridge event channel error: $error');
      },
    );
  }

  /// Handles events received from the native side
  void _handleNativeEvent(dynamic event) {
    if (event is! Map<String, dynamic>) {
      debugPrint('Invalid event format received: $event');
      return;
    }

    final methodName = event['method'] as String?;
    final data = event['data'] as Map<String, dynamic>?;

    if (methodName == null || data == null) {
      debugPrint('Invalid event structure: $event');
      return;
    }

    switch (methodName) {
      case 'onOrderCompleted':
        _callbacks.handleOrderCompleted(data);
        break;
      case 'onOrderFailed':
        _callbacks.handleOrderFailed(data);
        break;
      case 'onUserPaymentAbandoned':
        _callbacks.handleUserPaymentAbandoned(data);
        break;
      case 'onPaymentStatusUpdate':
        _callbacks.handlePaymentStatusUpdate(data);
        break;
      case 'onButtonClick':
        _callbacks.handleButtonClick(data);
        break;
      case 'onControllerStateChange':
        _callbacks.handleControllerStateChange(data);
        break;
      case 'onBannerInteraction':
        _callbacks.handleBannerInteraction(data);
        break;
      case 'onLifecycleEvent':
        _callbacks.handleLifecycleEvent(data);
        break;
      case 'onDeepLinkReceived':
        _callbacks.handleDeepLinkEvent(data);
        break;
      case 'onNetworkStatusUpdate':
        _callbacks.handleNetworkStatusUpdate(data);
        break;
      case 'onConfigurationUpdate':
        _callbacks.handleConfigurationUpdate(data);
        break;
      case 'onDebugLog':
        _callbacks.handleDebugLog(data);
        break;
      case 'onPerformanceMetric':
        _callbacks.handlePerformanceMetric(data);
        break;
      case 'onUserInteraction':
        _callbacks.handleUserInteraction(data);
        break;
      case 'onSessionEvent':
        _callbacks.handleSessionEvent(data);
        break;
      default:
        debugPrint('Unknown event method: $methodName');
    }
  }

  /// Initializes the Revolut Pay SDK
  Future<bool> init({
    required String environment,
    required String returnUri,
    required String merchantPublicKey,
    bool requestShipping = false,
    Map<String, dynamic>? customer,
  }) async {
    try {
      final result = await _channel.invokeMethod('init', {
        'environment': environment,
        'returnUri': returnUri,
        'merchantPublicKey': merchantPublicKey,
        'requestShipping': requestShipping,
        'customer': customer,
      });

      if (result is bool) {
        _isInitialized = result;
        return result;
      } else if (result is Map<String, dynamic>) {
        final success = result['success'] as bool? ?? false;
        _isInitialized = success;
        return success;
      }
      return false;
    } on PlatformException catch (e) {
      debugPrint('Platform exception during init: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Error during init: $e');
      rethrow;
    }
  }

  /// Initiates a payment flow
  Future<bool> pay({
    required String orderToken,
    bool savePaymentMethodForMerchant = false,
  }) async {
    if (!_isInitialized) {
      throw StateError('Revolut SDK not initialized. Call init() first.');
    }

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
      debugPrint('Platform exception during pay: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Error during pay: $e');
      rethrow;
    }
  }

  /// Creates a Revolut Pay button
  Future<ButtonResultData> provideButton({
    Map<String, dynamic>? buttonParams,
  }) async {
    if (!_isInitialized) {
      throw StateError('Revolut SDK not initialized. Call init() first.');
    }

    try {
      final result = await _channel.invokeMethod('provideButton', {
        'buttonParams': buttonParams,
      });

      if (result is Map<String, dynamic>) {
        return ButtonResultData.fromMap(result);
      }
      throw FormatException('Invalid response format from native side');
    } on PlatformException catch (e) {
      debugPrint(
        'Platform exception during provideButton: ${e.code} - ${e.message}',
      );
      rethrow;
    } catch (e) {
      debugPrint('Error during provideButton: $e');
      rethrow;
    }
  }

  /// Creates a promotional banner widget
  Future<BannerResultData> providePromotionalBannerWidget({
    Map<String, dynamic>? promoParams,
    String? themeId,
  }) async {
    if (!_isInitialized) {
      throw StateError('Revolut SDK not initialized. Call init() first.');
    }

    try {
      final result = await _channel.invokeMethod(
        'providePromotionalBannerWidget',
        {'promoParams': promoParams, 'themeId': themeId},
      );

      if (result is Map<String, dynamic>) {
        return BannerResultData.fromMap(result);
      }
      throw FormatException('Invalid response format from native side');
    } on PlatformException catch (e) {
      debugPrint(
        'Platform exception during providePromotionalBannerWidget: ${e.code} - ${e.message}',
      );
      rethrow;
    } catch (e) {
      debugPrint('Error during providePromotionalBannerWidget: $e');
      rethrow;
    }
  }

  /// Creates a controller for managing confirmation flows
  Future<ControllerResultData> createController() async {
    if (!_isInitialized) {
      throw StateError('Revolut SDK not initialized. Call init() first.');
    }

    try {
      final result = await _channel.invokeMethod('createController');

      if (result is Map<String, dynamic>) {
        return ControllerResultData.fromMap(result);
      }
      throw FormatException('Invalid response format from native side');
    } on PlatformException catch (e) {
      debugPrint(
        'Platform exception during createController: ${e.code} - ${e.message}',
      );
      rethrow;
    } catch (e) {
      debugPrint('Error during createController: $e');
      rethrow;
    }
  }

  /// Sets the order token for a controller
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
      debugPrint(
        'Platform exception during setOrderToken: ${e.code} - ${e.message}',
      );
      rethrow;
    } catch (e) {
      debugPrint('Error during setOrderToken: $e');
      rethrow;
    }
  }

  /// Sets whether to save payment method for merchant
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
      debugPrint(
        'Platform exception during setSavePaymentMethodForMerchant: ${e.code} - ${e.message}',
      );
      rethrow;
    } catch (e) {
      debugPrint('Error during setSavePaymentMethodForMerchant: $e');
      rethrow;
    }
  }

  /// Continues the confirmation flow
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
      debugPrint(
        'Platform exception during continueConfirmationFlow: ${e.code} - ${e.message}',
      );
      rethrow;
    } catch (e) {
      debugPrint('Error during continueConfirmationFlow: $e');
      rethrow;
    }
  }

  /// Disposes a controller
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
      debugPrint(
        'Platform exception during disposeController: ${e.code} - ${e.message}',
      );
      rethrow;
    } catch (e) {
      debugPrint('Error during disposeController: $e');
      rethrow;
    }
  }

  /// Gets the SDK version
  Future<Map<String, dynamic>> getSdkVersion() async {
    try {
      final result = await _channel.invokeMethod('getSdkVersion');

      if (result is Map<String, dynamic>) {
        return result;
      }
      throw FormatException('Invalid response format from native side');
    } on PlatformException catch (e) {
      debugPrint(
        'Platform exception during getSdkVersion: ${e.code} - ${e.message}',
      );
      rethrow;
    } catch (e) {
      debugPrint('Error during getSdkVersion: $e');
      rethrow;
    }
  }

  /// Gets the platform version
  Future<String> getPlatformVersion() async {
    try {
      final result = await _channel.invokeMethod('getPlatformVersion');

      if (result is String) {
        return result;
      }
      throw FormatException('Invalid response format from native side');
    } on PlatformException catch (e) {
      debugPrint(
        'Platform exception during getPlatformVersion: ${e.code} - ${e.message}',
      );
      rethrow;
    } catch (e) {
      debugPrint('Error during getPlatformVersion: $e');
      rethrow;
    }
  }

  /// Checks if the SDK is initialized
  bool get isInitialized => _isInitialized;

  /// Disposes the method channel and cleans up resources
  void dispose() {
    _eventSubscription?.cancel();
    _eventSubscription = null;
    _isInitialized = false;
  }
}
