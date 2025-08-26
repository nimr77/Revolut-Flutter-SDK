# Revolut Pay SDK Setup Guide

This guide explains how to set up the Revolut Pay SDK with your credentials in the example app.

## 🔐 Credentials Setup

### 1. Get Your Revolut Credentials

1. Go to [Revolut Developer Portal](https://developer.revolut.com/)
2. Create a merchant account or log in to your existing account
3. Navigate to the API Keys section
4. Generate your test and production API keys

### 2. Configure the Example App

The example app uses a configuration file to store your Revolut credentials securely.

#### Option A: Use the Template (Recommended)

1. Copy the template file:
   ```bash
   cp lib/revolut_config.example.dart lib/revolut_config.dart
   ```

2. Edit `lib/revolut_config.dart` and replace the placeholder values with your actual credentials:
   ```dart
   // Test Environment
   static const String testSecretKey = 'sk_your_actual_test_secret_key';
   static const String testPublicKey = 'pk_your_actual_test_public_key';
   static const String testBaseUrl = 'https://sandbox-merchant.revolut.com/';
   static const String testWebhookSecret = 'wsk_your_actual_test_webhook_secret';
   
   // Production Environment
   static const String prodSecretKey = 'sk_your_actual_production_secret_key';
   static const String prodPublicKey = 'pk_your_actual_production_public_key';
   static const String prodBaseUrl = 'https://merchant.revolut.com/';
   static const String prodWebhookSecret = 'wsk_your_actual_production_webhook_secret';
   ```

#### Option B: Use Environment Variables

1. Create a `.env` file in the example directory:
   ```bash
   # Revolut Test Environment
   TEST_SECRET_KEY=sk_your_test_secret_key
   TEST_PUBLIC_KEY=pk_your_test_public_key
   TEST_BASE_URL=https://sandbox-merchant.revolut.com/
   TEST_WEBHOOK_SECRET=wsk_your_test_webhook_secret
   
   # Environment (sandbox for testing, production for live)
   ENVIRONMENT=sandbox
   ```

2. Install the `flutter_dotenv` package and update the configuration to load from environment variables.

### 3. Security Notes

⚠️ **IMPORTANT**: Never commit your real credentials to version control!

- `lib/revolut_config.dart` is already in `.gitignore`
- `.env` files are already in `.gitignore`
- The `config/` directory is already in `.gitignore`

## 🚀 Running the Example

1. Make sure you have configured your credentials
2. Run the app:
   ```bash
   flutter run
   ```

3. The app will:
   - Initialize the Revolut Pay SDK with your credentials
   - Show the current configuration (environment, base URL, public key)
   - Allow you to create Revolut Pay buttons for testing

## 🔄 Environment Switching

To switch between test and production environments:

1. Edit `lib/revolut_config.dart`
2. Change the `environment` constant:
   ```dart
   static const String environment = 'production'; // or 'sandbox'
   ```

## 📱 Testing

- **Sandbox Environment**: Use test cards and credentials for development
- **Production Environment**: Use real cards and credentials for live payments

## 🆘 Troubleshooting

### Common Issues

1. **SDK Initialization Failed**
   - Check your public key is correct
   - Ensure you're using the right environment (sandbox/production)

2. **Payment Button Creation Failed**
   - Verify your order token is valid
   - Check the amount and currency format

3. **Build Errors**
   - Run `flutter clean` and `flutter pub get`
   - Ensure all dependencies are properly installed

### Support

- [Revolut Developer Documentation](https://developer.revolut.com/)
- [Revolut Pay iOS SDK Guide](https://developer.revolut.com/docs/guides/accept-payments/payment-methods/revolut-pay/mobile/ios)
- [Flutter Plugin Development](https://docs.flutter.dev/development/packages-and-plugins/developing-packages)

