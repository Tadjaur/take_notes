import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'services/database/database.dart';
import 'services/google_drive/google_drive.dart';
import 'widgets/note_view/note_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main(List<String>? args) async {
  if (!kIsWeb && GetPlatform.isDesktop) {
    throw Exception(
        'Unsupported Platform: Use main_desktop.dart for desktop application');
  }
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final driveService = GoogleDriveService();
  Get.put(driveService);
  Get.put(Database(driveService));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Take Note',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: NoteView(),
    );
  }
}
