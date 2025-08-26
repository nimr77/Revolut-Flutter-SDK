import 'package:flutter/material.dart';
import 'package:revolut_sdk_bridge/revolut_sdk_bridge.dart';

import 'revolut_config.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Revolut Pay SDK Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Revolut Pay SDK Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _currencyController = TextEditingController();
  final List<RevolutLogEntryIos> _logs = [];
  final List<RevolutPaymentResultIos> _paymentResults = [];
  bool _isInitialized = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SDK Status',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isInitialized
                            ? 'SDK Initialized'
                            : 'SDK Not Initialized',
                      ),
                      const SizedBox(height: 16),
                      if (!_isInitialized)
                        ElevatedButton(
                          onPressed: _initializeSDK,
                          child: const Text('Initialize SDK'),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_isInitialized) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment Details',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _amountController,
                          decoration: const InputDecoration(
                            labelText: 'Amount (in minor units)',
                            hintText: 'e.g., 1000 for £10.00',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _currencyController,
                          decoration: const InputDecoration(
                            labelText: 'Currency',
                            hintText: 'e.g., GBP, EUR, USD',
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Revolut Pay Button with full customization
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Revolut Pay Button',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 16),
                                RevolutPayButtonIos(
                                  style: RevolutPayButtonStyleIos(height: 70),
                                  config: RevolutPayButtonConfigIos(
                                    orderToken: 'test_order_token_123',
                                    amount:
                                        int.tryParse(_amountController.text) ??
                                        1000,
                                    currency: _currencyController.text,
                                    email: 'customer@example.com',
                                    shouldRequestShipping: false,
                                    savePaymentMethodForMerchant: false,
                                    returnURL:
                                        'revolut-sdk-bridge://revolut-pay',
                                    merchantName: 'Test Merchant',
                                    merchantLogoURL:
                                        'https://example.com/logo.png',
                                    additionalData: {
                                      'test_mode': true,
                                      'source': 'flutter_example',
                                    },
                                  ),
                                  onPaymentResult: (result) {
                                    setState(() {
                                      _paymentResults.add(result);
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Payment Result: ${result.success ? "Success" : "Failed"}',
                                        ),
                                        backgroundColor: result.success
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    );
                                  },
                                  onPaymentError: (error) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Payment Error: $error'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  },
                                  onPaymentCancelled: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Payment Cancelled'),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                  },
                                  onButtonCreated: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Revolut Pay button created successfully!',
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  },
                                  onButtonError: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Failed to create Revolut Pay button',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  },
                                  onError: (error) {
                                    // Developer handles errors themselves
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error: $error'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  },
                                ),

                                // Controller Control Buttons
                                // Removed _buttonController control buttons

                                // Button Status Display
                                const SizedBox(height: 16),
                                Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Button Status',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleMedium,
                                        ),
                                        const SizedBox(height: 8),
                                        Text('Is Initialized: $_isInitialized'),
                                        // Removed _buttonController status display
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Configuration Info',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text('Environment: ${RevolutConfig.environment}'),
                      Text('Base URL: ${RevolutConfig.currentBaseUrl}'),
                      Text(
                        'Public Key: ${RevolutConfig.currentPublicKey.substring(0, 20)}...',
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Instructions',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '1. The SDK is configured with test credentials\n'
                        '2. In production, get order tokens from your server\n'
                        '3. Handle payment results and webhooks properly\n'
                        '4. Test with sandbox environment first',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // SDK Logs
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'SDK Logs (${_logs.length})',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          if (_logs.isNotEmpty)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _logs.clear();
                                });
                              },
                              child: const Text('Clear'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_logs.isEmpty)
                        const Text('No logs yet...')
                      else
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListView.builder(
                            itemCount: _logs.length,
                            reverse: true,
                            itemBuilder: (context, index) {
                              final log = _logs[_logs.length - 1 - index];
                              Color logColor;
                              switch (log.level) {
                                case RevolutLogLevelIos.success:
                                  logColor = Colors.green;
                                  break;
                                case RevolutLogLevelIos.warning:
                                  logColor = Colors.orange;
                                  break;
                                case RevolutLogLevelIos.error:
                                  logColor = Colors.red;
                                  break;
                                case RevolutLogLevelIos.info:
                                  logColor = Colors.blue;
                                  break;
                              }

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                child: Text(
                                  log.toString(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: logColor,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Payment Results
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Payment Results (${_paymentResults.length})',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          if (_paymentResults.isNotEmpty)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _paymentResults.clear();
                                });
                              },
                              child: const Text('Clear'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_paymentResults.isEmpty)
                        const Text('No payment results yet...')
                      else
                        Container(
                          height: 150,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListView.builder(
                            itemCount: _paymentResults.length,
                            reverse: true,
                            itemBuilder: (context, index) {
                              final result =
                                  _paymentResults[_paymentResults.length -
                                      1 -
                                      index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                child: Text(
                                  result.toString(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: result.success
                                        ? Colors.green
                                        : Colors.red,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    RevolutCallbacksIos.initialize();
    RevolutCallbacksIos.onLog = (logEntry) {
      setState(() {
        _logs.add(logEntry);
        if (_logs.length > 100) _logs.removeAt(0);
      });
    };
    RevolutCallbacksIos.onPaymentResult = (paymentResult) {
      setState(() {
        _paymentResults.add(paymentResult);
        if (_paymentResults.length > 50) _paymentResults.removeAt(0);
      });
    };
    _initializeSDK();
  }

  Future<void> _initializeSDK() async {
    try {
      setState(() {
        _isInitialized = false;
      });

      // Use the configuration from RevolutConfig
      final String merchantPublicKey = RevolutConfig.currentPublicKey;

      final bool result = await RevolutSdkBridgeIos.initializeIos(
        merchantPublicKey: merchantPublicKey,
        environment: RevolutConfig
            .environment, // Use 'sandbox' for testing, 'production' for live payments
      );

      if (result) {
        setState(() {
          _isInitialized = true;
        });
      } else {
        setState(() {
          _isInitialized = false;
        });
      }
    } catch (e) {
      setState(() {
        _isInitialized = false;
      });
    }
  }
}
