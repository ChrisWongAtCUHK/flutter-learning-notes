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
      home: const GestureDetectorDemo(),
    );
  }
}

class GestureDetectorDemo extends StatefulWidget {
  const GestureDetectorDemo({super.key});

  @override
  State<GestureDetectorDemo> createState() => _GestureDetectorDemoState();
}

class _GestureDetectorDemoState extends State<GestureDetectorDemo> {
  String _statusMessage = 'Interact with the card!';
  Color _cardColor = Colors.indigo;
  double _scale = 1.0;

  // Dragging coordinates
  Offset _cardOffset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GestureDetector Demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _statusMessage,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),

            // Transform allows us to visually translate (drag) and scale the box
            Transform.translate(
              offset: _cardOffset,
              child: Transform.scale(
                scale: _scale,
                child: GestureDetector(
                  // 1. Single Tap
                  onTap: () {
                    setState(() {
                      _statusMessage = 'Single Tapped!';
                      _cardColor = Colors.indigo;
                    });
                  },

                  // 2. Double Tap
                  onDoubleTap: () {
                    setState(() {
                      _statusMessage = 'Double Tapped! (Toggled Scale)';
                      _scale = _scale == 1.0 ? 1.2 : 1.0;
                    });
                  },

                  // 3. Long Press
                  onLongPress: () {
                    setState(() {
                      _statusMessage = 'Long Pressed! (Color Changed)';
                      _cardColor = Colors.teal;
                    });
                  },

                  // 4. Pan / Drag (Tracks finger movement)
                  onPanUpdate: (DragUpdateDetails details) {
                    setState(() {
                      _statusMessage = 'Dragging...';
                      // Update box position by adding movement delta
                      _cardOffset += details.delta;
                    });
                  },

                  // Reset position on drag end
                  onPanEnd: (_) {
                    setState(() {
                      _statusMessage = 'Drag Ended!';
                    });
                  },

                  // The Child Widget being wrapped
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      color: _cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 10),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'Touch Me\n(Tap / Drag)',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
