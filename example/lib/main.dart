import 'package:flutter/material.dart';
import 'package:revolut_sdk_bridge/revolut_sdk_bridge.dart';

void main() {
  runApp(const RevolutSDKDemoApp());
}

class RevolutPayDemoPage extends StatefulWidget {
  const RevolutPayDemoPage({super.key});

  @override
  State<RevolutPayDemoPage> createState() => _RevolutPayDemoPageState();
}

class RevolutSDKDemoApp extends StatelessWidget {
  const RevolutSDKDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Revolut Pay SDK Bridge Demo',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const RevolutPayDemoPage(),
    );
  }
}

class _RevolutPayDemoPageState extends State<RevolutPayDemoPage> {
  bool _isInitialized = false;
  String _status = 'Not initialized';
  Map<String, dynamic>? _lastPaymentResult;

  final TextEditingController _merchantPublicKeyController =
      TextEditingController();
  final TextEditingController _orderTokenController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _currencyController = TextEditingController();
  final TextEditingController _customerEmailController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Revolut Pay SDK Demo'),
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
                      'Status: $_status',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          _isInitialized ? Icons.check_circle : Icons.error,
                          color: _isInitialized ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(_isInitialized ? 'Ready' : 'Not Ready'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Configuration Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Revolut Pay Configuration',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _merchantPublicKeyController,
                      decoration: const InputDecoration(
                        labelText: 'Merchant Public Key',
                        border: OutlineInputBorder(),
                        helperText:
                            'Get this from your Revolut Developer Dashboard',
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isInitialized ? null : _initializeSDK,
                      child: const Text('Initialize Revolut Pay SDK'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Payment Details Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Details',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _orderTokenController,
                      decoration: const InputDecoration(
                        labelText: 'Order Token',
                        border: OutlineInputBorder(),
                        helperText:
                            'Token from your server after creating an order',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _amountController,
                            decoration: const InputDecoration(
                              labelText: 'Amount (minor units)',
                              border: OutlineInputBorder(),
                              helperText: 'e.g., 1000 for £10.00',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _currencyController,
                            decoration: const InputDecoration(
                              labelText: 'Currency',
                              border: OutlineInputBorder(),
                              helperText: 'e.g., GBP, EUR, USD',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _customerEmailController,
                      decoration: const InputDecoration(
                        labelText: 'Customer Email (Optional)',
                        border: OutlineInputBorder(),
                        helperText: 'For receipts and payment confirmations',
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isInitialized
                          ? _createRevolutPayButton
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Create Revolut Pay Button'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Actions Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Actions',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _getPlatformVersion,
                      child: const Text('Get Platform Version'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Payment Result Card
            if (_lastPaymentResult != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Last Button Creation Result',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow('Success', _lastPaymentResult!['success']),
                      _buildInfoRow('Status', _lastPaymentResult!['status']),
                      if (_lastPaymentResult!['message'] != null)
                        _buildInfoRow(
                          'Message',
                          _lastPaymentResult!['message'],
                        ),
                      if (_lastPaymentResult!['error'] != null)
                        _buildInfoRow('Error', _lastPaymentResult!['error']),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Information Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How Revolut Pay Works',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '1. Initialize the SDK with your merchant public key\n'
                      '2. Create an order on your server using the Merchant API\n'
                      '3. Use the order token to create a Revolut Pay button\n'
                      '4. The SDK will present the native Revolut Pay interface\n'
                      '5. Handle the payment result in the completion handler\n'
                      '6. Use webhooks to track payment lifecycle\n\n'
                      'Note: This demo shows button creation. In a real app, the button would be displayed in your UI.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _merchantPublicKeyController.dispose();
    _orderTokenController.dispose();
    _amountController.dispose();
    _currencyController.dispose();
    _customerEmailController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _checkInitializationStatus();

    // Pre-fill with example values (replace with your actual values)
    _merchantPublicKeyController.text = 'your_merchant_public_key';
    _orderTokenController.text = 'your_order_token_from_server';
    _amountController.text = '1000';
    _currencyController.text = 'GBP';
    _customerEmailController.text = 'customer@example.com';
  }

  Widget _buildInfoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value?.toString() ?? 'N/A')),
        ],
      ),
    );
  }

  Future<void> _checkInitializationStatus() async {
    try {
      final initialized = await RevolutSdkBridge.isInitialized();
      setState(() {
        _isInitialized = initialized;
        _status = initialized ? 'Initialized' : 'Not initialized';
      });
    } catch (e) {
      setState(() {
        _status = 'Error checking status: $e';
      });
    }
  }

  Future<void> _createRevolutPayButton() async {
    if (!_isInitialized) {
      _showSnackBar('Please initialize the SDK first');
      return;
    }

    if (_orderTokenController.text.isEmpty ||
        _amountController.text.isEmpty ||
        _currencyController.text.isEmpty) {
      _showSnackBar('Please fill in all required fields');
      return;
    }

    try {
      setState(() {
        _status = 'Creating Revolut Pay button...';
      });

      final amount = int.tryParse(_amountController.text) ?? 0;
      if (amount <= 0) {
        _showSnackBar('Please enter a valid amount');
        return;
      }

      final paymentResult = await RevolutSdkBridge.createRevolutPayButton(
        orderToken: _orderTokenController.text,
        amount: amount,
        currency: _currencyController.text,
        email: _customerEmailController.text.isNotEmpty
            ? _customerEmailController.text
            : null,
        shouldRequestShipping:
            false, // Set to true if you want shipping details
        savePaymentMethodForMerchant:
            false, // Set to true for subscriptions/MIT
      );

      setState(() {
        _lastPaymentResult = paymentResult;
        _status = paymentResult != null && paymentResult['success'] == true
            ? 'Revolut Pay button created'
            : 'Failed to create button';
      });

      if (paymentResult != null) {
        if (paymentResult['success'] == true) {
          _showSnackBar('Revolut Pay button created successfully!');
          _showRevolutPayButtonInfo(paymentResult);
        } else {
          _showSnackBar('Failed to create button: ${paymentResult['error']}');
        }
      }
    } catch (e) {
      setState(() {
        _status = 'Button creation error: $e';
      });
      _showSnackBar('Failed to create button: $e');
    }
  }

  Future<void> _getPlatformVersion() async {
    try {
      final version = await RevolutSdkBridge.getPlatformVersion();
      _showSnackBar('Platform version: $version');
    } catch (e) {
      _showSnackBar('Failed to get platform version: $e');
    }
  }

  Future<void> _initializeSDK() async {
    if (_merchantPublicKeyController.text.isEmpty) {
      _showSnackBar('Please enter your merchant public key');
      return;
    }

    setState(() {
      _status = 'Initializing...';
    });

    try {
      final success = await RevolutSdkBridge.initialize(
        merchantPublicKey: _merchantPublicKeyController.text,
        environment: 'sandbox',
      );

      setState(() {
        _isInitialized = success;
        _status = success
            ? 'Initialized successfully'
            : 'Initialization failed';
      });

      if (success) {
        _showSnackBar('Revolut Pay SDK initialized successfully!');
      }
    } catch (e) {
      setState(() {
        _status = 'Initialization error: $e';
      });
      _showSnackBar('Initialization failed: $e');
    }
  }

  void _showRevolutPayButtonInfo(Map<String, dynamic> buttonConfig) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revolut Pay Button Created'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order Token: ${buttonConfig['orderToken']}'),
            Text(
              'Amount: ${buttonConfig['amount']} ${buttonConfig['currency']}',
            ),
            Text('Email: ${buttonConfig['email']}'),
            Text(
              'Shipping: ${buttonConfig['shouldRequestShipping'] ? 'Yes' : 'No'}',
            ),
            Text(
              'Save for Merchant: ${buttonConfig['savePaymentMethodForMerchant'] ? 'Yes' : 'No'}',
            ),
            const SizedBox(height: 16),
            const Text(
              'In a real app, this would display the actual Revolut Pay button that customers can tap to complete their payment.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
