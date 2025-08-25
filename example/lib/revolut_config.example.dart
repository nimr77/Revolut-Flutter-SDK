// Revolut Configuration Example
// Copy this file to revolut_config.dart and fill in your actual credentials
// IMPORTANT: revolut_config.dart is in .gitignore to prevent committing real credentials

class RevolutConfig {
  // Test Environment
  static const String testSecretKey = 'your_test_secret_key_here';
  static const String testPublicKey = 'your_test_public_key_here';
  static const String testBaseUrl = 'https://sandbox-merchant.revolut.com/';
  static const String testWebhookSecret = 'your_test_webhook_secret_here';

  // Production Environment (replace with real credentials)
  static const String prodSecretKey = 'your_production_secret_key_here';
  static const String prodPublicKey = 'your_production_public_key_here';
  static const String prodBaseUrl = 'https://merchant.revolut.com/';
  static const String prodWebhookSecret = 'your_production_webhook_secret_here';

  // Current Environment
  static const String environment =
      'sandbox'; // Change to 'production' for live

  // Get current base URL based on environment
  static String get currentBaseUrl {
    return environment == 'production' ? prodBaseUrl : testBaseUrl;
  }

  // Get current public key based on environment
  static String get currentPublicKey {
    return environment == 'production' ? prodPublicKey : testPublicKey;
  }
}
