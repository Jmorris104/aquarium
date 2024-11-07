import 'package:flutter/material.dart';

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
  double fishSpeed = 2.0; // Default fish speed
  Color selectedColor = Colors.blue; // Default fish color
  int fishCount = 0; // Default fish count
  
  void _addFish() {
    if (fishCount < 10) {
      setState(() {
        fishCount += 1;
      });
    }
  }

  void _saveSettings() {
    // Save settings to local storage (implementation required)
    print("Settings saved! Fish count: $fishCount, Speed: $fishSpeed, Color: $selectedColor");
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
              children: List.generate(fishCount, (index) {
                // Placeholder for fish widget (like a colored circle)
                return Positioned(
                  left: (index * 30) % 280.0, // Example positions
                  top: (index * 40) % 280.0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: selectedColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }),
            ),
          ),
          SizedBox(height: 20),
          
          // Control Panel
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                // Fish Speed Slider
                Row(
                  children: [
                    Text("Fish Speed:"),
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
                
                // Fish Color Dropdown
                Row(
                  children: [
                    Text("Fish Color:"),
                    SizedBox(width: 10),
                    DropdownButton<Color>(
                      value: selectedColor,
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
                          selectedColor = newColor!;
                        });
                      },
                    ),
                  ],
                ),
                
                // Add Fish & Save Settings Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _addFish,
                      child: Text("Add Fish"),
                    ),
                    ElevatedButton(
                      onPressed: _saveSettings,
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
