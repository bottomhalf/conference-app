import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../shared/responsive/responsive_builder.dart';
import 'main_controller.dart';
import 'mobile/mobile_main_page.dart';
import 'desktop/desktop_main_page.dart';

/// Responsive main page router.
///
/// Delegates to [MobileMainPage] (bottom nav) or [DesktopMainPage]
/// (side menu) based on viewport width (breakpoint: 800px).
class MainPage extends GetView<MainController> {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: (_) => const MobileMainPage(),
      desktop: (_) => const DesktopMainPage(),
    );
  }
}
