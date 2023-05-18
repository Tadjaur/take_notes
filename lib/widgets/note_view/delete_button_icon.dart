import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../services/database/database.dart';

class DeleteButtonIcon extends GetView<Database> {
  final hover = false.obs;
  DeleteButtonIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final color = controller.currentNote.color;
      return GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).hideCurrentMaterialBanner();

          ScaffoldMessenger.of(context).showMaterialBanner(
            MaterialBanner(
              content: Text('Delete this note?'),
              backgroundColor: color,
              contentTextStyle: TextStyle(color: Colors.grey.shade800),
              actions: [
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
                  },
                  style: ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(color),
                      foregroundColor:
                          MaterialStatePropertyAll(Colors.grey.shade800),
                      shape: const MaterialStatePropertyAll(
                          RoundedRectangleBorder())),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
                    controller.deleteCurrentNote();
                  },
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStatePropertyAll(Colors.red.shade800),
                      foregroundColor: MaterialStatePropertyAll(color),
                      shape: const MaterialStatePropertyAll(
                          RoundedRectangleBorder())),
                  child: Text('Yes Delete It'),
                ),
              ],
            ),
          );
        },
        child: MouseRegion(
          onExit: (d) {
            hover.value = false;
          },
          onEnter: (value) {
            hover.value = true;
          },
          child: ColoredBox(
            color: hover.value ? Colors.red.shade800 : Colors.transparent,
            child: SizedBox(
              width: 32,
              child: Center(
                child: Icon(
                  Icons.delete_forever_outlined,
                  color: hover.isTrue ? color : Colors.grey.shade800,
                  size: 18,
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
