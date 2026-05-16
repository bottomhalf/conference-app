import 'package:flutter/material.dart';

/// Breakpoints for responsive layout switching.
class Breakpoints {
  Breakpoints._();

  /// Width threshold below which we show the mobile layout.
  static const double mobile = 800;

  /// Width threshold above which we show the desktop layout.
  static const double desktop = 800;
}

/// A builder widget that renders different UIs based on screen width.
///
/// Works on all platforms including web — uses [MediaQuery] width,
/// NOT dart:io Platform checks, so it's fully web-compatible.
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    required this.desktop,
  });

  /// Builder for mobile / narrow viewports (< 800px).
  final Widget Function(BuildContext context) mobile;

  /// Builder for desktop / wide viewports (≥ 800px).
  final Widget Function(BuildContext context) desktop;

  /// Returns true when the current viewport is desktop-width.
  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= Breakpoints.desktop;

  /// Returns true when the current viewport is mobile-width.
  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < Breakpoints.mobile;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width >= Breakpoints.desktop) {
      return desktop(context);
    }
    return mobile(context);
  }
}
