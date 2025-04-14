import 'package:flutter/material.dart';
import 'dart:async';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/habit_model.dart';

late Isar isar;

// initialize isar database
Future<void> initializeIsar() async {
  final dir = await getApplicationDocumentsDirectory();
  isar = await Isar.open([HabitSchema], directory: dir.path);
}

// main app entry point
void main() {
  runApp(HabitTrackerApp());
}

// root widget
class HabitTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: initializeIsar(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: HabitTracker(),
          );
        } else {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }
      },
    );
  }
}

// habit model
class Habit {
  String name;
  bool isCompleted;
  TimeOfDay time;

  Habit({required this.name, this.isCompleted = false, required this.time});
}

// main habit tracker screen
class HabitTracker extends StatefulWidget {
  @override
  _HabitTrackerState createState() => _HabitTrackerState();
}

class _HabitTrackerState extends State<HabitTracker> {
  List<Habit> habits = [
    Habit(name: "Clean room", time: TimeOfDay(hour: 8, minute: 0)),
    Habit(name: "Exercise", time: TimeOfDay(hour: 16, minute: 0)),
    Habit(name: "Skincare routine", time: TimeOfDay(hour: 21, minute: 30)),
  ];

  String currentDate = '';
  String currentTime = '';
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _updateTime();
  }

  @override
  void dispose() {
    timer?.cancel(); // clean up timer to prevent memory leaks
    super.dispose();
  }

  void _updateTime() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      setState(() {
        currentDate =
            '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';
        currentTime =
            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
      });
    });
  }

  void toggleCompletion(int index) {
    setState(() {
      habits[index].isCompleted = !habits[index].isCompleted;
    });
  }

  void addHabit(String habitName, TimeOfDay habitTime) {
    setState(() {
      habits.add(Habit(name: habitName, time: habitTime));
    });
  }

  void deleteHabit(int index) {
    setState(() {
      habits.removeAt(index);
    });
  }

  void editHabitName(int index) {
    String updatedName = habits[index].name;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Routine'),
          content: TextField(
            onChanged: (value) {
              updatedName = value;
            },
            controller: TextEditingController(text: habits[index].name),
            decoration: InputDecoration(hintText: 'Enter new routine'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  habits[index].name = updatedName;
                });
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void showAddHabitDialog() {
    String newHabitName = '';
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Routine'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  newHabitName = value;
                },
                decoration: InputDecoration(hintText: 'Enter your routine'),
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () async {
                  TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      selectedTime = picked;
                    });
                  }
                },
                child: Text('Set Time'),
              ),
              Text(
                'Selected Time: ${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (newHabitName.isNotEmpty) {
                  addHabit(newHabitName, selectedTime);
                }
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  bool isHabitLate(Habit habit) {
    final now = TimeOfDay.now();
    if (!habit.isCompleted &&
        (habit.time.hour < now.hour ||
            (habit.time.hour == now.hour && habit.time.minute < now.minute))) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Habit Tracker'),
        backgroundColor: const Color.fromARGB(255, 231, 210, 204),
        centerTitle: true,
      ),
      backgroundColor: Color.fromRGBO(238, 237, 231, 1),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  currentDate,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 83, 85, 87),
                  ),
                ),
                Text(
                  currentTime,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 83, 85, 87),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: habits.length,
              itemBuilder: (context, index) {
                return HabitCard(
                  habit: habits[index],
                  toggleCompletion: () => toggleCompletion(index),
                  deleteHabit: () => deleteHabit(index),
                  editHabitName: () => editHabitName(index),
                  isLate: isHabitLate(habits[index]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddHabitDialog,
        child: Icon(Icons.add),
        backgroundColor: Color.fromARGB(255, 231, 210, 204),
      ),
    );
  }
}

// widget for habit card
class HabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback toggleCompletion;
  final VoidCallback deleteHabit;
  final VoidCallback editHabitName;
  final bool isLate;

  HabitCard({
    required this.habit,
    required this.toggleCompletion,
    required this.deleteHabit,
    required this.editHabitName,
    required this.isLate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color.fromRGBO(185, 183, 189, 1),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              habit.name,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 83, 85, 87),
              ),
            ),
            Text(
              'Time: ${habit.time.hour.toString().padLeft(2, '0')}:${habit.time.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 16,
                color: Color.fromARGB(255, 83, 85, 87),
              ),
            ),
            if (isLate)
              Text(
                '⚠️ Action skipped!',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Color.fromARGB(255, 100, 149, 237)),
              onPressed: editHabitName,
            ),
            Checkbox(
              value: habit.isCompleted,
              onChanged: (value) {
                toggleCompletion();
              },
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: deleteHabit,
            ),
          ],
        ),
      ),
    );
  }
}
