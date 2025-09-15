import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'revolut_sdk_bridge_platform_interface.dart';

/// An implementation of [RevolutSdkBridgePlatform] that uses method channels.
class MethodChannelRevolutSdkBridge extends RevolutSdkBridgePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('revolut_sdk_bridge');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
