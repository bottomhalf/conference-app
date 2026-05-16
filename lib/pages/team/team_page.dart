import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../shared/responsive/responsive_builder.dart';
import 'team_controller.dart';
import 'mobile/mobile_team_page.dart';
import 'desktop/desktop_team_page.dart';

/// Responsive team page router.
///
/// Delegates to [MobileTeamPage] or [DesktopTeamPage] based on
/// viewport width (breakpoint: 800px).
///
/// Both child pages share the same [TeamController].
class TeamPage extends GetView<TeamController> {
  const TeamPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: (_) => const MobileTeamPage(),
      desktop: (_) => const DesktopTeamPage(),
    );
  }
}
