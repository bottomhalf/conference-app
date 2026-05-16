import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared/widgets/desktop_shell.dart';
import '../../team/team_page.dart';
import '../../calendar/calendar_page.dart';
import '../../meet/meet_page.dart';
import '../../settings/settings_page.dart';
import '../main_controller.dart';

/// Desktop-optimised main page with persistent side navigation.
///
/// Uses the [DesktopShell] to provide a side menu + top header,
/// with the content area showing the currently selected page.
class DesktopMainPage extends GetView<MainController> {
  const DesktopMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DesktopShell(
      child: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value,
          children: const [
            TeamPage(),
            MeetPage(),
            CalendarPage(),
            SettingsPage(),
          ],
        ),
      ),
    );
  }
}
