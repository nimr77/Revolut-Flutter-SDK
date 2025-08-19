import 'package:flutter_test/flutter_test.dart';
import 'package:revolut_sdk_bridge/revolut_sdk_bridge.dart';
import 'package:revolut_sdk_bridge/revolut_sdk_bridge_platform_interface.dart';
import 'package:revolut_sdk_bridge/revolut_sdk_bridge_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockRevolutSdkBridgePlatform
    with MockPlatformInterfaceMixin
    implements RevolutSdkBridgePlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final RevolutSdkBridgePlatform initialPlatform = RevolutSdkBridgePlatform.instance;

  test('$MethodChannelRevolutSdkBridge is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelRevolutSdkBridge>());
  });

  test('getPlatformVersion', () async {
    RevolutSdkBridge revolutSdkBridgePlugin = RevolutSdkBridge();
    MockRevolutSdkBridgePlatform fakePlatform = MockRevolutSdkBridgePlatform();
    RevolutSdkBridgePlatform.instance = fakePlatform;

    expect(await revolutSdkBridgePlugin.getPlatformVersion(), '42');
  });
}
