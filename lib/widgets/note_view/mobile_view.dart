import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:take_notes/widgets/note_view/delete_button_icon.dart';
import 'package:take_notes/widgets/note_view/random_paint.dart';
import 'package:take_notes/widgets/note_view/title.dart';

import '../../services/database/database.dart';

class MobileView extends GetView<Database> {
  MobileView({required this.child, super.key});
  final Widget child;
  final appBar = Rx<AppBar?>(null);

  @override
  Widget build(BuildContext context) {
    final color = controller.currentNote.color;
    return Scaffold(
      backgroundColor: color,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            elevation: 4,
            backgroundColor: Color.lerp(color, Colors.white, .3),
            pinned: true,
            snap: false,
            floating: false,
            expandedHeight: 300.0,
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
                      color: hover.value
                          ? Colors.grey.shade50
                          : Colors.transparent,
                      child: SizedBox(
                        width: 32,
                        child: PopupMenuButton(
                          offset: Offset(32, 30),
                          elevation: 2,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero),
                          color: Color.lerp(color, Colors.black, 0.5),
                          itemBuilder: (context) => <PopupMenuEntry>[
                            PopupMenuItem(
                              padding: EdgeInsets.only(left: 5),
                              enabled: true,
                              height: 32,
                              onTap: controller.createNote,
                              child: Row(
                                children: [
                                  Padding(
                                    padding:
                                        EdgeInsets.only(right: 3.0, top: 2),
                                    child: Center(
                                      child: Icon(
                                        Icons.add,
                                        color: color,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'New Note',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: color),
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
                                      padding:
                                          EdgeInsets.only(right: 3.0, top: 2),
                                      child: Center(
                                        child: Icon(
                                          Icons.edit_note_rounded,
                                          color: color,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      note.title.value,
                                      maxLines: 1,
                                      overflow: TextOverflow.fade,
                                      textAlign: TextAlign.center,
                                      style:
                                          TextStyle(fontSize: 12, color: color),
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
            flexibleSpace: FlexibleSpaceBar(
              title: NoteTitle(),
            ),
          ),
          SliverFillRemaining(child: child),
        ],
      ),
      // appBar: AppBar(
      //   elevation: 4,
      //   backgroundColor: color,
      //   toolbarHeight: 32,
      //   leadingWidth: 18,
      //   title: NoteTitle(),
      //   titleSpacing: 0,
      //   // Take all available space.
      // ),
    );
  }
}
