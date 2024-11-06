import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(MyAquariumApp());
}

class MyAquariumApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AquariumScreen(),
    );
  }
}

class AquariumScreen extends StatefulWidget {
  @override
  _AquariumScreenState createState() => _AquariumScreenState();
}

class _AquariumScreenState extends State<AquariumScreen> with TickerProviderStateMixin {
  List<Fish> fishList = [];
  double fishSpeed = 2.0;
  Color fishColor = Colors.blue;

  void _addFish() {
    if (fishList.length < 10) { // Limit to 10 fish
      setState(() {
        fishList.add(Fish(color: fishColor, speed: fishSpeed, vsync: this));
      });
    }
  }

  void _removeFish() {
    if (fishList.isNotEmpty) {
      setState(() {
        fishList.last.dispose(); // Dispose controller to avoid memory leaks
        fishList.removeLast();
      });
    }
  }

  void saveSettings() {
    // Save settings (e.g., fish count, speed, color) to local storage here
  }

  @override
  void dispose() {
    for (var fish in fishList) {
      fish.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Aquarium Simulator"),
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          // Aquarium Container
          Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              color: Colors.lightBlue[100],
              border: Border.all(color: Colors.blueAccent, width: 2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Stack(
              children: fishList.map((fish) => fish.buildFish()).toList(),
            ),
          ),
          SizedBox(height: 20),
          // Control Panel
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Text("Fish Speed"),
                    Expanded(
                      child: Slider(
                        value: fishSpeed,
                        min: 1.0,
                        max: 5.0,
                        divisions: 4,
                        label: fishSpeed.toString(),
                        onChanged: (newSpeed) {
                          setState(() {
                            fishSpeed = newSpeed;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text("Fish Color"),
                    SizedBox(width: 10),
                    DropdownButton<Color>(
                      value: fishColor,
                      items: [
                        Colors.blue,
                        Colors.red,
                        Colors.green,
                        Colors.yellow,
                        Colors.purple,
                      ].map((color) {
                        return DropdownMenuItem(
                          value: color,
                          child: Container(
                            width: 24,
                            height: 24,
                            color: color,
                          ),
                        );
                      }).toList(),
                      onChanged: (newColor) {
                        setState(() {
                          fishColor = newColor!;
                        });
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _addFish,
                      child: Text("Add Fish"),
                    ),
                    ElevatedButton(
                      onPressed: _removeFish,
                      child: Text("Remove Fish"),
                    ),
                    ElevatedButton(
                      onPressed: saveSettings,
                      child: Text("Save Settings"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Fish {
  final Color color;
  final double speed;
  final AnimationController controller;
  final Random random = Random();
  double xPosition, yPosition;
  double xDirection, yDirection;

  Fish({required this.color, required this.speed, required TickerProvider vsync})
      : controller = AnimationController(
          duration: Duration(seconds: 2),
          vsync: vsync,
        ),
        xPosition = Random().nextDouble() * 280,
        yPosition = Random().nextDouble() * 280,
        xDirection = (Random().nextBool() ? 1 : -1) * Random().nextDouble(),
        yDirection = (Random().nextBool() ? 1 : -1) * Random().nextDouble() {
    controller.repeat();
    controller.addListener(() {
      xPosition += xDirection * speed;
      yPosition += yDirection * speed;

      // Check for boundary collisions
      if (xPosition <= 0 || xPosition >= 280) {
        xDirection *= -1;
      }
      if (yPosition <= 0 || yPosition >= 280) {
        yDirection *= -1;
      }
    });
  }

  Widget buildFish() {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Positioned(
          left: xPosition,
          top: yPosition,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  void dispose() {
    controller.dispose();
  }
}
