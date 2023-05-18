import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:take_notes/services/google_drive.dart';
import 'services/database/database.dart';
import 'widgets/note_view/note_view.dart';

void main(List<String>? args) async {
  print('Main call with $args');
  WidgetsFlutterBinding.ensureInitialized();
  final driveService = GoogleDriveService();
  Get.put(driveService);
  Get.put(Database(driveService));
  runApp(const MyApp());
  doWhenWindowReady(() {
    appWindow.minSize = Size(200, 250);
    appWindow.size = Size(350, 420);
    appWindow.title = 'Note';
    appWindow.alignment = Alignment.center;
    appWindow.show();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: NoteView(),
    );
  }
}
