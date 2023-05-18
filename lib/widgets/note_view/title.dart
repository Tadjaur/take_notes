import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../services/database/database.dart';

class NoteTitle extends GetView<Database> {
  final focused = Rx<bool?>(null);
  final editTitleMode = false.obs;
  final titleInputController = TextEditingController();
  final titleInputNode = FocusNode();
  final titleInputScrollCtrl = ScrollController();

  NoteTitle({super.key}) {
    titleInputNode.addListener(() async {
      bool hasFocus = titleInputNode.hasFocus;
      if (!hasFocus && focused.value == true && editTitleMode.isTrue) {
        controller.currentNote.title.value = titleInputController.text;
        controller.currentNote.save();
        editTitleMode.value = false;
      }
      focused.value = hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onDoubleTap: () async {
            editTitleMode.value = true;
            titleInputNode.requestFocus();
            titleInputScrollCtrl.jumpTo(titleInputScrollCtrl.offset);
          },
          child: TextField(
            focusNode: titleInputNode,
            controller: titleInputController
              ..text = controller.currentNote.title.value,
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
              controller.currentNote.title.value = edition;
              controller.currentNote.save();
              titleInputScrollCtrl.jumpTo(0);
            },
            readOnly: editTitleMode.isFalse,
            maxLines: 1,
            style: TextStyle(color: Colors.grey.shade800, fontSize: 20),
          ),
        ),
      ),
    );
  }
}
