import 'dart:math';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NoteView extends StatelessWidget {
  NoteView({super.key});

  final textInputController = TextEditingController();
  final currentColor = Rx<Color>(Colors.grey);

  @override
  Widget build(BuildContext context) {
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
              onTap: () => currentColor.value = [
                Color(0xFFCBB3F1),
                Color(0xFFFCF296),
                Color(0xFFE8EAED),
                Color(0xFFC8FAEC),
                Color(0xFFCEABE5A),
              ].elementAt(Random().nextInt(4)),
              child: Icon(Icons.color_lens_outlined, color: Colors.grey.shade800,),
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
              textInputController: textInputController,
              color: currentColor.value,
            )),
      ),
    );
  }
}

class BodyView extends StatelessWidget {
  final TextEditingController textInputController;
  final textInputNode = FocusNode();
  final Color? color;

  BodyView({required this.textInputController, this.color, super.key});

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
