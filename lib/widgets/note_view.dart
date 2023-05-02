import 'dart:math';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taurs_note/services/database/database.dart';

class NoteView extends GetView<Database> {
  NoteView({super.key});

  final currentColor = Rx<Color>(Colors.grey);
  final lastNote = Rx<Note?>(null);

  Future<Note> init() async {
    final note = await controller.getLastOpenedNote();
    lastNote.value = note;
    currentColor.value = note.color;
    return note;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Note>(
        future: init(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final note = snapshot.data;
          if (note == null) {
            assert(false); // Should never inter in this case
            return ErrorWidget('Null note retrieved after load.');
          }
          return Obx(
            () => Scaffold(
              appBar: AppBar(
                elevation: 4,
                backgroundColor: currentColor.value,
                toolbarHeight: 32,
                title: WindowTitleBarBox(
                  child: MoveWindow(
                    child: SizedBox.expand(
                      child: Center(
                        child: Title(
                          title: 'Untitled',
                          color: currentColor.value,
                          child: Text(
                            'Untitled',
                            style: TextStyle(color: Colors.grey.shade800),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                titleSpacing: 0,
                // Take all available space.
                actions: [
                  InkWell(
                    onTap: () {
                      currentColor.value = [
                        Color(0xFFCBB3F1),
                        Color(0xFFFCF296),
                        Color(0xFFE8EAED),
                        Color(0xFFC8FAEC),
                        Color(0xFFCEABE5A),
                      ].elementAt(Random().nextInt(4));
                      lastNote.value?.colorValue = currentColor.value.value;
                      lastNote.value?.save();
                    },
                    child: Icon(
                      Icons.color_lens_outlined,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  MinimizeWindowButton(),
                  MaximizeWindowButton(),
                  CloseWindowButton(),
                ],
              ),
              body: WindowBorder(
                  color: Color.lerp(currentColor.value, Colors.black, 0.25) ??
                      currentColor.value,
                  width: 3,
                  child: BodyView(
                    note: note,
                    color: currentColor.value,
                  )),
            ),
          );
        });
  }
}

class BodyView extends StatelessWidget {
  final textInputController = TextEditingController();
  final textInputNode = FocusNode();
  final Color? color;
  final Note note;

  BodyView({required this.note, this.color, super.key}) {
    textInputController.text = note.notes;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => textInputNode.requestFocus(),
      // Get focus the text controller.
      child: ColoredBox(
        color: color ?? Colors.grey.shade50,
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
            cursorColor: Color.lerp(color, Colors.black, 0.25),
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
