#!/bin/bash

# iOS Build Fix Script for Revolut SDK
# This script helps resolve common iOS build issues with the Revolut SDK

echo "🔧 Fixing iOS build issues for Revolut SDK..."

# Check if we're in the right directory
if [ ! -d "ios" ]; then
    echo "❌ iOS directory not found. Please run this script from your Flutter project root."
    exit 1
fi

cd ios

echo "📱 Updating Podfile configuration..."

# Check if Podfile exists
if [ ! -f "Podfile" ]; then
    echo "❌ Podfile not found in ios directory"
    exit 1
fi

# Add post_install configuration if not present
if ! grep -q "post_install" Podfile; then
    echo "✅ Adding post_install configuration to Podfile..."
    cat >> Podfile << 'EOF'

post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
        config.build_settings['ENABLE_BITCODE'] = 'NO'
        config.build_settings['OTHER_LDFLAGS'] = '$(inherited) -ObjC'
      end
    end
  end
end
EOF
else
    echo "⚠️  post_install configuration already exists in Podfile"
fi

# Check if Revolut source is added
if ! grep -q "revolut-payments-ios" Podfile; then
    echo "✅ Adding Revolut SDK source to Podfile..."
    sed -i.bak '/source '\''https:\/\/github.com\/CocoaPods\/Specs.git'\''/a\source '\''https://github.com/revolut/revolut-payments-ios.git'\''\n' Podfile
else
    echo "⚠️  Revolut SDK source already exists in Podfile"
fi

echo "🧹 Cleaning up previous installations..."
pod deintegrate
rm -rf Pods
rm -f Podfile.lock

echo "📦 Installing pods..."
pod install

if [ $? -eq 0 ]; then
    echo "✅ Pods installed successfully!"
else
    echo "❌ Pod installation failed. Trying alternative approach..."
    
    echo "🔄 Attempting to use RevolutPayLite instead..."
    sed -i.bak 's/RevolutPayments\/RevolutPay/RevolutPayments\/RevolutPayLite/g' Podfile
    
    echo "📦 Installing pods with RevolutPayLite..."
    pod install
    
    if [ $? -eq 0 ]; then
        echo "✅ RevolutPayLite installed successfully!"
        echo "ℹ️  Note: Using lightweight WebView version instead of native SDK"
    else
        echo "❌ Installation still failed. Please check your setup manually."
        exit 1
    fi
fi

cd ..

echo "🧹 Cleaning Flutter build..."
flutter clean
flutter pub get

echo ""
echo "🎉 iOS build fix completed!"
echo ""
echo "📋 Next steps:"
echo "1. Open ios/Runner.xcworkspace in Xcode"
echo "2. Build your project (⌘+B)"
echo "3. If you still get errors, check the troubleshooting section below"
echo ""
echo "🔍 If you still get static library errors:"
echo "1. Download the latest Revolut SDK from their releases"
echo "2. Extract PrivacyInfo.xcprivacy from the SDK bundle"
echo "3. Add it to your iOS project resources"
echo "4. Or consider using RevolutPayLite (WebView version)"
echo ""
echo "📚 For more help, check:"
echo "   - [Revolut iOS SDK Documentation](https://developer.revolut.com/docs/guides/accept-payments/payment-methods/revolut-pay/mobile/ios)"
echo "   - [Apple Static Library Guidelines](https://developer.apple.com/documentation/bundleresources/privacy_manifest_files)"
echo ""
echo "Happy coding! 🚀"
