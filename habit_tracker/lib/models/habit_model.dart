import 'package:isar/isar.dart';

part 'habit_model.g.dart';

@Collection()
class Habit {
  Id id = Isar.autoIncrement; // auto-generate an ID
  late String name;
  late bool isCompleted;
  late int hour; // store time as hour + minute integers
  late int minute;

  Habit({
    required this.name,
    this.isCompleted = false,
    required this.hour,
    required this.minute,
  });
}
