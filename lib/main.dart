import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'dart:math';
import 'database_helper.dart';
import 'graphic.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.init();
  runApp(MyAquariumApp());
}

class MyAquariumApp extends StatelessWidget {
  const MyAquariumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AquariumScreen(),
    );
  }
}

// Database Helper for SQLite
class DatabaseHelper {
  static Database? _database;

  static Future<void> init() async {
    _database = await openDatabase(
      p.join(await getDatabasesPath(), 'aquarium.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE settings(id INTEGER PRIMARY KEY, fishCount INTEGER, fishSpeed REAL, fishColor INTEGER)',
        );
      },
      version: 1,
    );
  }

  static Future<void> saveSettings(int fishCount, double fishSpeed, int fishColor) async {
    await _database?.insert(
      'settings',
      {'id': 1, 'fishCount': fishCount, 'fishSpeed': fishSpeed, 'fishColor': fishColor},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<Map<String, dynamic>?> loadSettings() async {
    final List<Map<String, dynamic>> maps = await _database?.query('settings', where: 'id = ?', whereArgs: [1]) ?? [];
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
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

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await DatabaseHelper.loadSettings();
    if (settings != null) {
      setState(() {
        fishSpeed = settings['fishSpeed'];
        fishColor = Color(settings['fishColor']);
        for (int i = 0; i < settings['fishCount']; i++) {
          _addFish();
        }
      });
    }
  }

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

  Future<void> saveSettings() async {
    await DatabaseHelper.saveSettings(fishList.length, fishSpeed, fishColor.value);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Settings saved!")));
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
        title: const Text("Aquarium Simulator"),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
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
          const SizedBox(height: 20),
          // Control Panel
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text("Fish Speed"),
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
                    const Text("Fish Color"),
                    const SizedBox(width: 10),
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
                      child: const Text("Add Fish"),
                    ),
                    ElevatedButton(
                      onPressed: _removeFish,
                      child: const Text("Remove Fish"),
                    ),
                    ElevatedButton(
                      onPressed: saveSettings,
                      child: const Text("Save Settings"),
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
          duration: const Duration(seconds: 2),
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
