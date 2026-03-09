import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/meeting_service.dart';
import 'meeting_overlay.dart';

/// Wraps the app with a Stack so the [MeetingOverlay] can render
/// on top of all routes when a meeting is active.
///
/// Much simpler and more reliable than using OverlayEntry.
class MeetingOverlayManager extends StatelessWidget {
  final Widget child;

  const MeetingOverlayManager({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // The normal app (navigator, routes, etc.)
        child,

        // Meeting overlay — shown on top when in a meeting
        Obx(() {
          if (!MeetingService.instance.isInMeeting.value) {
            return const SizedBox.shrink();
          }
          return const MeetingOverlay();
        }),
      ],
    );
  }
}
