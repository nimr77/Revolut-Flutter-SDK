import 'package:flutter/material.dart';
import 'package:revolut_sdk_bridge/revolut_sdk_bridge.dart';

class PluginTest extends StatefulWidget {
  const PluginTest({super.key});

  @override
  State<PluginTest> createState() => _PluginTestState();
}

class _PluginTestState extends State<PluginTest> {
  Map<String, dynamic> _pluginStatus = {};
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin Test'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkPluginStatus,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Plugin Status',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    if (_isLoading)
                      const CircularProgressIndicator()
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _pluginStatus.entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Text(
                              '${entry.key}: ${entry.value}',
                              style: const TextStyle(fontFamily: 'monospace'),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Event Channel Actions',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _setupEventChannel,
                      child: const Text('Setup Event Channel'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _waitForEventChannel,
                      child: const Text('Wait for Event Channel'),
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
  void initState() {
    super.initState();
    _checkPluginStatus();
  }

  Future<void> _checkPluginStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final status = await RevolutSdkBridge().getPluginStatus();
      setState(() {
        _pluginStatus = status;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _pluginStatus = {'error': e.toString()};
        _isLoading = false;
      });
    }
  }

  Future<void> _setupEventChannel() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await RevolutSdkBridge().setupEventChannel();
      setState(() {
        _pluginStatus['eventChannelSetupResult'] = result;
        _isLoading = false;
      });

      // Refresh status
      await _checkPluginStatus();
    } catch (e) {
      setState(() {
        _pluginStatus['eventChannelSetupError'] = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _waitForEventChannel() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await RevolutSdkBridge().waitForEventChannel();
      setState(() {
        _pluginStatus['eventChannelWaitResult'] = result;
        _isLoading = false;
      });

      // Refresh status
      await _checkPluginStatus();
    } catch (e) {
      setState(() {
        _pluginStatus['eventChannelWaitError'] = e.toString();
        _isLoading = false;
      });
    }
  }
}

