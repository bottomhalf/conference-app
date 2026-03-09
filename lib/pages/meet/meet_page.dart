import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../services/meeting_service.dart';
import '../../theme/app_theme.dart';
import 'meet_controller.dart';
import 'widgets/quick_action_tile.dart';
import 'widgets/recent_meetings_grid.dart';

class MeetPage extends GetView<MeetController> {
  const MeetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isInMeeting = MeetingService.instance.isInMeeting.value;

      return PopScope(
        canPop: !isInMeeting,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;

          final bool? shouldPop = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: AppTheme.card(context),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Exit Application?',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              content: Text(
                'Currently a meeting is ongoing. If you exit, you will automatically be disconnected from the meeting.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: AppTheme.accentPurple),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    'Exit',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
              ],
            ),
          );

          if (shouldPop == true) {
            await MeetingService.instance.leaveMeeting();
            SystemNavigator.pop();
          }
        },
        child: Scaffold(
          body: Stack(
            children: [
              // ── Background gradient orbs ──
              _backgroundOrbs(),

              // ── Main content ──
              SafeArea(
                child: RefreshIndicator(
                  onRefresh: controller.fetchRecentMeetings,
                  color: AppTheme.accentPurple,
                  backgroundColor: AppTheme.card(context),
                  child: CustomScrollView(
                    slivers: [
                      // ─── App Bar ───
                      SliverToBoxAdapter(child: _buildAppBar(context)),

                      // ─── Welcome Section ───
                      SliverToBoxAdapter(child: _buildWelcome(context)),

                      // ─── Quick Actions ───
                      SliverToBoxAdapter(child: _buildQuickActions(context)),

                      // ─── Recent Meetings Header ───
                      SliverToBoxAdapter(child: _buildRecentHeader(context)),

                      // ─── Recent Meetings Grid (from API) ───
                      const SliverToBoxAdapter(child: RecentMeetingsGrid()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _backgroundOrbs() {
    return Stack(
      children: [
        Positioned(
          top: -80,
          right: -60,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.accentPurple.withValues(alpha: 0.25),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -100,
          left: -80,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.primaryIndigo.withValues(alpha: 0.18),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: AppTheme.accentGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.videocam_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Text('Conference', style: Theme.of(context).textTheme.headlineMedium),
          const Spacer(),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: AppTheme.accentGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Text(
                'U',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcome(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back 👋',
            style: Theme.of(
              context,
            ).textTheme.headlineLarge?.copyWith(fontSize: 26),
          ),
          const SizedBox(height: 6),
          Text(
            'Start or join a meeting to collaborate with your team.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      child: Row(
        children: [
          QuickActionTile(
            icon: Icons.video_call_rounded,
            label: 'New\nMeeting',
            gradient: AppTheme.accentGradient,
            onTap: () {
              Get.snackbar(
                'Not Available',
                'Instant meeting requires a LiveKit server',
                snackPosition: SnackPosition.BOTTOM,
                margin: const EdgeInsets.all(16),
                borderRadius: 12,
              );
            },
          ),
          const SizedBox(width: 14),
          QuickActionTile(
            icon: Icons.calendar_today_rounded,
            label: 'Schedule',
            gradient: const LinearGradient(
              colors: [Color(0xFF2D7FF9), Color(0xFF18BFFF)],
            ),
            onTap: () {},
          ),
          const SizedBox(width: 14),
          QuickActionTile(
            icon: Icons.screen_share_rounded,
            label: 'Share\nScreen',
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
            ),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildRecentHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
      child: Row(
        children: [
          Text(
            'Recent Meetings',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Spacer(),
          TextButton(
            onPressed: () {},
            child: Text(
              'See all',
              style: TextStyle(
                color: AppTheme.accentPurple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
