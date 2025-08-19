#!/bin/bash

# Revolut Pay SDK Bridge Setup Script
# This script helps set up the Revolut Pay SDK Bridge plugin for Flutter

echo "🚀 Setting up Revolut Pay SDK Bridge Plugin..."

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    echo "   Visit: https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "✅ Flutter is installed"

# Check Flutter version
FLUTTER_VERSION=$(flutter --version | grep -o "Flutter [0-9]\+\.[0-9]\+\.[0-9]\+" | head -1)
echo "📱 $FLUTTER_VERSION detected"

# Get Flutter project path
echo "📁 Please enter the path to your Flutter project (or press Enter for current directory):"
read -r PROJECT_PATH

if [ -z "$PROJECT_PATH" ]; then
    PROJECT_PATH="."
fi

if [ ! -f "$PROJECT_PATH/pubspec.yaml" ]; then
    echo "❌ Invalid Flutter project path. pubspec.yaml not found."
    exit 1
fi

echo "✅ Valid Flutter project found at: $PROJECT_PATH"

# Navigate to project directory
cd "$PROJECT_PATH" || exit 1

# Add dependency to pubspec.yaml
echo "📦 Adding Revolut SDK Bridge dependency to pubspec.yaml..."

# Check if dependency already exists
if grep -q "revolut_sdk_bridge:" pubspec.yaml; then
    echo "⚠️  Dependency already exists in pubspec.yaml"
else
    # Add dependency after dependencies: section
    sed -i.bak '/dependencies:/a\  revolut_sdk_bridge: ^1.0.0' pubspec.yaml
    echo "✅ Dependency added to pubspec.yaml"
fi

# Install dependencies
echo "📥 Installing Flutter dependencies..."
flutter pub get

# Platform-specific setup
echo "🔧 Setting up platform-specific configurations..."

# Android setup
if [ -d "android" ]; then
    echo "🤖 Setting up Android configuration..."
    
    # Add Revolut SDK repository to project-level build.gradle
    if [ -f "android/build.gradle" ]; then
        if ! grep -q "maven.revolut.com" android/build.gradle; then
            sed -i.bak '/mavenCentral()/a\        maven { url "https://maven.revolut.com/releases" }' android/build.gradle
            echo "✅ Revolut SDK repository added to android/build.gradle"
        else
            echo "⚠️  Revolut SDK repository already exists in android/build.gradle"
        fi
    fi
    
    # Add Revolut SDK dependencies to app-level build.gradle
    if [ -f "android/app/build.gradle" ]; then
        if ! grep -q "com.revolut:revolut-sdk" android/app/build.gradle; then
            sed -i.bak '/dependencies {/a\    implementation '\''com.revolut:revolut-sdk:2.0.0'\''\n    implementation '\''com.revolut:revolut-auth:2.0.0'\''\n' android/app/build.gradle
            echo "✅ Revolut SDK dependencies added to android/app/build.gradle"
        else
            echo "⚠️  Revolut SDK dependencies already exist in android/app/build.gradle"
        fi
        
        # Update minSdkVersion if needed
        if grep -q "minSdkVersion [0-9]\+" android/app/build.gradle; then
            CURRENT_MIN_SDK=$(grep "minSdkVersion [0-9]\+" android/app/build.gradle | grep -o "[0-9]\+")
            if [ "$CURRENT_MIN_SDK" -lt 24 ]; then
                sed -i.bak "s/minSdkVersion [0-9]\+/minSdkVersion 24/" android/app/build.gradle
                echo "✅ Updated minSdkVersion to 24"
            else
                echo "✅ minSdkVersion is already >= 24 (current: $CURRENT_MIN_SDK)"
            fi
        fi
    fi
else
    echo "⚠️  Android directory not found, skipping Android setup"
fi

# iOS setup
if [ -d "ios" ]; then
    echo "🍎 Setting up iOS configuration..."
    
    # Check if Podfile exists
    if [ -f "ios/Podfile" ]; then
        # Add Revolut Payments SDK source if not already present
        if ! grep -q "revolut-payments-ios" ios/Podfile; then
            sed -i.bak '/source '\''https:\/\/github.com\/CocoaPods\/Specs.git'\''/a\source '\''https://github.com/revolut/revolut-payments-ios.git'\''\n' ios/Podfile
            echo "✅ Revolut Payments SDK source added to ios/Podfile"
        else
            echo "⚠️  Revolut Payments SDK source already exists in ios/Podfile"
        fi
        
        # Update iOS platform version if needed
        if grep -q "platform :ios, '[0-9]\+\.[0-9]\+'" ios/Podfile; then
            CURRENT_IOS_VERSION=$(grep "platform :ios, '[0-9]\+\.[0-9]\+'" ios/Podfile | grep -o "[0-9]\+\.[0-9]\+")
            if [ "$(echo "$CURRENT_IOS_VERSION < 13.0" | bc -l)" -eq 1 ]; then
                sed -i.bak "s/platform :ios, '[0-9]\+\.[0-9]\+'/platform :ios, '13.0'/" ios/Podfile
                echo "✅ Updated iOS platform version to 13.0"
            else
                echo "✅ iOS platform version is already >= 13.0 (current: $CURRENT_IOS_VERSION)"
            fi
        fi
        
        echo "📱 Installing iOS pods..."
        cd ios
        pod install
        cd ..
        echo "✅ iOS pods installed"
    else
        echo "⚠️  Podfile not found, skipping iOS setup"
    fi
else
    echo "⚠️  iOS directory not found, skipping iOS setup"
fi

# Create example configuration file
echo "📝 Creating example configuration file..."
cat > revolut_pay_config_example.dart << 'EOF'
// Revolut Pay SDK Configuration Example
// Replace these values with your actual Revolut Pay API credentials

class RevolutPayConfig {
  // Get this from your Revolut Developer Dashboard
  static const String merchantPublicKey = 'your_merchant_public_key_here';
  
  // Environment: 'sandbox' for development, 'production' for live
  static const String environment = 'sandbox';
  
  // Example order token (obtained from your server after creating an order)
  static const String exampleOrderToken = 'your_order_token_from_server';
  
  // Example payment amount in minor units (1000 = £10.00)
  static const int exampleAmount = 1000;
  
  // Example currency
  static const String exampleCurrency = 'GBP';
}

// Usage example:
// await RevolutSdkBridge.initialize(
//   merchantPublicKey: RevolutPayConfig.merchantPublicKey,
//   environment: RevolutPayConfig.environment,
// );
//
// await RevolutSdkBridge.createRevolutPayButton(
//   orderToken: RevolutPayConfig.exampleOrderToken,
//   amount: RevolutPayConfig.exampleAmount,
//   currency: RevolutPayConfig.exampleCurrency,
//   email: 'customer@example.com',
// );
EOF

echo "✅ Example configuration file created: revolut_pay_config_example.dart"

# Create Revolut Pay setup guide
echo "🔗 Creating Revolut Pay setup guide..."
cat > REVOLUT_PAY_SETUP_GUIDE.md << 'EOF'
# Revolut Pay SDK Setup Guide

## Overview
This plugin integrates with the Revolut Pay SDK for iOS, allowing you to accept Revolut Pay payments in your Flutter app.

## Prerequisites
1. **Revolut Merchant Account** - Apply for a merchant account at [developer.revolut.com](https://developer.revolut.com/)
2. **Merchant Public Key** - Generate your public API key from the Developer Dashboard
3. **Server Integration** - Set up a backend to create orders using the Merchant API
4. **iOS 13.0+** - Minimum supported iOS version

## Implementation Steps

### 1. Initialize the SDK
```dart
await RevolutSdkBridge.initialize(
  merchantPublicKey: 'your_merchant_public_key',
  environment: 'sandbox', // or 'production'
);
```

### 2. Create an Order (Server-side)
Use the Merchant API to create an order:
```bash
POST https://sandbox-merchant.revolut.com/api/1.0/orders
Authorization: Bearer YOUR_API_KEY
Content-Type: application/json

{
  "amount": 1000,
  "currency": "GBP",
  "merchant_order_ext_ref": "order_123"
}
```

### 3. Create Revolut Pay Button (Client-side)
```dart
final result = await RevolutSdkBridge.createRevolutPayButton(
  orderToken: 'order_token_from_server',
  amount: 1000, // Amount in minor units
  currency: 'GBP',
  email: 'customer@example.com',
  shouldRequestShipping: false, // Set to true for shipping details
  savePaymentMethodForMerchant: false, // Set to true for subscriptions
);
```

### 4. Handle Payment Results
```dart
if (result['success'] == true) {
  print('Revolut Pay button created successfully');
  // Display the button in your UI
} else {
  print('Failed to create button: ${result['error']}');
}
```

## Important Notes

- **Order Creation**: Orders must be created on your server using the Merchant API
- **Payment Status**: Use webhooks to track payment lifecycle
- **Testing**: Use sandbox environment and test cards for development
- **Production**: Switch to production environment for live payments
- **Button Display**: The SDK returns button configuration - you need to display the actual button in your UI

## Webhook Setup
Configure webhooks in your Revolut Developer Dashboard to receive payment notifications:
- Payment completed
- Payment failed
- Order status changes

## Testing
Use test cards provided by Revolut for sandbox testing:
- Success: 4000 0000 0000 0002
- Failure: 4000 0000 0000 0009
- 3D Secure: 4000 0000 0000 0002

## Support
- [Revolut Developer Documentation](https://developer.revolut.com/)
- [Merchant API Reference](https://developer.revolut.com/docs/merchant-api)
- [Revolut Pay iOS SDK Documentation](https://developer.revolut.com/docs/guides/accept-payments/payment-methods/revolut-pay/mobile/ios)
EOF

echo "✅ Revolut Pay setup guide created: REVOLUT_PAY_SETUP_GUIDE.md"

# Final instructions
echo ""
echo "🎉 Revolut Pay SDK Bridge setup completed!"
echo ""
echo "📋 Next steps:"
echo "1. Get your merchant public key from Revolut Developer Dashboard"
echo "2. Set up your backend to create orders using the Merchant API"
echo "3. Test the integration with the example app"
echo "4. Configure webhooks for payment notifications"
echo ""
echo "📚 For more information:"
echo "   - Check REVOLUT_PAY_SETUP_GUIDE.md"
echo "   - Visit [developer.revolut.com](https://developer.revolut.com/)"
echo "   - Review the example app code"
echo ""
echo "🔑 Key differences from previous version:"
echo "   - Uses RevolutPayments/RevolutPay SDK (v3.0.0+)"
echo "   - Focuses on Revolut Pay button creation"
echo "   - Requires server-side order creation"
echo "   - No OAuth flow needed"
echo "   - Native iOS payment experience"
echo ""
echo "Happy coding! 🚀"
