# Revolut SDK Bridge - iOS Plugin

This directory contains the iOS plugin for the Revolut SDK Bridge Flutter plugin.

## 🚀 Opening in Xcode

You can now open the iOS plugin directly in Xcode:

1. **Double-click** `revolut_sdk_bridge.xcodeproj` in Finder
2. **Or use terminal**: `open revolut_sdk_bridge.xcodeproj`
3. **Or drag the .xcodeproj file** into Xcode

## 📁 Project Structure

```
ios/
├── revolut_sdk_bridge.xcodeproj/          # Xcode project file
│   ├── project.pbxproj                    # Main project configuration
│   ├── project.xcworkspace/               # Workspace configuration
│   └── xcshareddata/xcschemes/           # Build schemes
├── Classes/
│   └── RevolutSdkBridgePlugin.swift      # Main plugin implementation
├── Assets/                                # Asset catalog
├── Resources/
│   └── PrivacyInfo.xcprivacy             # Privacy manifest
├── revolut_sdk_bridge.podspec            # CocoaPods specification
└── Info.plist                            # Framework info
```

## 🔧 Building the Plugin

### In Xcode:
1. Select the `revolut_sdk_bridge` target
2. Choose your target device/simulator
3. Press `Cmd + B` to build

### From Terminal:
```bash
# Build for iOS Simulator
xcodebuild -project revolut_sdk_bridge.xcodeproj \
           -scheme revolut_sdk_bridge \
           -destination 'platform=iOS Simulator,name=iPhone 15' \
           build

# Build for iOS Device
xcodebuild -project revolut_sdk_bridge.xcodeproj \
           -scheme revolut_sdk_bridge \
           -destination 'platform=iOS,id=YOUR_DEVICE_ID' \
           build
```

## 📱 Features

- **Platform View Factory**: Creates native Revolut Pay buttons
- **Method Channel**: Communication between Flutter and native code
- **Logging System**: Real-time logging back to Flutter
- **Payment Handling**: Native Revolut Pay SDK integration

## 🚨 Important Notes

- **Minimum iOS Version**: 13.0
- **Dependencies**: Requires Revolut Pay SDK (add to your app's Podfile)
- **Framework Type**: Dynamic framework
- **Bundle ID**: com.revolut.sdk.bridge

## 🔗 Integration

This plugin is designed to work with Flutter apps. The native code is automatically integrated when you:

1. Add the plugin to your `pubspec.yaml`
2. Run `flutter pub get`
3. Build your Flutter app

## 🐛 Debugging

- **Logs**: Check the Flutter console for detailed logs
- **Breakpoints**: Set breakpoints in Xcode for native code debugging
- **Method Channel**: Monitor method channel calls in Xcode console

## 📚 Next Steps

1. **Add Revolut Dependencies**: Include Revolut Pay SDK in your app
2. **Test Integration**: Build and test the complete payment flow
3. **Customize**: Modify the button appearance and behavior as needed
