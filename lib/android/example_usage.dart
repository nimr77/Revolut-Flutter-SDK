import 'package:flutter/material.dart';

import 'enums/revolut_enums.dart';
import 'models/revolut_pay_models.dart';
import 'revolut_sdk_bridge_method_channel.dart';
import 'services/revolut_callbacks.dart';
import 'widgets/revolut_pay_button.dart';

/// Example usage of the Android Revolut SDK Bridge
/// This file demonstrates how to integrate the Revolut Pay SDK in a Flutter app
class RevolutSdkExample extends StatefulWidget {
  const RevolutSdkExample({super.key});

  @override
  State<RevolutSdkExample> createState() => _RevolutSdkExampleState();
}

class _RevolutSdkExampleState extends State<RevolutSdkExample> {
  late RevolutSdkBridgeMethodChannel _sdkBridge;
  late RevolutCallbacks _callbacks;

  bool _isInitialized = false;
  bool _isLoading = false;
  String _statusMessage = 'Not initialized';
  String? _orderToken;
  String? _controllerId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Revolut SDK Bridge Example'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status display
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(_statusMessage),
                    const SizedBox(height: 8),
                    Text('Initialized: $_isInitialized'),
                    if (_controllerId != null)
                      Text('Controller ID: $_controllerId'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Order token input
            TextField(
              decoration: const InputDecoration(
                labelText: 'Order Token',
                hintText: 'Enter your order token here',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _orderToken = value;
              },
            ),

            const SizedBox(height: 16),

            // Control buttons
            ElevatedButton(
              onPressed: _isLoading ? null : _initializeSdk,
              child: const Text('Initialize SDK'),
            ),

            const SizedBox(height: 8),

            ElevatedButton(
              onPressed: _isLoading || !_isInitialized
                  ? null
                  : _createController,
              child: const Text('Create Controller'),
            ),

            const SizedBox(height: 8),

            ElevatedButton(
              onPressed: _isLoading || !_isInitialized ? null : _startPayment,
              child: const Text('Start Payment'),
            ),

            const SizedBox(height: 8),

            ElevatedButton(
              onPressed: _getSdkVersion,
              child: const Text('Get SDK Version'),
            ),

            const SizedBox(height: 8),

            ElevatedButton(
              onPressed: _getPlatformVersion,
              child: const Text('Get Platform Version'),
            ),

            const SizedBox(height: 24),

            // Revolut Pay Button example
            if (_isInitialized &&
                _orderToken != null &&
                _orderToken!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Revolut Pay Button:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  RevolutPayButton(
                    buttonParams: const ButtonParamsData(
                      size: ButtonSize.large,
                      radius: ButtonRadius.medium,
                      boxText: BoxText.none,
                    ),
                    orderToken: _orderToken,
                    onPressed: () {
                      _showSnackBar(
                        'Revolut Pay button pressed!',
                        Colors.green,
                      );
                    },
                    onError: (error) {
                      _showSnackBar('Button error: $error', Colors.red);
                    },
                  ),
                ],
              ),

            const SizedBox(height: 16),

            // Simple button example
            if (_isInitialized &&
                _orderToken != null &&
                _orderToken!.isNotEmpty)
              SimpleRevolutPayButton(
                orderToken: _orderToken!,
                onPressed: () {
                  _showSnackBar('Simple button pressed!', Colors.green);
                },
                onError: (error) {
                  _showSnackBar('Simple button error: $error', Colors.red);
                },
                showCashback: true,
                cashbackCurrency: 'GBP',
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _sdkBridge.dispose();
    _callbacks.clearCallbacks();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _setupCallbacks();
    _setupSdkBridge();
  }

  /// Creates a controller for managing payment flows
  Future<void> _createController() async {
    if (!_isInitialized) {
      _showSnackBar('Please initialize the SDK first', Colors.orange);
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = 'Creating controller...';
    });

    try {
      final result = await _sdkBridge.createController();
      setState(() {
        _controllerId = result.controllerId;
        _statusMessage = 'Controller created: ${result.controllerId}';
      });
      _showSnackBar('Controller created!', Colors.green);
    } catch (e) {
      setState(() {
        _statusMessage = 'Error creating controller: $e';
      });
      _showSnackBar('Error: $e', Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Gets the platform version
  Future<void> _getPlatformVersion() async {
    try {
      final platformVersion = await _sdkBridge.getPlatformVersion();
      _showSnackBar('Platform: $platformVersion', Colors.blue);
    } catch (e) {
      _showSnackBar('Error getting platform version: $e', Colors.red);
    }
  }

  /// Gets the SDK version information
  Future<void> _getSdkVersion() async {
    try {
      final versionInfo = await _sdkBridge.getSdkVersion();
      _showSnackBar('SDK Version: ${versionInfo['sdkVersion']}', Colors.blue);
    } catch (e) {
      _showSnackBar('Error getting version: $e', Colors.red);
    }
  }

  /// Initializes the Revolut Pay SDK
  Future<void> _initializeSdk() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Initializing...';
    });

    try {
      final success = await _sdkBridge.init(
        environment: RevolutEnvironment.sandbox.value,
        returnUri: 'https://your-app.com/payment-return',
        merchantPublicKey: 'your_merchant_public_key_here',
        requestShipping: false,
        customer: const CustomerData(
          email: 'customer@example.com',
          name: 'John Doe',
        ).toMap(),
      );

      if (success) {
        setState(() {
          _isInitialized = true;
          _statusMessage = 'SDK initialized successfully';
        });
        _showSnackBar('SDK initialized!', Colors.green);
      } else {
        setState(() {
          _statusMessage = 'Failed to initialize SDK';
        });
        _showSnackBar('Failed to initialize SDK', Colors.red);
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error initializing SDK: $e';
      });
      _showSnackBar('Error: $e', Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Sets up the callback handlers for Revolut Pay SDK events
  void _setupCallbacks() {
    _callbacks = RevolutCallbacks();

    // Set up order completion callback
    _callbacks.setOrderCompletedCallback((result) {
      setState(() {
        _statusMessage = 'Order completed successfully!';
      });
      _showSnackBar('Payment successful!', Colors.green);
    });

    // Set up order failure callback
    _callbacks.setOrderFailedCallback((result) {
      setState(() {
        _statusMessage = 'Order failed: ${result.error}';
      });
      _showSnackBar('Payment failed: ${result.error}', Colors.red);
    });

    // Set up payment abandoned callback
    _callbacks.setUserPaymentAbandonedCallback((result) {
      setState(() {
        _statusMessage = 'Payment abandoned by user';
      });
      _showSnackBar('Payment abandoned', Colors.orange);
    });

    // Set up payment status update callback
    _callbacks.setPaymentStatusUpdateCallback((status, data) {
      setState(() {
        _statusMessage = 'Payment status: $status';
      });
      debugPrint('Payment status update: $status - $data');
    });

    // Set up button click callback
    _callbacks.setButtonClickCallback((buttonId, orderToken) {
      debugPrint('Button clicked: $buttonId, Order token: $orderToken');
      _showSnackBar('Button clicked!', Colors.blue);
    });

    // Set up controller state change callback
    _callbacks.setControllerStateChangeCallback((controllerId, state, data) {
      debugPrint('Controller state change: $controllerId - $state - $data');
      setState(() {
        _statusMessage = 'Controller state: $state';
      });
    });

    // Set up lifecycle event callback
    _callbacks.setLifecycleEventCallback((event, data) {
      debugPrint('Lifecycle event: $event - $data');
    });

    // Set up deep link callback
    _callbacks.setDeepLinkCallback((uri, data) {
      debugPrint('Deep link received: $uri - $data');
      _showSnackBar('Deep link: $uri', Colors.purple);
    });
  }

  /// Sets up the SDK bridge for communication with native Android
  void _setupSdkBridge() {
    _sdkBridge = RevolutSdkBridgeMethodChannel(_callbacks);
  }

  /// Shows a snackbar with the given message and color
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Initiates a payment flow
  Future<void> _startPayment() async {
    if (!_isInitialized) {
      _showSnackBar('Please initialize the SDK first', Colors.orange);
      return;
    }

    if (_orderToken == null || _orderToken!.isEmpty) {
      _showSnackBar('Please enter an order token', Colors.orange);
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = 'Starting payment...';
    });

    try {
      final success = await _sdkBridge.pay(
        orderToken: _orderToken!,
        savePaymentMethodForMerchant: false,
      );

      if (success) {
        setState(() {
          _statusMessage = 'Payment initiated successfully';
        });
        _showSnackBar('Payment started!', Colors.green);
      } else {
        setState(() {
          _statusMessage = 'Failed to start payment';
        });
        _showSnackBar('Failed to start payment', Colors.red);
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error starting payment: $e';
      });
      _showSnackBar('Error: $e', Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
