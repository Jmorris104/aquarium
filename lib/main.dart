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

class _AquariumScreenState extends State<AquariumScreen> {
  List<Fish> fishList = [];
  double fishSpeed = 2.0;
  Color fishColor = Colors.blue;

  void addFish() {
    setState(() {
      fishList.add(Fish(color: fishColor, speed: fishSpeed));
    });
  }

  void saveSettings() {
    // Here you can add logic to save fish count, speed, and color to local storage.
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
                      onPressed: addFish,
                      child: Text("Add Fish"),
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
  final double initialPositionX;
  final double initialPositionY;

  Fish({required this.color, required this.speed})
      : initialPositionX = Random().nextDouble() * 300,
        initialPositionY = Random().nextDouble() * 300;

  Widget buildFish() {
    return Positioned(
      left: initialPositionX,
      top: initialPositionY,
      child: AnimatedContainer(
        duration: Duration(milliseconds: (1000 ~/ speed).toInt()),
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
