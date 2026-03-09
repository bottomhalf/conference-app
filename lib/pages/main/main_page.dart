import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../theme/app_theme.dart';
import '../../widgets/app_header.dart';
import '../team/team_page.dart';
import '../calendar/calendar_page.dart';
import '../meet/meet_page.dart';
import '../settings/settings_page.dart';
import 'main_controller.dart';

class MainPage extends GetView<MainController> {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(),
      body: Obx(
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
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: AppTheme.card(context).withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(36),
              border: Border.all(
                color: AppTheme.divider(context).withValues(alpha: 0.5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentPurple.withValues(alpha: 0.15),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(36),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Obx(
                    () => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildNavItem(
                          context: context,
                          icon: Icons.groups_rounded,
                          label: 'Team',
                          index: 0,
                        ),
                        _buildNavItem(
                          context: context,
                          icon: Icons.videocam_rounded,
                          label: 'Meet',
                          index: 1,
                        ),
                        _buildNavItem(
                          context: context,
                          icon: Icons.calendar_month_rounded,
                          label: 'Calendar',
                          index: 2,
                        ),
                        _buildNavItem(
                          context: context,
                          icon: Icons.settings_rounded,
                          label: 'Settings',
                          index: 3,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = controller.currentIndex.value == index;
    final color = isSelected
        ? AppTheme.accentPurple
        : AppTheme.textSecondary(context).withValues(alpha: 0.6);

    return InkWell(
      onTap: () => controller.changePage(index),
      borderRadius: BorderRadius.circular(24),
      splashColor: AppTheme.accentPurple.withValues(alpha: 0.1),
      highlightColor: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 20 : 12,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.accentPurple.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Icon(
                icon,
                key: ValueKey<bool>(isSelected),
                color: color,
                size: isSelected ? 26 : 24,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
