import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../services/database/database.dart';

class RandomPaint extends GetView<Database> {
  final hover = false.obs;
  RandomPaint({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GestureDetector(
        onTap: () {
          const colorSet = [
            Color(0xFFCBB3F1),
            Color(0xFFFCF296),
            Color(0xFFE8EAED),
            Color(0xFFC8FAEC),
            Color(0xFFEABE5A),
          ];
          final pos = colorSet.indexWhere(
              (clr) => clr.value == controller.currentNote.colorValue.value);

          controller.currentNote.colorValue.value =
              colorSet.elementAt((pos + 1) % colorSet.length).value;
          controller.currentNote.save();
        },
        child: MouseRegion(
          onExit: (d) {
            hover.value = false;
          },
          onEnter: (value) {
            hover.value = true;
          },
          child: ColoredBox(
            color: hover.value ? Colors.grey.shade800 : Colors.transparent,
            child: SizedBox(
              width: 32,
              child: Center(
                child: Icon(
                  Icons.color_lens_outlined,
                  color: hover.isTrue
                      ? controller.currentNote.color
                      : Colors.grey.shade800,
                  size: 18,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
