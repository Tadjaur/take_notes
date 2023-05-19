import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';

import '../../services/database/database.dart';

class BodyView extends GetView<Database> {
  // final textInputNode = FocusNode();

  const BodyView({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // onTap: () => textInputNode.requestFocus(),
      // Get focus the text controller.
      child: Obx(
        () => ColoredBox(
          color: controller.currentNote.color,
          child: SizedBox.expand(
            child: TextField(
              // focusNode: textInputNode,
              controller: controller.textInputController,
              onChanged: (input) {
                controller.currentNote.notes.value = input;
                controller.currentNote.save();
              },
              maxLines: null,
              style: TextStyle(
                fontSize: 19,
                fontFamily: 'roboto',
                color: Colors.grey.shade800,
              ),
              cursorColor:
                  Color.lerp(controller.currentNote.color, Colors.black, 0.25),
              cursorWidth: 3,
              decoration: const InputDecoration(
                contentPadding:
                    EdgeInsets.only(top: 15, bottom: 15, left: 8, right: 0),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
