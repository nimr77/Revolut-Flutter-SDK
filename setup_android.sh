#!/bin/bash

# Revolut SDK Bridge - Android Setup Script
# This script helps set up the Android implementation of the Revolut SDK Bridge

set -e

echo "🚀 Setting up Revolut SDK Bridge for Android..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ] || [ ! -d "android" ]; then
    print_error "Please run this script from the root of the revolut_sdk_bridge project"
    exit 1
fi

print_status "Checking project structure..."

# Verify Android directory structure
if [ ! -d "android/src/main/kotlin" ]; then
    print_error "Android Kotlin source directory not found. Please ensure the project structure is correct."
    exit 1
fi

print_success "Project structure verified"

# Check if Android SDK is available
print_status "Checking Android SDK..."
if ! command -v adb &> /dev/null; then
    print_warning "Android SDK not found in PATH. Please ensure Android SDK is installed and configured."
    print_warning "You can still proceed with the setup, but you won't be able to test on device."
else
    print_success "Android SDK found"
fi

# Check if Flutter is available
print_status "Checking Flutter..."
if ! command -v flutter &> /dev/null; then
    print_error "Flutter not found in PATH. Please install Flutter first."
    exit 1
fi

print_success "Flutter found: $(flutter --version | head -n 1)"

# Check Flutter version
FLUTTER_VERSION=$(flutter --version | grep -o 'Flutter [0-9]\+\.[0-9]\+\.[0-9]\+' | cut -d' ' -f2)
FLUTTER_MAJOR=$(echo $FLUTTER_VERSION | cut -d'.' -f1)
FLUTTER_MINOR=$(echo $FLUTTER_VERSION | cut -d'.' -f2)

if [ "$FLUTTER_MAJOR" -lt 3 ] || ([ "$FLUTTER_MAJOR" -eq 3 ] && [ "$FLUTTER_MINOR" -lt 3 ]); then
    print_error "Flutter 3.3.0 or higher is required. Current version: $FLUTTER_VERSION"
    exit 1
fi

print_success "Flutter version $FLUTTER_VERSION is compatible"

# Clean and get dependencies
print_status "Getting Flutter dependencies..."
flutter clean
flutter pub get

print_success "Flutter dependencies updated"

# Check Android build configuration
print_status "Verifying Android build configuration..."

# Check if Revolut repository is configured
if ! grep -q "maven.revolut.com" android/build.gradle; then
    print_warning "Revolut repository not found in android/build.gradle"
    print_warning "Please ensure the repository is properly configured:"
    echo "    maven { url \"https://maven.revolut.com/releases\" }"
fi

# Check if Revolut SDK dependencies are configured
if ! grep -q "com.revolut:revolut-pay-sdk" android/build.gradle; then
    print_warning "Revolut SDK dependencies not found in android/build.gradle"
    print_warning "Please ensure the dependencies are properly configured:"
    echo "    implementation 'com.revolut:revolut-pay-sdk:2.0.0'"
    echo "    implementation 'com.revolut:revolut-pay-ui:2.0.0'"
fi

# Check example app configuration
if [ -d "example" ]; then
    print_status "Checking example app configuration..."
    
    if ! grep -q "maven.revolut.com" example/android/settings.gradle.kts; then
        print_warning "Revolut repository not found in example/android/settings.gradle.kts"
    fi
    
    if ! grep -q "com.revolut:revolut-pay-sdk" example/android/app/build.gradle.kts; then
        print_warning "Revolut SDK dependencies not found in example/android/app/build.gradle.kts"
    fi
fi

# Check Android manifest permissions
print_status "Checking Android manifest permissions..."

if [ -f "android/src/main/AndroidManifest.xml" ]; then
    if ! grep -q "android.permission.INTERNET" android/src/main/AndroidManifest.xml; then
        print_warning "INTERNET permission not found in plugin AndroidManifest.xml"
    fi
    
    if ! grep -q "android.permission.ACCESS_NETWORK_STATE" android/src/main/AndroidManifest.xml; then
        print_warning "ACCESS_NETWORK_STATE permission not found in plugin AndroidManifest.xml"
    fi
fi

if [ -f "example/android/app/src/main/AndroidManifest.xml" ]; then
    if ! grep -q "android.permission.INTERNET" example/android/app/src/main/AndroidManifest.xml; then
        print_warning "INTERNET permission not found in example app AndroidManifest.xml"
    fi
fi

# Check deep link configuration
print_status "Checking deep link configuration..."

if [ -f "example/android/app/src/main/AndroidManifest.xml" ]; then
    if ! grep -q "android:scheme=\"revolut\"" example/android/app/src/main/AndroidManifest.xml; then
        print_warning "Deep link scheme not configured in example app AndroidManifest.xml"
        print_warning "Please add the following intent filter:"
        echo "    <intent-filter>"
        echo "        <action android:name=\"android.intent.action.VIEW\" />"
        echo "        <category android:name=\"android.intent.category.DEFAULT\" />"
        echo "        <category android:name=\"android.intent.category.BROWSABLE\" />"
        echo "        <data android:scheme=\"revolut\" />"
        echo "    </intent-filter>"
    fi
fi

# Try to build the project
print_status "Attempting to build the project..."

if flutter build apk --debug --target-platform android-arm64; then
    print_success "Project builds successfully!"
else
    print_warning "Project build failed. This might be due to missing Revolut SDK credentials or configuration."
    print_warning "Please check the error messages above and ensure all dependencies are properly configured."
fi

# Setup instructions
echo ""
echo "📋 Setup Summary:"
echo "=================="
echo ""
echo "✅ Flutter dependencies updated"
echo "✅ Project structure verified"
echo "✅ Build configuration checked"
echo ""
echo "🔧 Next Steps:"
echo "=============="
echo ""
echo "1. Configure your Revolut merchant credentials:"
echo "   - Get your merchant public key from Revolut Business dashboard"
echo "   - Update the example app with your credentials"
echo ""
echo "2. Test the integration:"
echo "   - Run 'flutter run' in the example directory"
echo "   - Test on a physical Android device (recommended)"
echo ""
echo "3. Customize for your app:"
echo "   - Copy the relevant code to your app"
echo "   - Update the deep link scheme if needed"
echo "   - Configure your own return URI"
echo ""
echo "📚 Documentation:"
echo "================="
echo "   - Android implementation: lib/android/README.md"
echo "   - Example usage: lib/android/example_usage.dart"
echo "   - Revolut SDK docs: https://developer.revolut.com/docs/sdks/merchant-android-sdk"
echo ""
echo "🚨 Important Notes:"
echo "==================="
echo "   - The Revolut SDK requires a physical device for testing"
echo "   - Ensure your device has the Revolut app installed"
echo "   - Test with sandbox credentials before going live"
echo "   - Keep your merchant keys secure and never commit them to version control"
echo ""

print_success "Setup script completed!"
print_status "Please review the summary above and complete the next steps manually."
