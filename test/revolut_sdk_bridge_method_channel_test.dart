import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revolut_sdk_bridge/revolut_sdk_bridge_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelRevolutSdkBridge platform = MethodChannelRevolutSdkBridge();
  const MethodChannel channel = MethodChannel('revolut_sdk_bridge');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
