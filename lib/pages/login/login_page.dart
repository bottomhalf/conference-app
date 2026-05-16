import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../shared/responsive/responsive_builder.dart';
import 'login_controller.dart';
import 'mobile/mobile_login_page.dart';
import 'desktop/desktop_login_page.dart';

/// Responsive login page router.
///
/// Delegates to [MobileLoginPage] or [DesktopLoginPage] based on
/// the current viewport width (breakpoint: 800px).
///
/// Both child pages share the same [LoginController] for state
/// management, API calls, and business logic.
class LoginPage extends GetView<LoginController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: (_) => const MobileLoginPage(),
      desktop: (_) => const DesktopLoginPage(),
    );
  }
}
