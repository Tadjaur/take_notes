import 'dart:math';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:taurs_note/services/database/database.dart';

class NoteView extends GetView<Database> {
  final focused = Rx<bool?>(null);
  final color = Rx<Color>(Colors.grey);
  final editTitleMode = false.obs;
  final titleInputController = TextEditingController();
  final titleInputNode = FocusNode();
  final titleInputScrollCtrl = ScrollController();

  NoteView({super.key}) {
    titleInputNode.addListener(() async {
      bool hasFocus = titleInputNode.hasFocus;
      if (!hasFocus &&
          focused.value == true &&
          editTitleMode.isTrue) {
        controller.currentNote.title = titleInputController.text;
        controller.currentNote.save();
        editTitleMode.value = false;
      }
      focused.value = hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      color.value = controller.currentNote.color;
      return Scaffold(
        appBar: AppBar(
          elevation: 4,
          backgroundColor: color.value,
          toolbarHeight: 32,
          leadingWidth: 18,
          leading: GestureDetector(
            onPanStart: (pan) => appWindow.startDragging(),
            child: Icon(
              Icons.drag_indicator,
              size: 15,
              color: Colors.grey.shade800,
            ),
          ),
          title: Center(
            child: GestureDetector(
              onDoubleTap: () async {
                editTitleMode.value = true;
                titleInputNode.requestFocus();
                titleInputScrollCtrl.jumpTo(titleInputScrollCtrl.offset);
              },
              child: TextField(
                focusNode: titleInputNode,
                controller: titleInputController
                  ..text = controller.currentNote.title,
                decoration: InputDecoration(
                  disabledBorder: InputBorder.none,
                  isCollapsed: true,
                  enabled: editTitleMode.isTrue,
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(width: 1, color: Colors.black),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(width: 1, color: Colors.black),
                  ),
                  constraints: const BoxConstraints.tightFor(),
                  contentPadding: const EdgeInsets.all(3),
                ),
                scrollController: titleInputScrollCtrl,
                cursorColor: Colors.blueGrey,
                onSubmitted: (edition) {
                  editTitleMode.value = false;
                  titleInputNode.unfocus();
                  controller.currentNote.title = edition;
                  controller.currentNote.save();
                  titleInputScrollCtrl.jumpTo(0);
                },
                readOnly: editTitleMode.isFalse,
                maxLines: 1,
                style: TextStyle(color: Colors.grey.shade800, fontSize: 20),
              ),
            ),
          ),
          titleSpacing: 0,
          // Take all available space.
          actions: [
            InkWell(
              onTap: () {
                const colorSet = [
                  Color(0xFFCBB3F1),
                  Color(0xFFFCF296),
                  Color(0xFFE8EAED),
                  Color(0xFFC8FAEC),
                  Color(0xFFEABE5A),
                ];
                final pos = colorSet
                    .indexWhere((clr) => clr.value == color.value.value);

                controller.currentNote.colorValue =
                    colorSet
                        .elementAt((pos + 1) % colorSet.length)
                        .value;
                controller.currentNote.save();
                color.value = controller.currentNote.color;
              },
              hoverColor: Color.lerp(color.value, Colors.black, 0.50),
              child: SizedBox(
                width: 32,
                child: Center(
                  child: Icon(
                    Icons.color_lens_outlined,
                    color: Colors.grey.shade800,
                    size: 18,
                  ),
                ),
              ),
            ),
            MinimizeWindowButton(),
            PopupMenuButton(
              offset: Offset(32, 30),
              elevation: 2,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              color: Color.lerp(color.value, Colors.black, 0.5),
              itemBuilder: (context) =>
              <PopupMenuEntry>[
                PopupMenuItem(
                  padding: EdgeInsets.only(left: 5),
                  enabled: true,
                  height: 32,
                  onTap: () {},
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 3.0, top: 2),
                        child: Center(
                          child: Icon(
                            Icons.add,
                            color: color.value,
                            size: 20,
                          ),
                        ),
                      ),
                      Text(
                        'New Note',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: color.value),
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                ...controller.otherNotes.map(
                      (note) =>
                      PopupMenuItem(
                        padding: const EdgeInsets.only(left: 5),
                        enabled: true,
                        height: 32,
                        onTap: () => controller.currentNoteRx.value = note,
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(right: 3.0, top: 2),
                              child: Center(
                                child: Icon(
                                  Icons.edit_note_rounded,
                                  color: color.value,
                                  size: 20,
                                ),
                              ),
                            ),
                            Text(
                              note.title,
                              maxLines: 1,
                              overflow: TextOverflow.fade,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 12, color: color.value),
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
          ],
        ),
        body: WindowBorder(
            color: Color.lerp(color.value, Colors.black, 0.25) ?? color.value,
            width: 2,
            child: BodyView(note: controller.currentNote)),
      );
    });
  }
}

class BodyView extends StatelessWidget {
  final textInputController = TextEditingController();
  final textInputNode = FocusNode();
  final Note note;

  BodyView({required this.note, super.key}) {
    textInputController.text = note.notes;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => textInputNode.requestFocus(),
      // Get focus the text controller.
      child: ColoredBox(
        color: note.color,
        child: SizedBox.expand(
          child: TextField(
            focusNode: textInputNode,
            controller: textInputController,
            onChanged: (input) {
              note.notes = input;
              note.save();
            },
            maxLines: null,
            style: TextStyle(
              fontSize: 19,
              fontFamily: 'roboto',
              color: Colors.grey.shade800,
            ),
            cursorColor: Color.lerp(note.color, Colors.black, 0.25),
            cursorWidth: 3,
            decoration: const InputDecoration(
              contentPadding:
              EdgeInsets.only(top: 15, bottom: 15, left: 8, right: 0),
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }
}
