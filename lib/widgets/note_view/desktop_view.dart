import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:take_notes/widgets/note_view/delete_button_icon.dart';
import 'package:take_notes/widgets/note_view/random_paint.dart';
import 'package:take_notes/widgets/note_view/title.dart';

import '../../services/database/database.dart';
import 'google_sync_status_icon.dart';

class DesktopView extends GetView<Database> {
  final Widget child;
  const DesktopView({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: child,
        appBar: AppBar(
          elevation: 4,
          backgroundColor: controller.currentNote.color,
          toolbarHeight: 32,
          leadingWidth: 47,
          // automaticallyImplyLeading: false,
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onPanStart: (pan) {
                  print('pan started');
                  appWindow.startDragging();
                },
                child: SizedBox(
                  height: 32,
                  child: Icon(
                    Icons.drag_indicator,
                    size: 15,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              // Builder is required for the widget insde to get internal context.
              Builder(builder: (context) {
                return IconTheme(
                    data: IconThemeData(color: controller.currentNote.color),
                    child: GoogleSyncStatusIcon());
              }),
            ],
          ),
          title: NoteTitle(),
          titleSpacing: 0,
          // Take all available space.
          actions: [
            DeleteButtonIcon(),
            RandomPaint(),
            Builder(builder: (context) {
              final hover = false.obs;
              return Obx(
                () => MouseRegion(
                  onExit: (d) {
                    hover.value = false;
                  },
                  onEnter: (value) {
                    hover.value = true;
                  },
                  child: ColoredBox(
                    color:
                        hover.value ? Colors.grey.shade50 : Colors.transparent,
                    child: SizedBox(
                      width: 32,
                      child: PopupMenuButton(
                        offset: const Offset(32, 30),
                        elevation: 2,
                        padding: EdgeInsets.zero,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero),
                        color: Color.lerp(
                            controller.currentNote.color, Colors.black, 0.5),
                        itemBuilder: (context) => <PopupMenuEntry>[
                          PopupMenuItem(
                            padding: const EdgeInsets.only(left: 5),
                            enabled: true,
                            height: 32,
                            onTap: controller.createNote,
                            child: Row(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.only(right: 3.0, top: 2),
                                  child: Center(
                                    child: Icon(
                                      Icons.add,
                                      color: controller.currentNote.color,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                Text(
                                  'New Note',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: controller.currentNote.color),
                                ),
                              ],
                            ),
                          ),
                          const PopupMenuDivider(),
                          ...controller.otherNotes.map(
                            (note) => PopupMenuItem(
                              padding: const EdgeInsets.only(left: 5),
                              enabled: true,
                              height: 32,
                              onTap: () =>
                                  controller.currentNoteRx.value = note,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        right: 3.0, top: 2),
                                    child: Center(
                                      child: Icon(
                                        Icons.edit_note_rounded,
                                        color: controller.currentNote.color,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    note.title.value,
                                    maxLines: 1,
                                    overflow: TextOverflow.fade,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: controller.currentNote.color),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        child: Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Colors.grey.shade800,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ));
  }
}
