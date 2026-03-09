import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_theme.dart';
import 'calendar_controller.dart';

class CalendarPage extends GetView<CalendarController> {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.accentPurple,
                      strokeWidth: 3,
                    ),
                  );
                }

                // Placeholder for an actual calendar view
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_month_rounded,
                        size: 80,
                        color: AppTheme.textSecondary(
                          context,
                        ).withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No upcoming events',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your schedule looks clear.',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary(context),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Schedule Meeting'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.divider(context).withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Calendar',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary(context),
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              Icons.today_rounded,
              color: AppTheme.textSecondary(context),
            ),
            onPressed: () {},
            tooltip: 'Today',
          ),
          IconButton(
            icon: Icon(Icons.add_rounded, color: AppTheme.accentPurple),
            onPressed: () {},
            tooltip: 'New Event',
          ),
        ],
      ),
    );
  }
}
