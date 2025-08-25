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
  bool _isInitialized = false;
  String _status = 'Not initialized';
  final TextEditingController _amountController = TextEditingController(
    text: '1000',
  );
  final TextEditingController _currencyController = TextEditingController(
    text: 'GBP',
  );

  // Logs from the native SDK
  final List<RevolutLogEntry> _logs = [];
  final List<RevolutPaymentResult> _paymentResults = [];

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
                      Text(_status),
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
                        Text(
                          'Revolut Pay Button:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        RevolutPayButton(
                          orderToken: 'test_order_token_123',
                          amount: int.tryParse(_amountController.text) ?? 1000,
                          currency: _currencyController.text,
                          email: 'customer@example.com',
                          shouldRequestShipping: false,
                          savePaymentMethodForMerchant: false,
                          onPaymentResult: (result) {
                            setState(() {
                              _status =
                                  'Payment completed: ${result['status'] ?? 'Unknown status'}';
                            });
                            if (result['success'] == true) {
                              _showSuccessDialog(
                                result['message']?.toString() ??
                                    'Payment successful',
                              );
                            } else {
                              _showErrorDialog(
                                result['error']?.toString() ?? 'Payment failed',
                              );
                            }
                          },
                          onPaymentError: (error) {
                            setState(() {
                              _status = 'Payment error: $error';
                            });
                            _showErrorDialog(error);
                          },
                          onPaymentCancelled: () {
                            setState(() {
                              _status = 'Payment cancelled by user';
                            });
                          },
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
                                case RevolutLogLevel.success:
                                  logColor = Colors.green;
                                  break;
                                case RevolutLogLevel.warning:
                                  logColor = Colors.orange;
                                  break;
                                case RevolutLogLevel.error:
                                  logColor = Colors.red;
                                  break;
                                case RevolutLogLevel.info:
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

    // Initialize the Revolut logger
    RevolutLogger.initialize();

    // Set up log callbacks
    RevolutLogger.onLog = (logEntry) {
      setState(() {
        _logs.add(logEntry);
        // Keep only last 50 logs
        if (_logs.length > 50) {
          _logs.removeAt(0);
        }
      });
    };

    // Set up payment result callbacks
    RevolutLogger.onPaymentResult = (paymentResult) {
      setState(() {
        _paymentResults.add(paymentResult);
        // Keep only last 10 payment results
        if (_paymentResults.length > 10) {
          _paymentResults.removeAt(0);
        }
      });

      // Update status based on payment result
      if (paymentResult.success) {
        _status = 'Payment successful: ${paymentResult.message}';
        _showSuccessDialog(paymentResult.message);
      } else {
        _status = 'Payment failed: ${paymentResult.error}';
        _showErrorDialog(paymentResult.error);
      }
    };

    _initializeSDK();
  }

  Future<void> _initializeSDK() async {
    try {
      setState(() {
        _status = 'Initializing SDK...';
      });

      // Use the configuration from RevolutConfig
      final String merchantPublicKey = RevolutConfig.currentPublicKey;

      final bool result = await RevolutSdkBridge.initialize(
        merchantPublicKey: merchantPublicKey,
        environment: RevolutConfig
            .environment, // Use 'sandbox' for testing, 'production' for live payments
      );

      if (result) {
        setState(() {
          _isInitialized = true;
          _status = 'SDK initialized successfully!';
        });
      } else {
        setState(() {
          _status = 'Failed to initialize SDK';
        });
      }
    } catch (e) {
      setState(() {
        _status = 'Error initializing SDK: $e';
      });
    }
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Payment Failed'),
          content: Text(error),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Payment Successful'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
