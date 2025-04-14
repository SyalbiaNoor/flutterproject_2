# Habit Tracker V2

This app is a simple habit tracker flutter project. Previously, this was a standalone flutter app that only used in-memory storage to manage habits and is now modified
to integrate isar, a high-performance database for persistent data storage.

## Modifications

### Before:
- Habits were stored in a `List<Habit>` in-memory array, which meant data would lost whenever the app was closed.
- Added basic functionalities:
  - Toggle habit completion.
  - Add, edit, and delete habits.
  - Display current date and time.

### After:
- Added Dependencies
  - Updated the `pubspec.yaml` to include the `isar` and the `isar_flutter_libs` by running the following commands taken from the Isar Database official website:
    ```
    flutter pub add isar isar_flutter_libs path_provider
    flutter pub add -d isar_generator build_runner
    ```
    
- Initialized Isar
  - Created a `initializeIsar` function to set up database:
    ```
    late isar isar;

    future<void> initializeisar() async {
      final dir = await getapplicationdocumentsdirectory();
      isar = await isar.open([habitschema], directory: dir.path);
    }
    ```
  - Used `futurebuilder` to ensure the database was fully initialized before displaying the app.

- Restructured Habit Data
  - Updated the `habit` xlass to be compatible with isar by creating a new model:
    ```
    import 'package:isar/isar.dart';

    part 'habit_model.g.dart';

    @collection()
    class habit {
      id id = isar.autoincrement;
      late string name;
      late bool iscompleted;
      late int hour;
      late int minute;
    }
    ```
  - Habits now use isar collections for data management.

- Database Operations
  - Added methods to perform CRUD operations with isar:
    - `addhabit` writes new habits to the database.
    - `edithabitname` updates habit names directly in the database.
    - `deletehabit` removes habits from the database.
    - `loadhabits` retrieces all habits when the app starts.
   
## Problems Faced and Solution Attempts

### Problems

The following pictures are the screenshot of the most current errors faced during the app modification:

![image](https://github.com/user-attachments/assets/82b8bf03-667f-4195-8fc0-ef50e084ce8b)

![image](https://github.com/user-attachments/assets/86738abb-6bb7-451a-b32c-80ef6d39f3c4)

### Solution Attempts

I have tried several solutions offered by various platforms, teaching assistant, as well as ChatGPT such as:
- Rebuilding the project multiple times by running:
  ```
  flutter clean
  flutter pub get
  flutter run
  ```
- Adding `namespace 'dev.isar.flutter'` into build.gradle from the AppData directory
- Clearing flutter's pub cache using `flutter pub cache repair`
- Checking my `isar_flutter_libs` in the `pubspec.yaml` to see if it has the latest version, and it does
- Checking my `AndroidManifest.xml` and removed the `packange="dev.isar.isar_flutter_libs"` part of the script
- Updating dependencies with using `flutter pub upgrade --major-versions`
- Reinstalling isar by running:
  ```
  flutter pub remove isar_flutter_libs
  flutter pub add isar_flutter_libs
  ```
- Turned developer mode on

Those are the lists of my fixing attempts on my system's error. However, after attempting those attempts, I still seem to face some errors in the system.
For now, I'm still unable to fix it and I will try my best to fix the problems immediately.

------

_This project was made with the help of ChatGPT and Youtube resources_
