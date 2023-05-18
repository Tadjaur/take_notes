import 'package:flutter/material.dart';

import '../../services/database/models/note.dart';

class BodyView extends StatelessWidget {
  final textInputController = TextEditingController();
  final textInputNode = FocusNode();
  final Note note;

  BodyView({required this.note, super.key}) {
    textInputController.text = note.notes.value;
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
              note.notes.value = input;
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
