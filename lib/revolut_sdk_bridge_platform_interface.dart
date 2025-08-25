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

  /// Get platform version (for debugging)
  Future<String?> getPlatformVersion() {
    throw UnimplementedError('getPlatformVersion() has not been implemented.');
  }

  /// Initialize the Revolut Pay SDK with configuration
  Future<bool> initialize({
    required String merchantPublicKey,
    String? environment,
  }) {
    throw UnimplementedError('initialize() has not been implemented.');
  }
}
