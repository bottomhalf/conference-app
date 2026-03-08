import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/meeting_model.dart';
import '../../../theme/app_theme.dart';
import '../home_controller.dart';

/// Displays top 6 recent meetings fetched from the API as a
/// grid of glassmorphism cards.
class RecentMeetingsGrid extends GetView<HomeController> {
  const RecentMeetingsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Loading state
      if (controller.isLoadingMeetings.value) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppTheme.accentPurple,
            ),
          ),
        );
      }

      // Error state
      if (controller.meetingsError.value != null) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
          child: Column(
            children: [
              Icon(
                Icons.cloud_off_rounded,
                size: 40,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(height: 12),
              Text(
                'Couldn\'t load meetings',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: controller.fetchRecentMeetings,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Retry'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.accentPurple,
                ),
              ),
            ],
          ),
        );
      }

      // Empty state
      if (controller.recentMeetings.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.videocam_off_rounded,
                  size: 40,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(height: 12),
                Text(
                  'No recent meetings',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                ),
              ],
            ),
          ),
        );
      }

      // Meeting cards — grid of 2 columns
      final meetings = controller.recentMeetings;
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: meetings.length,
        itemBuilder: (context, index) => _MeetingCard(meeting: meetings[index]),
      );
    });
  }
}

class _MeetingCard extends StatelessWidget {
  final MeetingModel meeting;

  const _MeetingCard({required this.meeting});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    // Pick a unique gradient per card based on index
    final gradients = [
      const [Color(0xFF6C5CE7), Color(0xFF8E7CF3)],
      const [Color(0xFF2D7FF9), Color(0xFF18BFFF)],
      const [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
      const [Color(0xFF00B894), Color(0xFF55EFC4)],
      const [Color(0xFFE17055), Color(0xFFF8A5C2)],
      const [Color(0xFFA29BFE), Color(0xFF6C5CE7)],
    ];
    final colorPair = gradients[meeting.id.hashCode.abs() % gradients.length];

    return GestureDetector(
      onTap: () => controller.openMeeting(meeting),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.cardDark.withValues(alpha: 0.9),
                  AppTheme.cardDarkAlt.withValues(alpha: 0.75),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colorPair[0].withValues(alpha: 0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Icon badge ──
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: colorPair),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    meeting.conversationType == 'group'
                        ? Icons.groups_rounded
                        : Icons.person_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(height: 14),

                // ── Meeting name ──
                Text(
                  meeting.conversationName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
                const Spacer(),

                // ── Last message preview ──
                if (meeting.lastMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      meeting.lastMessage!.content,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),

                // ── Footer: participants + time ──
                Row(
                  children: [
                    // Participant avatars stack
                    SizedBox(
                      width: _avatarStackWidth(meeting.participantCount),
                      height: 22,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: List.generate(
                          meeting.participantCount.clamp(0, 3),
                          (i) => Positioned(
                            left: i * 14.0,
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: colorPair),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppTheme.surfaceDark,
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  meeting.participants[i].initials,
                                  style: const TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (meeting.participantCount > 3) ...[
                      const SizedBox(width: 4),
                      Text(
                        '+${meeting.participantCount - 3}',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const Spacer(),
                    Text(
                      meeting.timeAgo,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _avatarStackWidth(int count) {
    final shown = count.clamp(0, 3);
    if (shown == 0) return 0;
    return 22.0 + (shown - 1) * 14.0;
  }
}
