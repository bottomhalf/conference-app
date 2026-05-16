import 'package:flutter/material.dart';

import 'desktop_side_menu.dart';

/// Desktop shell layout that wraps content with the side menu.
///
/// Used by the desktop variant of MainPage to provide a persistent
/// side navigation alongside the page content.
class DesktopShell extends StatelessWidget {
  const DesktopShell({
    super.key,
    required this.child,
  });

  /// The main content area (the page body).
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // ── Persistent side menu ──
          const DesktopSideMenu(),

          // ── Main content area ──
          Expanded(child: child),
        ],
      ),
    );
  }
}
