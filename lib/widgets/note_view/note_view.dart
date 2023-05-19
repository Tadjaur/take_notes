import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'mobile_view.dart';
import '../../services/database/database.dart';
import 'body.dart';
import 'desktop_view.dart';

class NoteView extends GetView<Database> {
  const NoteView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final child = WindowBorder(
          color: Color.lerp(controller.currentNote.color, Colors.black, 0.25) ??
              controller.currentNote.color,
          width: 2,
          child: const BodyView());
      return GetPlatform.isMobile
          ? MobileView(child: child)
          : DesktopView(child: child);
    });
  }
}
