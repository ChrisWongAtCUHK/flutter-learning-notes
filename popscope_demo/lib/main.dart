import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PopScope Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Screen')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DetailsScreen()),
            );
          },
          child: const Text('Go to Details Screen'),
        ),
      ),
    );
  }
}

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  // Track whether there are unsaved changes
  bool _hasUnsavedChanges = true;

  // Function to show a confirmation dialog
  Future<bool> _showExitConfirmationDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Changes?'),
        content: const Text(
          'You have unsaved changes. Are you sure you want to leave this page?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Don't exit
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // Confirm exit
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // If there are unsaved changes, prevent automatic popping (canPop: false)
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) async {
        // If the route already popped successfully, do nothing
        if (didPop) return;

        // Since canPop was false, we manually handle the exit decision
        final shouldExit = await _showExitConfirmationDialog();

        if (shouldExit && context.mounted) {
          // Update state to allow popping, then pop the route manually
          setState(() {
            _hasUnsavedChanges = false;
          });
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Details Screen')),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _hasUnsavedChanges
                    ? Icons.warning_amber_rounded
                    : Icons.check_circle,
                size: 80,
                color: _hasUnsavedChanges ? Colors.orange : Colors.green,
              ),
              const SizedBox(height: 20),
              Text(
                _hasUnsavedChanges
                    ? 'You have unsaved modifications!'
                    : 'All changes saved successfully.',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _hasUnsavedChanges = !_hasUnsavedChanges;
                  });
                },
                child: Text(
                  _hasUnsavedChanges
                      ? 'Simulate Saving Changes'
                      : 'Simulate Editing',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
