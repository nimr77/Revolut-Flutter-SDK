#!/bin/bash

# Revolut SDK Live Logs Viewer
# This script shows real-time logs from the Revolut SDK with color and emojis

echo "🔴 Starting Revolut SDK Live Logs Monitor..."
echo "═══════════════════════════════════════════════════════════"
echo "Press Ctrl+C to stop"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Clear old logs
adb logcat -c

# Start monitoring with color and filtering for Revolut-related logs
adb logcat -v color | grep --line-buffered -E "RevolutPayButton|RevolutSdkBridge|🔵|🟢|🚀|💰|🎉|❌|✅|⚠️|🔥"

