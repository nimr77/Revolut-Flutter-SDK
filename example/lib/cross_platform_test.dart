import 'package:flutter/material.dart';
import 'package:revolut_sdk_bridge/revolut_sdk_bridge.dart';

/// A simple test widget to demonstrate cross-platform functionality
class CrossPlatformTest extends StatelessWidget {
  const CrossPlatformTest({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cross-Platform Test')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Platform detection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Platform Detection',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text('Current Platform: ${_getPlatformInfo()}'),
                    const SizedBox(height: 8),
                    Text('SDK Bridge Type: ${RevolutSdkBridge().runtimeType}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Cross-platform button test
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cross-Platform Button Test',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    CrossPlatformRevolutPayButton(
                      orderToken: 'test_cross_platform_token',
                      amount: 1000,
                      currency: 'GBP',
                      email: 'test@example.com',
                      height: 60,
                      onPaymentResult: (result) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Payment Result: ${result['success']}',
                            ),
                            backgroundColor: result['success'] == true
                                ? Colors.green
                                : Colors.red,
                          ),
                        );
                      },
                      onError: (error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $error'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      },
                      onButtonCreated: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Button created successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // // Simple button test
            // Card(
            //   child: Padding(
            //     padding: const EdgeInsets.all(16.0),
            //     child: Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         Text(
            //           'Simple Button Test',
            //           style: Theme.of(context).textTheme.headlineSmall,
            //         ),
            //         const SizedBox(height: 16),
            //         // CrossPlatformSimpleRevolutPayButton(
            //         //   orderToken: 'test_simple_token',
            //         //   amount: 500,
            //         //   currency: 'EUR',
            //         //   email: 'simple@example.com',
            //         //   size: ButtonSize.medium,
            //         //   radius: ButtonRadius.small,
            //         //   showCashback: true,
            //         //   cashbackCurrency: 'EUR',
            //         //   onPressed: () {
            //         //     ScaffoldMessenger.of(context).showSnackBar(
            //         //       const SnackBar(
            //         //         content: Text('Simple button pressed!'),
            //         //         backgroundColor: Colors.blue,
            //         //       ),
            //         //     );
            //         //   },
            //         //   onError: (error) {
            //         //     ScaffoldMessenger.of(context).showSnackBar(
            //         //       SnackBar(
            //         //         content: Text('Error: $error'),
            //         //         backgroundColor: Colors.red,
            //         //       ),
            //         //     );
            //         //   },
            //         // ),
            //       ],
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  String _getPlatformInfo() {
    final bridge = RevolutSdkBridge();
    if (bridge.isAndroid) {
      return 'Android';
    } else if (bridge.isIOS) {
      return 'iOS';
    } else {
      return 'Unknown';
    }
  }
}
