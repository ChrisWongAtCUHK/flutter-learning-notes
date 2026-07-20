import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
      home: const CollisionDemoScreen(),
    );
  }
}

class CollisionDemoScreen extends StatefulWidget {
  const CollisionDemoScreen({super.key});

  @override
  State<CollisionDemoScreen> createState() => _CollisionDemoScreenState();
}

class _CollisionDemoScreenState extends State<CollisionDemoScreen> {
  // Player Box Properties (Position and Dimensions)
  Offset _playerPosition = const Offset(50, 150);
  final Size _playerSize = const Size(100, 100);

  // Obstacle Box Properties (Fixed Position and Dimensions)
  final Offset _obstaclePosition = const Offset(200, 250);
  final Size _obstacleSize = const Size(120, 120);

  /// Converts position and size into Flutter's built-in [Rect] representation
  Rect _getRect(Offset position, Size size) {
    return Rect.fromLTWH(position.dx, position.dy, size.width, size.height);
  }

  /// Core AABB Collision Logic
  /// Uses Flutter's built-in [Rect.overlaps] method
  bool _checkCollision() {
    final Rect playerRect = _getRect(_playerPosition, _playerSize);
    final Rect obstacleRect = _getRect(_obstaclePosition, _obstacleSize);

    // Equivalent to:
    // playerRect.left < obstacleRect.right &&
    // playerRect.right > obstacleRect.left &&
    // playerRect.top < obstacleRect.bottom &&
    // playerRect.bottom > obstacleRect.top
    return playerRect.overlaps(obstacleRect);
  }

  @override
  Widget build(BuildContext context) {
    final bool isColliding = _checkCollision();

    return Scaffold(
      appBar: AppBar(
        title: const Text('AABB Collision Detection'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background Canvas Container
          Positioned.fill(child: Container(color: const Color(0xFF1E1E1E))),

          // 1. Fixed Obstacle Box
          Positioned(
            left: _obstaclePosition.dx,
            top: _obstaclePosition.dy,
            child: Container(
              width: _obstacleSize.width,
              height: _obstacleSize.height,
              decoration: BoxDecoration(
                color: isColliding ? Colors.blue : Colors.green,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Center(
                child: Text(
                  'Obstacle\n${_obstacleSize.width.toInt()}x${_obstacleSize.height.toInt()}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),

          // 2. Draggable Player Box
          Positioned(
            left: _playerPosition.dx,
            top: _playerPosition.dy,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  // Update player position based on drag movement
                  _playerPosition += details.delta;
                });
              },
              child: Container(
                width: _playerSize.width,
                height: _playerSize.height,
                decoration: BoxDecoration(
                  color: isColliding ? Colors.blue : Colors.redAccent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black45,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Drag Me!',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),

          // 3. UI Status Banner
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Card(
              color: isColliding
                  ? Colors.blue.withAlpha((0.9 * 255).round())
                  : Colors.grey[850],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      isColliding
                          ? Icons.warning_amber_rounded
                          : Icons.check_circle_outline,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isColliding
                                ? 'COLLISION DETECTED!'
                                : 'NO COLLISION',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Player Position: (${_playerPosition.dx.toInt()}, ${_playerPosition.dy.toInt()})',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
