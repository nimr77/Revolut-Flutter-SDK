#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint revolut_sdk_bridge.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'revolut_sdk_bridge'
  s.version          = '1.0.0'
  s.summary          = 'A Flutter plugin that provides a bridge to the native Revolut Pay SDK for iOS.'
  s.description      = <<-DESC
A Flutter plugin that provides a bridge to the native Revolut Pay SDK for iOS, allowing you to accept Revolut Pay payments in your Flutter apps.
                       DESC
  s.homepage         = 'https://github.com/your-username/revolut_sdk_bridge'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'RevolutPayments/RevolutPay', '~> 3.9.0'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'revolut_sdk_bridge_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
