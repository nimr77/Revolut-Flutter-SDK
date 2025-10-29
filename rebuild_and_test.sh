#!/bin/bash

echo "🔄 Rebuilding Revolut SDK Example App..."
echo "═══════════════════════════════════════"

cd example

echo "1️⃣ Cleaning old build..."
flutter clean

echo "2️⃣ Getting dependencies..."
flutter pub get

echo "3️⃣ Uninstalling old app from device..."
adb uninstall com.example.revolut_sdk_bridge_example 2>/dev/null || echo "App not installed"

echo "4️⃣ Building and installing fresh app..."
flutter run

echo "✅ Done!"

