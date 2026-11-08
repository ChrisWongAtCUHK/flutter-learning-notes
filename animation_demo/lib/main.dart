import 'package:flutter/material.dart';

import 'dart:math' as math;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AnimationController Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AnimationDemoPage(),
    );
  }
}

class AnimationDemoPage extends StatefulWidget {
  const AnimationDemoPage({super.key});

  @override
  State<AnimationDemoPage> createState() => _AnimationDemoPageState();
}

// 1. Add TickerProviderStateMixin to handle screen refresh sync (vsync)
class _AnimationDemoPageState extends State<AnimationDemoPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Define animations driven by the controller
  late Animation<double> _sizeAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();

    // 2. Initialize the AnimationController
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // 3. Map controller's 0.0 -> 1.0 range to desired UI values using Tweens
    _sizeAnimation = Tween<double>(begin: 100.0, end: 250.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut, // Smooth easing curve
      ),
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _colorAnimation = ColorTween(
      begin: Colors.blue,
      end: Colors.orange,
    ).animate(_controller);

    // Optional: Listen to value changes if you need to run imperative logic
    _controller.addListener(() {
      // setState(() {}); // Not strictly required when using AnimatedBuilder
    });
  }

  @override
  void dispose() {
    // 4. Always dispose of the controller to prevent memory leaks
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AnimationController Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 5. Use AnimatedBuilder to rebuild only the animated widget efficiently
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationAnimation.value,
                  child: Container(
                    width: _sizeAnimation.value,
                    height: _sizeAnimation.value,
                    decoration: BoxDecoration(
                      color: _colorAnimation.value,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'Flutter',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 50),
            // Control Buttons
            Wrap(
              spacing: 10,
              children: [
                ElevatedButton(
                  onPressed: () => _controller.forward(),
                  child: const Text('Forward'),
                ),
                ElevatedButton(
                  onPressed: () => _controller.reverse(),
                  child: const Text('Reverse'),
                ),
                ElevatedButton(
                  onPressed: () => _controller.stop(),
                  child: const Text('Stop'),
                ),
                ElevatedButton(
                  onPressed: () => _controller.repeat(reverse: true),
                  child: const Text('Repeat'),
                ),
                ElevatedButton(
                  onPressed: () => _controller.reset(),
                  child: const Text('Reset'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
