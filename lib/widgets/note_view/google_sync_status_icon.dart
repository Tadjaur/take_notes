import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:take_notes/services/database/database.dart';

class GoogleSyncStatusIcon extends GetView<Database> {
  final hover = false.obs;
  final loading = false.obs;
  GoogleSyncStatusIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: (() async {
          // tap
          loading.value = true;
          SyncResponse? syncResponse;
          try {
            syncResponse = await controller.syncData();
          } on Exception catch (e) {
            print('ERROR CAUGHT: $e');
            syncResponse = SyncResponse.failed;
          }
          loading.value = false;
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          switch (syncResponse) {
            case SyncResponse.succeeded:
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Text('Synchronized!'),
                  ),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 3),
                  padding: EdgeInsets.zero,
                ),
              );
              break;
            case SyncResponse.failed:
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Text('Synchronization failed!'),
                  ),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 3),
                  padding: EdgeInsets.zero,
                ),
              );
              break;
          }
        }),
        child: MouseRegion(
          onExit: (d) {
            hover.value = false;
          },
          onEnter: (value) {
            hover.value = true;
          },
          child: Obx(() {
            final childIcon = Icon(
              Icons.sync,
              color: hover.isTrue ? null : Colors.grey.shade800,
              size: 18,
            );
            return ColoredBox(
              color: hover.value ? Colors.blue.shade800 : Colors.transparent,
              child: SizedBox.square(
                dimension: 32,
                child: loading.isFalse
                    ? childIcon
                    : TweenAnimationBuilder<double>(
                        builder: (context, value, child) {
                          return AnimatedRotation(
                            duration: Duration(seconds: 1),
                            turns: -value,
                            child: child,
                          );
                        },
                        child: childIcon,
                        duration: Duration(seconds: 500),
                        tween: Tween(begin: 0, end: 500),
                        onEnd: () {},
                      ),
              ),
            );
          }),
        ));
  }
}
