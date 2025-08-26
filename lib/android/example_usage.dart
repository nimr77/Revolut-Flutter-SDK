import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'enums/revolut_enums.dart';
import 'models/revolut_pay_models.dart';
import 'revolut_sdk_bridge_method_channel.dart';
import 'services/revolut_callbacks.dart';

/// Example usage of the Revolut SDK Bridge
/// This class demonstrates how to integrate and use all Revolut SDK features
class RevolutSdkExample extends StatefulWidget {
  const RevolutSdkExample({super.key});

  @override
  State<RevolutSdkExample> createState() => _RevolutSdkExampleState();
}

class _RevolutSdkExampleState extends State<RevolutSdkExample> {
  final RevolutSdkBridgeMethodChannel _sdkBridge =
      RevolutSdkBridgeMethodChannel(RevolutCallbacks());

  bool _isInitialized = false;
  String? _currentControllerId;
  String? _currentButtonId;
  String? _currentBannerId;

  // Configuration
  final String _merchantPublicKey = 'your_merchant_public_key_here';
  final String _returnUri = 'revolut://payment-callback';
  final RevolutEnvironment _environment = RevolutEnvironment.sandbox;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Revolut SDK Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SDK Status',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          _isInitialized ? Icons.check_circle : Icons.error,
                          color: _isInitialized ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isInitialized ? 'Initialized' : 'Not Initialized',
                          style: TextStyle(
                            color: _isInitialized ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (_currentControllerId != null) ...[
                      const SizedBox(height: 8),
                      Text('Controller: $_currentControllerId'),
                    ],
                    if (_currentButtonId != null) ...[
                      const SizedBox(height: 8),
                      Text('Button: $_currentButtonId'),
                    ],
                    if (_currentBannerId != null) ...[
                      const SizedBox(height: 8),
                      Text('Banner: $_currentBannerId'),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Initialization Section
            if (!_isInitialized) ...[
              _buildSection('Initialization', [
                ElevatedButton(
                  onPressed: _initializeSdk,
                  child: const Text('Initialize SDK'),
                ),
              ]),
            ] else ...[
              // SDK Features Section
              _buildSection('Controllers', [
                ElevatedButton(
                  onPressed: _createController,
                  child: const Text('Create Controller'),
                ),
                if (_currentControllerId != null) ...[
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _setOrderToken,
                    child: const Text('Set Order Token'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _continueConfirmationFlow,
                    child: const Text('Continue Confirmation Flow'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _disposeController,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Dispose Controller'),
                  ),
                ],
              ]),

              const SizedBox(height: 16),

              _buildSection('UI Components', [
                ElevatedButton(
                  onPressed: _createButton,
                  child: const Text('Create Button'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _createBanner,
                  child: const Text('Create Banner'),
                ),
              ]),

              const SizedBox(height: 16),

              _buildSection('Payment', [
                ElevatedButton(
                  onPressed: _initiatePayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Initiate Payment'),
                ),
              ]),

              const SizedBox(height: 16),

              _buildSection('Information', [
                ElevatedButton(
                  onPressed: _getSdkVersion,
                  child: const Text('Get SDK Version'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _getPlatformVersion,
                  child: const Text('Get Platform Version'),
                ),
              ]),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _sdkBridge.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initializeSdk();
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  /// Continue confirmation flow
  Future<void> _continueConfirmationFlow() async {
    if (_currentControllerId == null) {
      _showSnackBar('No controller available. Create one first.');
      return;
    }

    try {
      final success = await _sdkBridge.continueConfirmationFlow(
        controllerId: _currentControllerId!,
      );

      if (success) {
        _showSnackBar('Confirmation flow continued');
      } else {
        _showSnackBar('Failed to continue confirmation flow');
      }
    } catch (e) {
      _showSnackBar('Error continuing confirmation flow: $e');
    }
  }

  /// Create a promotional banner
  Future<void> _createBanner() async {
    try {
      final promoParams = PromoBannerParamsData(
        transactionId: 'example_transaction_123',
        paymentAmount: 1000, // Amount in smallest currency unit (e.g., cents)
        currency: RevolutCurrency.gbp,
        customer: CustomerData(
          name: 'John Doe',
          email: 'john.doe@example.com',
          phone: '+44123456789',
          country: 'GB',
          dateOfBirth: DateOfBirthData(day: 15, month: 6, year: 1990),
        ),
      );

      final result = await _sdkBridge.providePromotionalBannerWidget(
        promoParams: promoParams.toMap(),
        themeId: 'default',
      );

      if (result.success) {
        setState(() {
          _currentBannerId = result.bannerId;
        });
        _showSnackBar('Banner created: ${result.bannerId}');
      } else {
        _showSnackBar('Failed to create banner');
      }
    } catch (e) {
      _showSnackBar('Error creating banner: $e');
    }
  }

  /// Create a Revolut Pay button
  Future<void> _createButton() async {
    try {
      final buttonParams = ButtonParamsData(
        radius: ButtonRadius.medium,
        size: ButtonSize.large,
        boxText: BoxText.getCashbackValue,
        boxTextCurrency: 'GBP',
        variantModes: VariantModesData(
          darkTheme: ButtonVariant.dark,
          lightTheme: ButtonVariant.light,
        ),
      );

      final result = await _sdkBridge.provideButton(
        buttonParams: buttonParams.toMap(),
      );

      if (result.success) {
        setState(() {
          _currentButtonId = result.buttonId;
        });
        _showSnackBar('Button created: ${result.buttonId}');
      } else {
        _showSnackBar('Failed to create button');
      }
    } catch (e) {
      _showSnackBar('Error creating button: $e');
    }
  }

  /// Create a controller for managing payment flows
  Future<void> _createController() async {
    try {
      final result = await _sdkBridge.createController();
      if (result.success) {
        setState(() {
          _currentControllerId = result.controllerId;
        });
        _showSnackBar('Controller created: ${result.controllerId}');
      } else {
        _showSnackBar('Failed to create controller');
      }
    } catch (e) {
      _showSnackBar('Error creating controller: $e');
    }
  }

  /// Dispose current controller
  Future<void> _disposeController() async {
    if (_currentControllerId == null) {
      _showSnackBar('No controller to dispose');
      return;
    }

    try {
      final success = await _sdkBridge.disposeController(
        controllerId: _currentControllerId!,
      );

      if (success) {
        setState(() {
          _currentControllerId = null;
        });
        _showSnackBar('Controller disposed successfully');
      } else {
        _showSnackBar('Failed to dispose controller');
      }
    } catch (e) {
      _showSnackBar('Error disposing controller: $e');
    }
  }

  /// Get platform version
  Future<void> _getPlatformVersion() async {
    try {
      final platformVersion = await _sdkBridge.getPlatformVersion();
      _showSnackBar('Platform: $platformVersion');
    } catch (e) {
      _showSnackBar('Error getting platform version: $e');
    }
  }

  /// Get SDK version information
  Future<void> _getSdkVersion() async {
    try {
      final versionInfo = await _sdkBridge.getSdkVersion();
      _showSnackBar('SDK Version: ${versionInfo['version']}');
    } catch (e) {
      _showSnackBar('Error getting SDK version: $e');
    }
  }

  /// Initialize the Revolut SDK
  Future<void> _initializeSdk() async {
    try {
      final success = await _sdkBridge.init(
        environment: _environment.value,
        returnUri: _returnUri,
        merchantPublicKey: _merchantPublicKey,
        requestShipping: false,
        customer: CustomerData(
          name: 'John Doe',
          email: 'john.doe@example.com',
          phone: '+44123456789',
          country: 'GB',
          dateOfBirth: DateOfBirthData(day: 15, month: 6, year: 1990),
        ).toMap(),
      );

      if (success) {
        setState(() {
          _isInitialized = true;
        });
        _showSnackBar('Revolut SDK initialized successfully');
      } else {
        _showSnackBar('Failed to initialize Revolut SDK');
      }
    } catch (e) {
      _showSnackBar('Error initializing SDK: $e');
    }
  }

  /// Initiate a payment flow
  Future<void> _initiatePayment() async {
    try {
      // In a real app, you would get this from your backend
      const orderToken = 'example_order_token_123';

      final success = await _sdkBridge.pay(
        orderToken: orderToken,
        savePaymentMethodForMerchant: false,
      );

      if (success) {
        _showSnackBar('Payment initiated successfully');
      } else {
        _showSnackBar('Failed to initiate payment');
      }
    } catch (e) {
      _showSnackBar('Error initiating payment: $e');
    }
  }

  /// Set order token for a controller
  Future<void> _setOrderToken() async {
    if (_currentControllerId == null) {
      _showSnackBar('No controller available. Create one first.');
      return;
    }

    try {
      const orderToken = 'example_order_token_456';

      final success = await _sdkBridge.setOrderToken(
        orderToken: orderToken,
        controllerId: _currentControllerId!,
      );

      if (success) {
        _showSnackBar('Order token set successfully');
      } else {
        _showSnackBar('Failed to set order token');
      }
    } catch (e) {
      _showSnackBar('Error setting order token: $e');
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }
}
