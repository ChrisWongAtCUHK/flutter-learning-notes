import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Gravity Simulation',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const GravitySimScreen(),
    );
  }
}

class GravitySimScreen extends StatefulWidget {
  const GravitySimScreen({super.key});

  @override
  State<GravitySimScreen> createState() => _GravitySimScreenState();
}

class _GravitySimScreenState extends State<GravitySimScreen>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;

  // Arena Dimensions
  final GlobalKey _arenaKey = GlobalKey();
  double _arenaWidth = 300.0;
  double _arenaHeight = 400.0;

  // Ball Physics State
  double _posX = 150.0;
  double _posY = 50.0;
  double _velocityX = 0.0;
  double _velocityY = 0.0;

  // Simulation Parameters (Adjustable)
  double _gravity = 980.0; // Pixels per second squared (~9.8 m/s²)
  double _bounciness = 0.75; // Restitution factor (0.0 to 1.0)
  double _ballRadius = 20.0;

  // Time tracking
  Duration _lastFrameTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    // Ticker fires on every screen refresh frame
    _ticker = createTicker(_onFrame)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onFrame(Duration elapsed) {
    if (_lastFrameTime == Duration.zero) {
      _lastFrameTime = elapsed;
      return;
    }

    // Delta time in seconds
    double dt = (elapsed - _lastFrameTime).inMicroseconds / 1000000.0;
    _lastFrameTime = elapsed;

    // Limit dt to prevent huge jumps on lag spikes
    if (dt > 0.05) dt = 0.05;

    _updatePhysics(dt);
  }

  void _updatePhysics(double dt) {
    setState(() {
      // 1. Apply Gravity Acceleration: v = v + a * dt
      _velocityY += _gravity * dt;

      // 2. Update Position: p = p + v * dt
      _posX += _velocityX * dt;
      _posY += _velocityY * dt;

      // 3. Collision with Floor
      double maxY = _arenaHeight - _ballRadius;
      if (_posY >= maxY) {
        _posY = maxY;
        _velocityY = -_velocityY * _bounciness; // Reverse & lose energy

        // Stop micro-bouncing when energy is near zero
        if (_velocityY.abs() < 20.0) {
          _velocityY = 0;
        }
      }

      // 4. Collision with Walls (Left / Right)
      double minX = _ballRadius;
      double maxX = _arenaWidth - _ballRadius;
      if (_posX <= minX) {
        _posX = minX;
        _velocityX = -_velocityX * _bounciness;
      } else if (_posX >= maxX) {
        _posX = maxX;
        _velocityX = -_velocityX * _bounciness;
      }
    });
  }

  void _resetBall(Offset targetPos) {
    setState(() {
      // Keep ball within arena boundaries
      _posX = targetPos.dx.clamp(_ballRadius, _arenaWidth - _ballRadius);
      _posY = targetPos.dy.clamp(_ballRadius, _arenaHeight - _ballRadius);
      // Random velocity between -300 and +300 px/sec
      _velocityX = (Random().nextDouble() - 0.5) * 600;
      _velocityY = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gravity Simulation'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Physics Arena Area
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                _arenaWidth = constraints.maxWidth;
                _arenaHeight = constraints.maxHeight;

                return GestureDetector(
                  key: _arenaKey,
                  onTapDown: (details) => _resetBall(details.localPosition),
                  child: Container(
                    color: Colors.grey[900],
                    child: Stack(
                      children: [
                        // Tap prompt helper
                        const Center(
                          child: Text(
                            'Tap anywhere to drop the ball',
                            style: TextStyle(
                              color: Colors.white24,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        // Simulated Ball
                        Positioned(
                          left: _posX - _ballRadius,
                          top: _posY - _ballRadius,
                          child: Container(
                            width: _ballRadius * 2,
                            height: _ballRadius * 2,
                            decoration: BoxDecoration(
                              color: Colors.cyanAccent,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.cyanAccent.withAlpha(
                                    (0.4 * 255).round(),
                                  ),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Control Panel Sliders
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 12.0,
            ),
            color: Colors.black45,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSlider(
                  label: 'Gravity',
                  value: _gravity,
                  min: 0,
                  max: 2500,
                  unit: 'px/s²',
                  onChanged: (val) => setState(() => _gravity = val),
                ),
                _buildSlider(
                  label: 'Bounciness',
                  value: _bounciness,
                  min: 0.1,
                  max: 0.95,
                  unit: '',
                  onChanged: (val) => setState(() => _bounciness = val),
                ),
                _buildSlider(
                  label: 'Ball Size',
                  value: _ballRadius,
                  min: 10,
                  max: 50,
                  unit: 'px',
                  onChanged: (val) => setState(() => _ballRadius = val),
                ),
                ElevatedButton.icon(
                  onPressed: () => _resetBall(Offset(_arenaWidth / 2, 50)),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset Ball'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required String unit,
    required ValueChanged<double> onChanged,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Slider(value: value, min: min, max: max, onChanged: onChanged),
        ),
        SizedBox(
          width: 60,
          child: Text(
            '${value.toStringAsFixed(1)} $unit',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
